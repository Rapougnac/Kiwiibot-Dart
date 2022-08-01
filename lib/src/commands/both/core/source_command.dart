import 'dart:async';

import 'package:nyxx/nyxx.dart';
import 'package:nyxx_commands/nyxx_commands.dart';
import 'package:kiwiibot_dart/descriptions.g.dart';
import 'package:kiwiibot_dart/sources.g.dart';
import 'package:nyxx_interactions/nyxx_interactions.dart';

/// Shows the source of the command.
final sourceCommand = ChatCommand(
  'source',
  sourceCommandDescription,
  id(
    'source',
    (IContext ctx, [@Autocomplete(cb) String? command]) {
      final sourceUrl = 'https://github.com/Rapougnac/Kiwiibot-Dart';
      final branch = 'mistress';
      if (command == null) {
        return ctx.respond(MessageBuilder.content(sourceUrl));
      }
      final c = ctx.commands.getCommand(StringView(command));
      if (c == null) {
        return ctx.respond(MessageBuilder.content(sourceUrl));
      }

      final resolved = sourceFilesInfos[c.name];
      final lines = resolved!['lines']!.split('-');
      final location = resolved['path'];

      final url =
          '<$sourceUrl/blob/$branch/$location#L${lines.first}-L${lines.last}>';

      return ctx is MessageChatContext
          ? ctx.respond(MessageBuilder.content(url), mention: false)
          : ctx.respond(MessageBuilder.content(url));
    },
  ),
);

FutureOr<Iterable<ArgChoiceBuilder>?> cb(AutocompleteContext ctx) {
  final current = ctx.currentValue;
  final filtered =
      ctx.commands.walkCommands().where((e) => e.name.startsWith(current));
  return filtered.map((e) => ArgChoiceBuilder(e.name, e.name));
}
