import 'dart:io';

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:path/path.dart';

generateSources(String inPath, String outPath) async {
  final dir = Directory(inPath);
  final files = dir.listSync(recursive: true).whereType<File>().where(
        (e) => e.path.endsWith('.dart'),
      );
  final sb = StringBuffer('''
// Generated file - Do not edit

const sourceFilesInfos = <String, Map<String, String>>{
''');
  for (final file in files) {
    final ast = parseFile(
        path: absolute(normalize(file.path)),
        featureSet: FeatureSet.latestLanguageVersion());
    final decl = ast.unit.declarations.first;
    final index =
        ast.unit.lineInfo.lineStarts.indexOf(decl.beginToken.charOffset);
    var linesFrom = ast.unit.lineInfo.lineStarts.sublist(0, index).length;
    if (index == 9) {
      linesFrom++;
    } else {
      linesFrom += 2;
    }
    final endIndex = !ast.unit.lineInfo.lineStarts
            .contains(decl.endToken.charOffset + 1)
        ? ast.unit.lineInfo.lineStarts.indexOf(decl.endToken.charOffset - 1)
        : ast.unit.lineInfo.lineStarts.indexOf(decl.endToken.charOffset + 1);
    final linesTo =
        ast.unit.lineInfo.lineStarts.sublist(0, endIndex).length + 1;
    sb.write('''
  '${decl.firstTokenAfterCommentAndMetadata.next.toString().split('Command').first}': {
    'lines': '$linesFrom-$linesTo',
    'path': '${posix.normalize(file.path).replaceAll(r'\', '/')/* Why the heck i must do this?? */}',
  },
''');
  }

  sb.write('};');

  await File(outPath).writeAsString(sb.toString());
}
