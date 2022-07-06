import 'package:nyxx_commands/nyxx_commands.dart';

Converter<List<String>> listStringConverter = Converter<List<String>>(
    (view, ctx) => view.buffer.split(' ').skip(1).toList());
