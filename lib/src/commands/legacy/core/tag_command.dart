import 'package:kiwiibot_dart/src/models/tag.dart';
import 'package:kiwiibot_dart/src/services/tag.dart';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx_commands/nyxx_commands.dart';
import 'package:nyxx_interactions/nyxx_interactions.dart';

/// Test
final tagCommand = ChatCommand.textOnly(
  'tag',
  'a',
  id('tag', (IChatContext ctx, Tag tag) async {
    return ctx is MessageChatContext
        ? await ctx.respond(
            MessageBuilder.content(tag.content),
            mention: false,
          )
        : await ctx.respond(
            MessageBuilder.content(tag.content),
          );
  }),
  aliases: ['t'],
  children: [
    ChatCommand(
      'create',
      'Creates a new tag',
      id(
        'tag-create',
        (
          IChatContext ctx,
          @Name('name', {Locale.french: 'nom'})
          @Description('The name of this tag', {
            Locale.french: 'Le nom de ce tag'
          })
              String name,
          @Name('content', {Locale.french: 'contenu'})
          @Description('The content of this tag', {
            Locale.french: 'Le contenu de ce tag'
          })
              List<String> content,
        ) async {
          if (TagService().getByName(ctx.guild?.id ?? Snowflake.zero(), name) !=
              null) {
            return await ctx.respond(
              MessageBuilder.embed(
                EmbedBuilder()
                  ..color = DiscordColor.red
                  ..title = 'Couldn\'t create tag'
                  ..description = 'A tag with that name already exists.',
              ),
            );
          }

          final enabled = await ctx.getConfirmation(
            MessageBuilder.content('Whether to enable the tag by default.'),
          );

          final tag = Tag(
            name: name,
            content: content.join(' '),
            enabled: enabled,
            guildId: ctx.guild?.id ?? Snowflake.zero(),
            authorId: ctx.user.id,
          );

          await TagService().createTag(tag);
          return await ctx
              .respond(MessageBuilder.content('Tag created successfully'));
        },
      ),
    ),
  ],
);
