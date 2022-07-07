import 'dart:async';
import 'dart:convert';

import 'package:kiwiibot_dart/src/utils/checks/guild_check.dart';
import 'package:kiwiibot_dart/descriptions.g.dart';
import 'package:args/args.dart';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx_commands/nyxx_commands.dart';

/// Mass ban multiple members from this server.
///
/// This command has a "command line" syntax.
///
/// `--reason` or `-r`: The reason for the ban.
/// `--regex` or `-R`: The regex the user's username must match. None flags are enabled.
/// `--[no-]show` or `-s`: Shows the members that will be bent instead of directly ban them.
/// `--no-avatar`: Matches members if they has a default profile picture given by Discord.
/// `--no-roles`: Matches members that have no roles.
/// `--[no-]bot`: Allows you to ban bots, `false` by default.
///
/// If no arguments (unless `reason`) are provided, then all members that are not bots will be banned.
/// Unless the bot has no permission to ban you.
final massbanCommand = ChatCommand.textOnly(
  'massban',
  massbanCommandDescription,
  id('massban', (MessageChatContext ctx, [List<String> args = const []]) async {
    final parser = ArgParser()
      ..addOption('reason', abbr: 'r', mandatory: true)
      ..addOption('regex', abbr: 'R')
      ..addFlag('show', abbr: 's', defaultsTo: false)
      ..addFlag('no-avatar', defaultsTo: false, negatable: false)
      ..addFlag('no-roles', defaultsTo: false, negatable: false)
      ..addFlag('bot', defaultsTo: false);

    late ArgResults result;

    try {
      result = parser.parse(args);
    } on FormatException catch (e) {
      return await ctx.respond(
        MessageBuilder.content('There was an error while parsing the args; $e'),
      );
    }

    // defaultAvatar(int discriminator) => '${Constants.cdnUrl}/embed/avatars/${discriminator % 5}.png';

    if (ctx.guild!.members.isEmpty) {
      ctx.guild!.requestChunking();
    }

    final predicatesUser = [
      (IUser u) => u.formattedDiscriminator != '0000',
      if (!result['bot']) (IUser u) => !u.bot,
    ];

    final predicatesMember = <bool Function(IMember)>[];

    RegExp? regExp;

    if (result['regex'] != null) {
      try {
        regExp = RegExp(result['regex'] as String);
      } on FormatException catch (e) {
        return await ctx.respond(
          MessageBuilder.content('Invalid regex passed to `--regex|-R`: $e'),
        );
      } finally {
        predicatesUser.add((u) => regExp!.hasMatch(u.username));
      }
    }

    if (result['no-avatar']) {
      predicatesUser.add((u) => u.avatar == null);
    }

    if (result['no-roles']) {
      predicatesMember.add((m) => m.roles.isEmpty);
    }

    final membersFound = [
      // This seems overcomplicated..
      await for (final u in Stream<IUser>.fromFutures(
        ctx.guild!.members.values.map(
          (m) => Future(() => m.user.getOrDownload()),
        ),
      ))
        if (predicatesUser.every(
              (p) => p(u),
            ) &&
            predicatesMember.every(
              (p) => p(
                ctx.guild!.members[u.id]!,
              ),
            ))
          ctx.guild!.members[u.id]!
    ];

    if (result['show'] as bool) {
      membersFound.sort((a, b) => a.joinedAt.compareTo(b.joinedAt));
      IUser u;
      final str = [
        for (final m in membersFound)
          '${m.id}\tJoined: ${m.joinedAt}\tCreated: ${m.createdAt}\t${(u = await m.user.getOrDownload()).bot ? '[BOT] ' : ''}${u.username}'
      ].join('\n');
      final content =
          'Current time: ${DateTime.now().toUtc()}\nTotal members found: ${membersFound.length}\n\n$str';
      final attachment =
          AttachmentBuilder.bytes(utf8.encode(content), 'members.txt');
      return await ctx.respond(MessageBuilder.files([attachment]));
    }

    final condition = await ctx.getConfirmation(
      MessageBuilder.content(
          'This will ban **${membersFound.length} member${membersFound.length == 1 ? '' : 's'}**\nAre you sure?'),
    );

    if (!condition) {
      return await ctx.channel.sendMessage(
        MessageBuilder.content('The operation was cancelled'),
      );
    }

    var count = 0;

    for (final member in membersFound) {
      try {
        await ctx.guild!.ban(member, auditReason: result['reason']);
        count++;
      } on IHttpResponseError {
        continue;
      }
    }

    return await ctx.respond(
      MessageBuilder.content(
        'Banned $count/${membersFound.length} member${membersFound.length == 1 ? '' : 's'}',
      ),
    );
  }),
  checks: [
    guildCheck,
    PermissionsCheck(
      PermissionsConstants.banMembers,
      requiresAll: false,
      name: 'permissionsCheck',
      allowsDm: false,
      allowsOverrides: false,
    )
  ],
);
