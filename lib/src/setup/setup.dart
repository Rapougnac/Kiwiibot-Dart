import 'dart:async';
import 'dart:io';

import 'package:kiwiibot_dart/src/commands/both/core/help_command.dart';
import 'package:kiwiibot_dart/src/commands/both/core/ping_command.dart';
import 'package:kiwiibot_dart/src/commands/both/core/setlanguage_command.dart';
import 'package:kiwiibot_dart/src/commands/both/core/source_command.dart';
import 'package:kiwiibot_dart/src/commands/both/infos/user_command.dart';
import 'package:kiwiibot_dart/src/commands/both/music/play_command.dart';
// import 'package:kiwiibot_dart/src/commands/both/edit-images/images/rip.dart';
import 'package:kiwiibot_dart/src/commands/legacy/core/massban_command.dart';
import 'package:kiwiibot_dart/src/db/connection.dart';
import 'package:kiwiibot_dart/src/utils/converters/list_converter.dart';
import 'package:kiwiibot_dart/src/utils/converters/permissionsraw_to_human_readable.dart';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx_commands/nyxx_commands.dart';
import 'package:nyxx_lavalink/nyxx_lavalink.dart';
import 'package:supabase/supabase.dart';
import 'package:kiwiibot_dart/strings.g.dart';

late final ICluster cluster;
late final SupabaseClient supabase;
final cached = {};
final fb = AppLocale.en.build();

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
        ..memberCachePolicy = MemberCachePolicy.all
        ..userCachePolicyLocation = CachePolicyLocation.all())
    ..registerPlugin(Logging())
    ..registerPlugin(CliIntegration())
    ..registerPlugin(IgnoreExceptions());
  supabase = SupabaseClient(Platform.environment['SUPABASE_URL']!,
      Platform.environment['SUPABASE_KEY']!);

  final res = await supabase.from('guild').select().execute();

  for (var element in (res.data as List)) {
    final gid = element.remove('guild_id');
    cached[gid] = {...element as Map};
  }

  final commands = CommandsPlugin(
      prefix: (m) {
        if (m.guild == null) {
          return mentionOr((msg) => (dmOr((_) => 'm?'))(msg))(m);
        }
        final map = cached[m.guild!.id.toString()];
        if (map == null) {
          return mentionOr((msg) => (dmOr((_) => 'm?'))(msg))(m);
        }

        return map['prefix'];
      },
      guild: 911736666551640075.toSnowflake(),
      options: CommandsOptions(acceptSelfCommands: false));
  commands
    ..addCommand(pingCommand)
    ..addCommand(helpCommand)
    ..addCommand(massbanCommand)
    ..addCommand(sourceCommand)
    ..addCommand(setLanguageCommand)
    // ..addCommand(userCommand)
    ..addCommand(playCommand);
  // ..addCommand(ripCommand);

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

  // await setupConnection();

  client.eventsWs.onReady.listen((_) async {
    cluster = ICluster.createCluster(client, client.self.id);
    await cluster.addNode(NodeOptions());
  });

  // client.eventsWs.onGuildMemberUpdate.listen((event) async {
  //   final oldUser = event.oldUser!;
  //   final newUser = event.user;
  //   if (oldUser.username != newUser.username) {
  //     await connection.query(
  //       'insert into users(user_id) values (@uid) on conflict (user_id) do nothing',
  //       substitutionValues: {
  //         'uid': newUser.id.toString(),
  //       },
  //     );
  //     final results = await connection.query(
  //       'insert into usernames(username) values(@username) returning id',
  //       substitutionValues: {
  //         'username': oldUser.username,
  //       },
  //     );
  //     final id = results.first.first as int;
  //     final q = await connection.query(
  //       'select from users where user_id = @uid',
  //       substitutionValues: {'uid': newUser.id.toString()},
  //     );
  //     if (q.first.isEmpty) {
  //       final historyId = (await connection.query(
  //         'insert into history(usernames_id) values (@id) returning id',
  //         substitutionValues: {
  //           'id': id,
  //         },
  //       ))
  //           .first
  //           .first;
  //       await connection.query(
  //         'update users set history_id = @hid where user_id = @id',
  //         substitutionValues: {
  //           'id': newUser.id.toString(),
  //           'hid': historyId,
  //         },
  //       );
  //       await connection.query(
  //         'update usernames set history_id = @hid where history_id is not null and id = @id',
  //         substitutionValues: {
  //           'id': id,
  //           'hid': historyId,
  //         },
  //       );
  //     } else {
  //       final historyId = (await connection.query(
  //         'select history_id from users where user_id = @uid',
  //         substitutionValues: {
  //           'uid': newUser.id.toString(),
  //         },
  //       ))
  //           .first
  //           .first;

  //       await connection.query(
  //         'insert into usernames(username, history_id) values (@u, @hid)',
  //         substitutionValues: {
  //           'u': oldUser.username,
  //           'hid': historyId,
  //         },
  //       );
  //     }
  //   }
  // });
}

extension ExtendedGuild on IGuild? {
  /// The prefix of this guild.
  String? get prefix => cached[this?.id.toString()]?['prefix'];

  /// The language of this guild
  String? get language => cached[this?.id.toString()]?['language'];

  StringsEn get slang {
    switch (language) {
      case 'fr':
        return AppLocale.fr.build();
      default:
        return AppLocale.en.build();
    }
  }
}
