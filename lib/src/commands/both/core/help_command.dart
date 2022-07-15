import 'package:kiwiibot_dart/args.g.dart';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx_commands/nyxx_commands.dart';
import 'package:kiwiibot_dart/descriptions.g.dart';

/// Helps you a lil', actually
final helpCommand = ChatCommand(
  'help',
  helpCommandDescription,
  id<Function(IChatContext, String)>(
    'help',
    (ctx, [String? commandName]) {
      if (commandName == null) {
        return ctx.respond(MessageBuilder.content('No u'), private: true);
      }
      final gettedCommand = ctx.commands.getCommand(StringView(commandName));
      if (gettedCommand == null) {
        return ctx.respond(
          MessageBuilder.content(
            'Failed to get this command, try again, have you made a typo?',
          ),
        );
      }
      final commandParams = generatedArgs[commandName]?['args'] ?? '';
      final embed = EmbedBuilder()
        ..title =
            '${ctx is InteractionChatContext && gettedCommand.type != CommandType.textOnly ? '/' : (ctx as MessageChatContext).prefix}${gettedCommand.name} $commandParams'
        ..description = generatedArgs[commandName]?['description'];
      return ctx.respond(
        MessageBuilder.content('Yes, I will help you')..embeds = [embed],
      );
    },
  ),
);
