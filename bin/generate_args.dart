import 'package:kiwiibot_dart/src/utils/generator/generate_args.dart';

void main(List<String> args) async {
  await generateArgs('./bin/kiwiibot_dart.dart', './lib/args.g.dart');
}
