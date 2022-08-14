import 'dart:io';

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:kiwiibot_dart/src/utils/generator/generate_descriptions.dart';
import 'package:path/path.dart';
import 'package:source_gen/source_gen.dart';

// generateSource(String inPath, String outPath) async {
//   final dir = Directory(inPath);
//   final files = dir.listSync(recursive: true).whereType<File>().where(
//         (e) => e.path.endsWith('.dart'),
//       );
//   final sb = StringBuffer('''
// // Generated file - Do not edit

// const sourceFilesInfos = <String, Map<String, String>>{
// ''');
//   for (final file in files) {
//     final ast = parseFile(
//         path: absolute(normalize(file.path)),
//         featureSet: FeatureSet.latestLanguageVersion());
//     final decl = ast.unit.declarations.first;
//     // final
//     sb.write('''
//   '${decl.firstTokenAfterCommentAndMetadata.next.toString().split('Command').first}': {
//     'lines': '$linesFrom-$linesTo',
//     'path': '${posix.normalize(file.path).replaceAll(r'\', '/') /* Why the heck i must do this?? */}',
//   },
// ''');
//   }

//   sb.write('};');

//   await File(outPath).writeAsString(sb.toString());
// }

Builder generateSources(BuilderOptions options) =>
    LibraryBuilder(SourceGenerator(),
        generatedExtension: '.sources.part.g.dart');

class SourceGenerator extends Generator {
  @override
  String generate(LibraryReader library, BuildStep buildStep) {
    final sb =
        StringBuffer('const sourceFilesInfos = <String, Map<String, String>>{');
    final commands = getCommands(library);
    for (final command in commands) {
      if (command.variable.documentationComment == null) {
        continue;
      }
      final unit =
          ((command as dynamic).enclosingUnit as CompilationUnitElement);
      final session = command.session;
      final parsed = session?.getParsedLibraryByElement(command.library);
      final el = (parsed as ParsedLibraryResult?)
          ?.getElementDeclaration(command.variable);
      final node = el?.node;
      if (node == null) continue;
      // Include comments too, as it is part of the command.
      final beginLine = unit.lineInfo.getLocation(node.beginToken.charOffset -
          command.variable.documentationComment!.length);
      final endLine = unit.lineInfo.getLocation(node.endToken.charOffset);
      final source = command.declaration.source.fullName
          .split('/kiwiibot_dart')
          .last
          .substring(1);
      final name =
          command.declaration.source.shortName.split('_command.dart').first;
      sb.write('''
  '$name': {
    'lines': '${beginLine.lineNumber}-${endLine.lineNumber}',
    'path': '$source',
  },
''');
    }

    sb.write('};');

    return sb.toString();
  }
}
