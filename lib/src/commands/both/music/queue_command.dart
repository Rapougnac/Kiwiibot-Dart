import 'package:kiwiibot_dart/src/setup/setup.dart';
import 'package:kiwiibot_dart/src/utils/checks/checks.dart';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx_commands/nyxx_commands.dart';

/// Shows the queue that's currently consumed.
final queueCommand = ChatCommand(
  'queue',
  'udfdiufd',
  id(
    'queue',
    (IContext ctx) async {
      final node = cluster.getOrCreatePlayerNode(ctx.guild!.id);

      final player = node.players.isNotEmpty ? node.players.values.first : null;
      if (player != null && player.queue.isNotEmpty) {
        final embed = EmbedBuilder()
          ..addAuthor((author) => author
            ..iconUrl = ctx.user.avatarURL()
            ..name = ctx.user.tag);
        // int index;
        for (int i = 0; i < player.queue.length; i++) {
          final track = player.queue[i];
          embed.description =
              '${i + 1} • ${track.track.info?.title ?? track.track.track} requested by ${ctx.client.users[track.requester] ?? await (ctx.client as INyxxWebsocket).fetchUser(track.requester ?? Snowflake.zero())}';
        }
      }
    },
  ),
  checks: [guildCheck],
);
