import 'package:nyxx_commands/nyxx_commands.dart';

Future<void> connectIfNeeded(IChatContext context) async {
  final selfMember = await context.guild!.selfMember.getOrDownload();

  if ((selfMember.voiceState == null ||
          selfMember.voiceState!.channel == null) &&
      (context.member!.voiceState != null &&
          context.member!.voiceState!.channel != null)) {
    context.guild!.shard.changeVoiceState(
        context.guild!.id, context.member!.voiceState!.channel!.id);
  }
}
