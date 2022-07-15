import 'package:nyxx/nyxx.dart';
import 'package:nyxx_commands/nyxx_commands.dart';
import 'package:kiwiibot_dart/descriptions.g.dart';

/// Simple command that respond with pong, fun if you're bored
final pingCommand = ChatCommand(
  'ping',
  pingCommandDescription,
  id<Function(IChatContext)>(
    'ping',
    (ctx, [List<String> rest = const []]) {
      return ctx.respond(
        MessageBuilder.content('Pong! You said ${rest.join(' ')}'),
      );
    },
  ),
);
