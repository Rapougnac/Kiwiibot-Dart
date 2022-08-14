import 'package:nyxx/nyxx.dart';
import 'package:supabase/supabase.dart';

class Tag {
  /// The id for this tag, `null` if not in the database.
  int? id;

  /// The tag's name.
  final String name;

  /// The tag's content
  final String content;

  /// Whether this tag is enabled.
  bool enabled;

  /// The id of the guild this tag belongs to.
  final Snowflake guildId;

  /// The id of the user this tag belongs to.
  final Snowflake authorId;

  Tag({
    required this.name,
    required this.content,
    required this.enabled,
    required this.guildId,
    required this.authorId,
    this.id,
  });

  factory Tag.fromDbRes(Map<dynamic, dynamic> response) {
    return Tag(
      name: response['title'] as String,
      content: response['content'] as String,
      enabled: response['enabled'] as bool,
      guildId: Snowflake(response['guildId']),
      authorId: Snowflake(response['creator']),
      id: response['id'] as int,
    );
  }
}
