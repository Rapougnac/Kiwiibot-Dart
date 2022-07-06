import 'dart:io';

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:kiwiibot_dart/src/utils/parse_doc.dart';
import 'package:path/path.dart';
import 'package:pub_semver/pub_semver.dart';

Future<void> generate(String inPath, String outPath) async {
  final directory = Directory(inPath);
  final fse = await directory.list(recursive: true).toList();
  final files = fse.whereType<File>();
  final filtered = files.where((e) => e.path.endsWith('.dart'));
  final sb = StringBuffer('''
// AUTO-GENERATED FILE
// DO NOT EDIT.

// This file was generated at ${DateTime.now()}

''');
  for (final file in filtered) {
    final ast = parseFile(
      path: normalize(absolute(file.path)),
      featureSet: FeatureSet.fromEnableFlags2(
        sdkLanguageVersion: Version(2, 17, 3),
        flags: [],
      ),
    );

    final unit = ast.unit;
    final f = unit.declarations.firstWhere(
      (d) {
        final declaration = d.childEntities.firstWhere(
          (c) {
            return c is VariableDeclarationList;
          },
        ) as VariableDeclarationList;
        var isOneOfGoodType = false;
        final containsListTypes = [
          'ChatCommand',
          'UserCommand',
          'MessageCommand'
        ];
        // This is so ugly :(
        if (declaration.type != null) {
          isOneOfGoodType =
              containsListTypes.contains(declaration.type!.toSource());
        } else if (declaration.isFinal) {
          final semanticType = declaration
              .toString()
              .split('=')
              [1]
              .trimLeft()
              .split('(')
              .first;
          isOneOfGoodType = containsListTypes.contains(semanticType);
        }
        return isOneOfGoodType;
      },
    );
    final comments = f.documentationComment!.tokens.map((comment) {
      final parsed = stripComments(comment.toString());
      return parsed;
    }).join('\n');

    sb.write('''
const ${f.firstTokenAfterCommentAndMetadata.next}Description = \'\'\'
${comments.replaceAll('\'', '\\\'')}
\'\'\';
''');
  }

  await File(outPath).writeAsString(sb.toString());
}
