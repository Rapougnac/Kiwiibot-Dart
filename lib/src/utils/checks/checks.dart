import 'package:nyxx/nyxx.dart';
import 'package:nyxx_commands/nyxx_commands.dart';

final guildCheck = Check((ctx) => ctx.guild != null, 'guildCheck', false);

final connectedToAVoiceChannelCheck = Check((IContext context) async {
  final selfMember = await context.guild!.selfMember.getOrDownload();

  if (selfMember.voiceState == null || selfMember.voiceState!.channel == null) {
    return false;
  }
  return true;
}, 'voiceConnectedToVocal');

final notConnectedToAVoiceChannelCheck = Check((IContext context) async {
  final selfMember = await context.guild!.selfMember.getOrDownload();

  if (selfMember.voiceState == null || selfMember.voiceState!.channel == null) {
    return true;
  }
  return false;
}, 'voiceNotConnectedToVocal');

final userConnectedToVoiceChannelCheck = Check((IContext context) {
  final memberVoiceState = context.member!.voiceState;

  if (memberVoiceState == null || memberVoiceState.channel == null) {
    return false;
  }
  return true;
}, 'voiceUserConnectedToVocal');

final sameVoiceChannelOrDisconnectedCheck = Check((IContext context) async {
  // If this is an interaction, acknowledge it just in case the check
  // takes too long to run.
  if (context is InteractionChatContext) {
    await context.acknowledge();
  }

  final selfMemberVoiceState =
      (await context.guild!.selfMember.getOrDownload()).voiceState;
  // The upper check should be executed before, so its okay to assume the voice
  // state exists.
  final memberVoiceState = context.member!.voiceState!;

  if (selfMemberVoiceState == null || selfMemberVoiceState.channel == null) {
    return true;
  }

  if (selfMemberVoiceState.channel!.id != memberVoiceState.channel!.id) {
    return false;
  }
  return true;
}, 'voiceSameVocal');
