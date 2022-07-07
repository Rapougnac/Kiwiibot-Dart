import 'package:nyxx_commands/nyxx_commands.dart';


final guildCheck = Check((ctx) => ctx.guild != null, 'guildCheck', false);