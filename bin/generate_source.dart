import 'package:kiwiibot_dart/src/utils/generator/generate_source.dart';

void main(List<String> args) async {
  await generateSources('lib/src/commands', 'lib/sources.g.dart');
}
