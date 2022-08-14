import 'package:kiwiibot_dart/src/setup/setup.dart';
import 'package:kiwiibot_dart/src/utils/checks/checks.dart';
import 'package:nyxx_commands/nyxx_commands.dart';

final skipCommand = ChatCommand(
  'skip',
  'UwU',
  id(
    'skip',
    (IContext ctx) {
      final node = cluster.getOrCreatePlayerNode(ctx.guild!.id);
    },
  ),
  aliases: const ['s'],
  checks: [guildCheck],
);
