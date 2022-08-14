import 'dart:async';
import 'dart:convert';

import 'package:fuzzy/fuzzy.dart';
import 'package:kiwiibot_dart/src/setup/setup.dart';
import 'package:kiwiibot_dart/src/utils/checks/checks.dart';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx_commands/nyxx_commands.dart';
import 'package:nyxx_interactions/nyxx_interactions.dart';
import 'package:nyxx_lavalink/nyxx_lavalink.dart';
import 'package:http/http.dart' as http;

/// Play some music in the channel you're connected to!
final playCommand = ChatCommand(
  'play',
  'Yes',
  id(
    'play',
    (
      IContext ctx,
      @Autocomplete(cb) String song,
      @Description('Whether to activate autoplay') bool autoPlay,
    ) async {
      final o = ctx is MessageChatContext ? (ctx) : null;
      // o.message
      // o.targetMessage
      if (song.length <= 3) {
        return await ctx.respond(MessageBuilder.content(
          'The song name must be greater than 3 characters!',
        ));
      }
      var amIConnected = false;
      final state =
          ctx.guild!.voiceStates[(ctx.client as INyxxWebsocket).self.id];
      if (state != null) {
        amIConnected = true;
      }

      var isAuthorConnected = false;
      final authorState = ctx.guild!.voiceStates[ctx.user.id];
      if (authorState != null) {
        isAuthorConnected = true;
      }

      if (isAuthorConnected) {
        ((await authorState!.channel!.getOrDownload()) as IVoiceGuildChannel)
            .connect();
        final node = cluster.getOrCreatePlayerNode(ctx.guild!.id);
        var links = await node.autoSearch(song);

        node.play(ctx.guild!.id, links.tracks.first).queue();
        final embed = EmbedBuilder()
          ..addAuthor((author) => author
            ..iconUrl = ctx.user.avatarURL()
            ..name = ctx.user.tag)
          ..description =
              '[${links.tracks.first.info?.title}](${links.tracks.first.info?.uri}) has been added to the queue.'
          ..color ??= DiscordColor.hotPink;
        // if (autoPlay) {
        //   final recommendedTrack =
        //       await links.tracks.first.getRecommendedTrack(ctx.guild!.id);
        //   cluster.eventDispatcher.onTrackEnd.listen((event) {
        //     event.
        //   });
        // }
        return await ctx.respond(MessageBuilder.embed(embed));
      } else {
        return await ctx.respond(MessageBuilder.content(
          '''You're not connected in a voice channel!''',
        ));
      }
    },
  ),
  checks: [guildCheck],
  aliases: const ['p'],
);

FutureOr<Iterable<ArgChoiceBuilder>?> cb(AutocompleteContext ctx) async {
  final current = ctx.currentValue;
  if (current.length <= 3) {
    return [
      ArgChoiceBuilder(
        'The song name must be greater than 3 characters',
        'songLess3Chars',
      )
    ];
  }

  final request = await http.get(
    Uri.parse(
        'https://youtube.com/results?q=${Uri.encodeComponent(current).replaceAll('%20', '+')}&hl=en&sp=EgIQAQ%253D%253D'),
    headers: {
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.116 Safari/537.36',
    },
  );

  var html = request.body;
  var details = [];
  var fetched = false;

  // Rewritten from: https://github.com/DevAndromeda/youtube-sr/blob/rewrite/src/Util.ts#L108
  try {
    var data = html
        .split('ytInitialData = JSON.parse(\'')[1]
        .split('\');</script>')
        .first;
    html = data.replaceAllMapped(
        RegExp(
          r'\\x([0-9A-F]{2})',
          caseSensitive: false,
        ),
        (match) => String.fromCharCode(int.parse(match.group(1)!, radix: 16)));
    // ignore: empty_catches
  } catch (e) {}
  try {
    details = jsonDecode(
      html
          .split('{"itemSelectionRenderer":{"contents":')
          .last
          .split(',"continuations":[{')
          .first,
    );
    fetched = true;
    // ignore: empty_catches
  } catch (e) {}
  if (!fetched) {
    try {
      details = jsonDecode(
        html
            .split('{"itemSectionRenderer":')
            .last
            .split('},{"continuationItemRenderer":{')
            .first,
      )['contents'];
      fetched = true;
      // ignore: empty_catches
    } catch (e) {}
  }
  var parsed = details.map((d) => VideoRenderer.fromJson(d)).toList();
  final fuzzy = Fuzzy<VideoRenderer>(
    parsed,
    options: FuzzyOptions(
      keys: [
        WeightedKey(name: 'title', getter: (v) => v.title!, weight: 5),
        WeightedKey(name: 'artist', getter: (v) => v.artist!, weight: 1),
      ],
    ),
  );
  final result = fuzzy.search(current);
  final filtered = result;
  try {
    filtered
        .map((e) => ArgChoiceBuilder(
              '${e.item.title}',
              'https://www.youtube.com/watch?v=${e.item.videoId}',
            ))
        .toList()
        .sublist(0, 100);
  } catch (_) {
    return filtered.map((e) => ArgChoiceBuilder(
          '${e.item.title}',
          'https://www.youtube.com/watch?v=${e.item.videoId}',
        ));
  }

  return filtered.map((e) => ArgChoiceBuilder(
      '${e.item.title}', 'https://www.youtube.com/watch?v=${e.item.videoId}'));
}

extension TtsNode on INode {
  Future<ITracks> sendTts(String query) => searchTracks('speak:$query');
}

extension on ITrack {
  Future<ITrack> getRecommendedTrack(Snowflake guildId) async {
    final r =
        await http.get(Uri.parse('${info?.uri}')).then((value) => value.body);
    final node = cluster.getOrCreatePlayerNode(guildId);

    final preRawRecommended =
        r.split('var ytInitialData = ')[1].split('</script>').first;
    final rawRecommended = (jsonDecode(preRawRecommended.substring(
                    0, preRawRecommended.length - 1))?['contents']
                ?['twoColumnWatchNextResults']?['secondaryResults']
            ?['secondaryResults']?['results'] as List)
        .map((e) => e['compactVideoRenderer'])
        .first;

    final track = (await node.searchTracks(
            'https://www.youtube.com/watch?v=${rawRecommended['videoId']}'))
        .tracks
        .first;

    return track;
  }
}

class VideoRenderer {
  late String? videoId;
  late String? thumbnail;
  late String? title;
  late String? artist;
  late String? publishedAt;
  late String? duration;
  late String? viewCount;
  VideoRenderer.fromJson(dynamic data) {
    videoId = data['videoRenderer']?['videoId'];
    thumbnail = data['videoRenderer']?['thumbnail']['thumbnails'][0]['url'];
    title = data['videoRenderer']?['title']['runs'][0]['text'] ?? 'unknown';
    artist = data['videoRenderer']?['longBylineText']['runs'][0]['text'] ??
        'unknown';
    publishedAt =
        data['videoRenderer']?['publishedTimeText']?['simpleText'] ?? '0';
    duration = data['videoRenderer']?['lengthText']?['simpleText'] ?? '0';
    viewCount = data['videoRenderer']?['viewCountText']?['simpleText'] ?? '0';
  }
}
