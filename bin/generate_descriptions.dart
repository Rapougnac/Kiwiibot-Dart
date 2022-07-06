import 'package:kiwiibot_dart/kiwiibot_dart.dart' as kiwiibot_dart;

void main(List<String> arguments) {
  kiwiibot_dart.generate('./lib/src/commands', './lib/descriptions.g.dart');
}
