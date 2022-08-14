import 'package:fuzzy/fuzzy.dart';
import 'package:kiwiibot_dart/src/models/tag.dart';
import 'package:kiwiibot_dart/src/setup/setup.dart';
import 'package:nyxx/nyxx.dart';
import 'package:supabase/supabase.dart';

class TagService {
  static TagService? get instance => _instance;
  static TagService? _instance;

  final List<Tag> tags = [];

  TagService._() {
    supabase.from('tag').select().execute().then((t) {
      final data = t.data;
      final tags = data.map((d) => Tag.fromDbRes(d)).toList().cast<Tag>();
      this.tags.addAll(tags);
    });
  }

  factory TagService() {
    if (instance != null) {
      return instance!;
    } else {
      return (_instance = TagService._());
    }
  }

  Iterable<Tag> getGuildTags(Snowflake guildId) =>
      tags.where((tag) => tag.guildId == guildId && tag.enabled);

  Iterable<Tag> getOwnedTags(Snowflake guildId, Snowflake userId) =>
      tags.where((tag) => tag.guildId == guildId && tag.authorId == userId);

  Tag? getByName(Snowflake guildId, String name) => tags
      .where((t) => t.guildId == guildId && t.name == name)
      .cast<Tag?>()
      .followedBy([null]).first;
  Tag? getById(int id) =>
      tags.where((t) => t.id == id).cast<Tag?>().followedBy([null]).first;

  Iterable<Tag> search(String query, Snowflake guildId, [Snowflake? userId]) {
    Iterable<Tag> allTags;

    if (userId == null) {
      allTags = getGuildTags(guildId);
    } else {
      allTags = getOwnedTags(guildId, userId);
    }

    final results = Fuzzy<Tag>(
      allTags.toList(),
      options: FuzzyOptions(
        keys: [
          WeightedKey(
            name: 'name',
            getter: (tag) => tag.name,
            weight: 5,
          ),
          WeightedKey(
            name: 'content',
            getter: (tag) => tag.content,
            weight: 1,
          ),
        ],
      ),
    ).search(query);

    return results.map((result) => result.item);
  }

  Future<Tag> createTag(Tag tag) async {
    if (tag.id != null) {
      return tag;
    }
    final res = await supabase.from('tag').insert({
      'content': tag.content,
      'title': tag.name,
      'creator': tag.authorId.toString(),
      'enabled': tag.enabled,
      'guildId': tag.guildId.toString(),
    }).execute();

    tag.id = res.data.first['id'];

    tags.add(tag);

    return tag;
  }

  Future<Tag> updateTag(Tag tag) async {
    if (tag.id == null) {
      return createTag(tag);
    }

    final res = await supabase
        .from('tag')
        .update({
          'content': tag.content,
          'title': tag.name,
          'creator': tag.authorId.toString(),
          'enabled': tag.enabled,
          'guildId': tag.guildId.toString(),
        })
        .eq('id', tag.id!)
        .execute();

    final updated = Tag.fromDbRes(res.data.first as Map<String, dynamic>);
    tags.removeWhere((t) => t.id == tag.id);
    tags.add(updated);

    return updated;
  }

  Future<void> deleteTag(Tag tag) async {
    final id = tag.id;

    if (id == null) {
      return;
    }

    await supabase.from('tag').delete().eq('id', id).execute();

    tags.removeWhere((t) => t.id == id);
  }
}
