import 'package:kiwiibot_dart/src/setup/setup.dart';
import 'package:kiwiibot_dart/src/utils/checks/guild_check.dart';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx_commands/nyxx_commands.dart';

/// Play some music in the channel you're connected to!
final playCommand = ChatCommand(
  'play',
  'Yes',
  id(
    'play',
    (IContext ctx, String song) async {
      var amIConnected = false;
      final state =
          ctx.guild!.voiceStates[(ctx.client as INyxxWebsocket).self.id];
      if (state != null) {
        amIConnected = true;
      }

      if (amIConnected) {
        final node = cluster.getOrCreatePlayerNode(ctx.guild!.id);
        final links = await node.searchTracks(song);

        node.play(ctx.guild!.id, links.tracks.first).queue();
        final embed = EmbedBuilder()
          ..addAuthor((author) => author
            ..iconUrl = ctx.user.avatarURL()
            ..name = ctx.user.tag)
          ..description =
              '${links.tracks.first.info?.title} has been added to the queue.'
          ..color ??= DiscordColor.hotPink;
        return ctx.respond(MessageBuilder.embed(embed));
      } else {
        var isAuthorConnected = false;
        final authorState = ctx.guild!.voiceStates[ctx.user.id];
        if (authorState != null) {
          isAuthorConnected = true;
        }

        if (isAuthorConnected) {
          ((await authorState!.channel!.getOrDownload()) as IVoiceGuildChannel)
              .connect();
          final node = cluster.getOrCreatePlayerNode(ctx.guild!.id);
          final links = await node.searchTracks(song);

          node.play(ctx.guild!.id, links.tracks.first).queue();
          final embed = EmbedBuilder()
            ..addAuthor((author) => author
              ..iconUrl = ctx.user.avatarURL()
              ..name = ctx.user.tag)
            ..description =
                '${links.tracks.first.info?.title} has been added to the queue.'
            ..color ??= DiscordColor.hotPink;
          return ctx.respond(MessageBuilder.embed(embed));
        } else {
          return await ctx.respond(MessageBuilder.content(
            '''You're not connected in a voice channel!''',
          ));
        }
      }
    },
  ),
  checks: [guildCheck],
);
