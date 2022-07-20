import 'dart:io';

void main(List<String> args) {
  final files =
      Directory('./lib').listSync(recursive: true).whereType<File>().where(
            (f) => f.path.endsWith('.descs.part.g.dart'),
          );
  final sb = StringBuffer();
  for (final file in files) {
    final content = file.readAsStringSync();
    sb.write(content);

    file.deleteSync();
  }

  final f = File('./lib/descriptions.g.dart');
  // Yes, this is ugly
  if (f.existsSync()) {
    f.deleteSync();
  }

  f.writeAsStringSync(sb.toString());
}
