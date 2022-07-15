import 'package:kiwiibot_dart/src/commands/both/help_command.dart';
import 'package:kiwiibot_dart/src/commands/both/ping_command.dart';
import 'package:kiwiibot_dart/src/commands/legacy/massban_command.dart';
import 'package:kiwiibot_dart/src/db/connection.dart';
import 'package:kiwiibot_dart/src/utils/converters/list_converter.dart';
import 'package:kiwiibot_dart/src/utils/converters/permissionsraw_to_human_readable.dart';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx_commands/nyxx_commands.dart';

void setup(String token) async {
  final client = NyxxFactory.createNyxxWebsocket(
    token,
    // All intents exept typings.
    GatewayIntents.all &
        ~GatewayIntents.guildMessageTyping &
        ~GatewayIntents.directMessageTyping,
    cacheOptions: CacheOptions()
      // I really like overcaching, yes
      ..memberCachePolicyLocation = CachePolicyLocation.all()
      ..memberCachePolicy = MemberCachePolicy.all,
  )
    ..registerPlugin(Logging())
    ..registerPlugin(CliIntegration())
    ..registerPlugin(IgnoreExceptions());

  final commands = CommandsPlugin(
    prefix: (m) => 'm?',
    guild: 911736666551640075.toSnowflake(),
  );
  commands
    ..addCommand(pingCommand)
    ..addCommand(helpCommand)
    ..addCommand(massbanCommand);

  commands.addConverter(listStringConverter);

  commands.onCommandError.listen((c) {
    if (c is CheckFailedException) {
      if (c.failed.name == 'guildCheck') {
        c.context.respond(
            MessageBuilder.content('This command cannot be used in DMs'));
        return;
      }

      if (c.failed.name == 'permissionsCheck') {
        final permissions = convertRawPermissionsToReadable(
            (c.failed as PermissionsCheck).permissionsValue);
        c.context.respond(MessageBuilder.content(
          'Hey, it looks like you\'re missing the: ${permissions.join(', ')} permission${permissions.length == 1 ? '' : 's'}!',
        ));
        return;
      }
    } else if (c is BadInputException) {
      c.context.respond(
        MessageBuilder.content(
            '${c.runtimeType}: ${c.message.split(':').last.trimLeft()}'),
      );
      return;
    }
  });

  client.registerPlugin(commands);

  client.connect();

  await setupConnection();
}
