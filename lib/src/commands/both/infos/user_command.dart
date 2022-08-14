import 'package:kiwiibot_dart/src/db/connection.dart';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx_commands/nyxx_commands.dart';

/// Tells you informations about you. That's all. Bruh
// final userCommand = ChatCommand('userinfo', 'aa', (IContext ctx) async {
//   final usernames = await connection.mappedResultsQuery(
//     'select us.username, us.created_at from users u inner join history h on u.history_id = h.id inner join usernames us on us.history_id = h.id where u.user_id = @uid;',
//     substitutionValues: {
//       'uid': ctx.user.id.toString(),
//     },
//   );
//   usernames.sort(((a, b) =>
//       (b['usernames']!['created_at'] as DateTime).compareTo(a['usernames']!['created_at'] as DateTime)));
//   final embed = EmbedBuilder()
//     ..color = DiscordColor.aquamarine
//     ..addField(
//       name: 'Old usernames',
//       content: usernames.map((e) => e['usernames']!['username']).join(','),
//     );
//   return await ctx.respond(MessageBuilder.embed(embed));
// });
