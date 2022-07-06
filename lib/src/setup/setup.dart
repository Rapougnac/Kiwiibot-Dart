import 'package:kiwiibot_dart/src/commands/both/help_command.dart';
import 'package:kiwiibot_dart/src/commands/both/ping_command.dart';
import 'package:kiwiibot_dart/src/utils/converters/list_converter.dart';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx_commands/nyxx_commands.dart';

void setup(String token) {
  final client = NyxxFactory.createNyxxWebsocket(token, GatewayIntents.all)
    ..registerPlugin(Logging())
    ..registerPlugin(CliIntegration())
    ..registerPlugin(IgnoreExceptions());

  final commands = CommandsPlugin(
      prefix: (m) => 'm?', guild: 911736666551640075.toSnowflake());
  commands
    ..addCommand(pingCommand)
    ..addCommand(helpCommand);

  commands.addConverter(listStringConverter);

  client.registerPlugin(commands);

  client.connect();
}
