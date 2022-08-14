import 'package:kiwiibot_dart/src/models/tag.dart';
import 'package:kiwiibot_dart/src/services/tag.dart';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx_commands/nyxx_commands.dart';
import 'package:nyxx_interactions/nyxx_interactions.dart';

final tagConverter = Converter<Tag>(
  ((view, context) => TagService()
      .search(view.getQuotedWord(), context.guild?.id ?? Snowflake.zero())
      .cast<Tag?>()
      .followedBy([null]).first),
  autocompleteCallback: (context) => TagService()
      .search(context.currentValue, context.guild?.id ?? Snowflake.zero())
      .take(25)
      .map((e) => e.name)
      .map(
        (e) => ArgChoiceBuilder(e, e),
      ),
);
