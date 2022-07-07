import 'package:nyxx_commands/nyxx_commands.dart';

Converter<List<String>> listStringConverter = Converter<List<String>>(
  (view, ctx) {
    final args = <String>[];
    while (!view.eof) {
      args.add(view.getQuotedWord());
    }
    return args;
  },
);
