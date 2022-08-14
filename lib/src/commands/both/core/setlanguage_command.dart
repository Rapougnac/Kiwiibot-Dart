import 'dart:async';

import 'package:kiwiibot_dart/src/utils/checks/checks.dart';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx_commands/nyxx_commands.dart';
import 'package:nyxx_interactions/nyxx_interactions.dart';
import 'package:kiwiibot_dart/strings.g.dart';
import 'package:kiwiibot_dart/src/setup/setup.dart';

/// Set a specified locale for the current guild.
final setLanguageCommand = ChatCommand(
  'setlanguage',
  'ssjdnsj',
  id(
    'setlanguage',
    (
      IContext ctx,
      @Name(
        'locale',
        {Locale.french: 'langue'},
      )
      @Description(
        'The new locale to use',
        {
          Locale.french: 'La nouvelle langue à utiliser',
          Locale.german: 'Die neue zu verwendende Sprache',
        },
      )
      @Autocomplete(cb)
          String newLocale,
    ) async {
      final locales = AppLocale.values.map((e) => e.languageCode);
      if (!locales.contains(newLocale)) {
        return await ctx.respond(
          MessageBuilder.content(
            ctx.guild!.slang.core.setLangCommand
                .localeNotFound(locales: locales.join(', ')),
          ),
        );
      }

      await supabase
          .from('guild')
          .update({'language': newLocale})
          .eq('guild_id', ctx.guild!.id)
          .execute();
      final Map c = cached[ctx.guild!.id.toString()];
      c['language'] = newLocale;
      cached[ctx.guild!.id.toString()] = c;

      return await ctx.respond(MessageBuilder.content('Done 😎👌😘'));
    },
  ),
  checks: [guildCheck],
);

FutureOr<Iterable<ArgChoiceBuilder>?> cb(AutocompleteContext ctx) {
  final current = ctx.currentValue;
  final choices = AppLocale.values.map((e) => e.languageCode);
  final filtered = choices.where((e) => e.startsWith(current));
  return filtered.map((e) => ArgChoiceBuilder(e, e));
}
