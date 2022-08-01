import 'dart:math' as math;

import 'package:nyxx/nyxx.dart';
import 'package:nyxx_commands/nyxx_commands.dart';
import 'package:kiwiibot_dart/descriptions.g.dart';
import 'package:kiwiibot_dart/src/setup/setup.dart';

/// Simple command that respond with pong, fun if you're bored
final pingCommand = ChatCommand(
  'ping',
  pingCommandDescription,
  id<Function(IChatContext)>(
    'ping',
    (ctx) async {
      final msg = await ctx.respond(MessageBuilder.content('🏓 Pinging....'));
      final ping = msg.createdAt.difference(
        ctx is MessageChatContext
            ? ctx.message.createdAt
            : (ctx as InteractionChatContext).interaction.createdAt,
      );
      final hb = (ctx.client as INyxxWebsocket).shardManager.gatewayLatency;
      final translated = ctx.guild != null
          ? ctx.guild.slang.core.ping(
              o: 'o' * math.min(ping.inMilliseconds ~/ 100, 1500),
              ping: ping.inMilliseconds,
              hb: hb.inMilliseconds == 0 ? 'NOT ACKED' : hb.inMilliseconds,
            )
          : fb.core.ping(
              o: 'o' * math.min(ping.inMilliseconds ~/ 100, 1500),
              ping: ping.inMilliseconds,
              hb: hb.inMilliseconds == 0 ? 'NOT ACKED' : hb.inMilliseconds,
            );
      return await msg.edit(
        MessageBuilder.content(
          translated,
        ),
      );
    },
  ),
);
