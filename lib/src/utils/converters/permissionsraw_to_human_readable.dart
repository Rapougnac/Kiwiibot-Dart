import 'package:nyxx/nyxx.dart';

/// It takes a raw permissions integer and returns a list of strings that describe the permissions
///
/// Args:
///   [raw] (int): The raw permissions value.
List<String> convertRawPermissionsToReadable(int raw) {
  final permissions = <String>[];

  if (PermissionsUtils.isApplied(raw, PermissionsConstants.addReactions)) {
    permissions.add('Add Reactions');
  } else if (PermissionsUtils.isApplied(
    raw,
    PermissionsConstants.administrator,
  )) {
    permissions.add('Administrator');
  } else if (PermissionsUtils.isApplied(
    raw,
    PermissionsConstants.attachFiles,
  )) {
    permissions.add('Attaching Files');
  } else if (PermissionsUtils.isApplied(
    raw,
    PermissionsConstants.banMembers,
  )) {
    permissions.add('Ban Members');
  } else if (PermissionsUtils.isApplied(
    raw,
    PermissionsConstants.changeNickname,
  )) {
    permissions.add('Change Nickname');
  } else if (PermissionsUtils.isApplied(raw, PermissionsConstants.connect)) {
    permissions.add('Connect');
  } else if (PermissionsUtils.isApplied(
    raw,
    PermissionsConstants.createInstantInvite,
  )) {
    permissions.add('Create Instant Invite');
  } else if (PermissionsUtils.isApplied(
    raw,
    PermissionsConstants.createPrivateThreads,
  )) {
    permissions.add('Create Private Threads');
  } else if (PermissionsUtils.isApplied(
    raw,
    PermissionsConstants.createPublicThreads,
  )) {
    permissions.add('Create Public Threads');
  } else if (PermissionsUtils.isApplied(
    raw,
    PermissionsConstants.deafenMembers,
  )) {
    permissions.add('Deafen Members');
  } else if (PermissionsUtils.isApplied(
    raw,
    PermissionsConstants.embedLinks,
  )) {
    permissions.add('Embed Links');
  } else if (PermissionsUtils.isApplied(
    raw,
    PermissionsConstants.externalEmojis,
  )) {
    permissions.add('Use External Emojis');
  } else if (PermissionsUtils.isApplied(
    raw,
    PermissionsConstants.kickMembers,
  )) {
    permissions.add('Kick Members');
  } else if (PermissionsUtils.isApplied(
    raw,
    PermissionsConstants.manageChannels,
  )) {
    permissions.add('Manage Channels');
  } else if (PermissionsUtils.isApplied(
    raw,
    PermissionsConstants.manageEmojis,
  )) {
    permissions.add('Manage Emojis');
  } else if (PermissionsUtils.isApplied(
    raw,
    PermissionsConstants.manageGuild,
  )) {
    permissions.add('Manage Guild');
  } else if (PermissionsUtils.isApplied(
    raw,
    PermissionsConstants.manageMessages,
  )) {
    permissions.add('Manage Messages');
  } else if (PermissionsUtils.isApplied(
    raw,
    PermissionsConstants.manageNicknames,
  )) {
    permissions.add('Manage Nicknames');
  } else if (PermissionsUtils.isApplied(
    raw,
    PermissionsConstants.manageRolesOrPermissions,
  )) {
    permissions.add('Manage Roles or Permissions');
  } else if (PermissionsUtils.isApplied(
    raw,
    PermissionsConstants.manageThreads,
  )) {
    permissions.add('Manage Threads');
  } else if (PermissionsUtils.isApplied(
    raw,
    PermissionsConstants.manageWebhooks,
  )) {
    permissions.add('Manage Webhooks');
  } else if (PermissionsUtils.isApplied(
    raw,
    PermissionsConstants.mentionEveryone,
  )) {
    permissions.add('Mention Everyone');
  } else if (PermissionsUtils.isApplied(
    raw,
    PermissionsConstants.moveMembers,
  )) {
    permissions.add('Move Members');
  } else if (PermissionsUtils.isApplied(
    raw,
    PermissionsConstants.muteMembers,
  )) {
    permissions.add('Mute Members');
  } else if (PermissionsUtils.isApplied(
    raw,
    PermissionsConstants.prioritySpeaker,
  )) {
    permissions.add('Priority Speaker');
  } else if (PermissionsUtils.isApplied(
    raw,
    PermissionsConstants.readMessageHistory,
  )) {
    permissions.add('Read Message History');
  } else if (PermissionsUtils.isApplied(
    raw,
    PermissionsConstants.requestToSpeak,
  )) {
    permissions.add('Request to Speak');
  } else if (PermissionsUtils.isApplied(
    raw,
    PermissionsConstants.sendMessages,
  )) {
    permissions.add('Send Messages');
  } else if (PermissionsUtils.isApplied(
    raw,
    PermissionsConstants.sendMessagesInThread,
  )) {
    permissions.add('Send Messages in Thread');
  } else if (PermissionsUtils.isApplied(
    raw,
    PermissionsConstants.sendTtsMessages,
  )) {
    permissions.add('Send TTS Messages');
  } else if (PermissionsUtils.isApplied(
    raw,
    PermissionsConstants.speak,
  )) {
    permissions.add('Speak');
  } else if (PermissionsUtils.isApplied(
    raw,
    PermissionsConstants.startEmbeddedActivities,
  )) {
    permissions.add('Start Embedded Activities');
  } else if (PermissionsUtils.isApplied(
    raw,
    PermissionsConstants.stream,
  )) {
    permissions.add('Stream');
  } else if (PermissionsUtils.isApplied(
    raw,
    PermissionsConstants.useExternalStickers,
  )) {
    permissions.add('Use External Stickers');
  } else if (PermissionsUtils.isApplied(
    raw,
    PermissionsConstants.useSlashCommands,
  )) {
    permissions.add('Use Slash Commands');
  } else if (PermissionsUtils.isApplied(
    raw,
    PermissionsConstants.useVad,
  )) {
    permissions.add('Use Voice Activity Detection');
  } else if (PermissionsUtils.isApplied(
    raw,
    PermissionsConstants.viewAuditLog,
  )) {
    permissions.add('View Audit Log');
  } else if (PermissionsUtils.isApplied(
    raw,
    PermissionsConstants.viewChannel,
  )) {
    permissions.add('View Channel');
  } else if (PermissionsUtils.isApplied(
    raw,
    PermissionsConstants.viewGuildInsights,
  )) {
    permissions.add('View Guild Insights');
  }

  return permissions;
}
