import 'dart:developer';
import 'dart:io';

void main(List<String> args) async {
  final files = Directory('./lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((e) => e.path.endsWith('.sources.part.g.dart'));
  final sb =
      StringBuffer('const sourceFilesInfos = <String, Map<String, String>>{');
  for (final file in files) {
    final content = file.readAsStringSync();
    final parsedFirst = content.split('>>').last;
    var finalContent = parsedFirst.substring(1);
    finalContent = finalContent.substring(0, finalContent.length - 4);
    sb.write(finalContent);
    file.deleteSync();
  }

  sb.write('};');
  File('./lib/sources.g.dart').writeAsStringSync(sb.toString());
}
