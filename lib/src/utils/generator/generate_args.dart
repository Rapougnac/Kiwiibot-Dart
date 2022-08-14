import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context.dart';
import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:kiwiibot_dart/src/utils/generator/visitor/element_tree_visitor.dart';
import 'package:path/path.dart';

Future<void> generateArgs(String inPath, final String outPath) async {
  final sb = StringBuffer('''
// GENERATED FILE
//
// DO NOT EDIT
// 
// Generated at ${DateTime.now()}

import './descriptions.g.dart';

const generatedArgs = <String, Map<String, String>>{
''');
  inPath = absolute(normalize(inPath));
  final collection = AnalysisContextCollection(includedPaths: [inPath]);

  final context = collection.contextFor(inPath);
  final session = context.currentSession;

  final library = await session.getResolvedLibrary(inPath);

  if (library is! ResolvedLibraryResult) {
    throw Exception('This is not a library result');
  }

  final functionBuilder = FunctionBuilderVisitor(context, false);
  await functionBuilder.visitLibrary(library.element);

  for (final id in functionBuilder.ids) {
    final parameterList =
        (id.argumentList.arguments[1] as FunctionExpression).parameters!;

    final List<String> stringParams = [];

    for (final param in parameterList.parameters.skip(1)) {
      if (param.childEntities.first is SimpleFormalParameter ||
          param is SimpleFormalParameter) {
        final resolvedParam = param is SimpleFormalParameter
            ? param
            : (param.childEntities.first as SimpleFormalParameter);

        late String identifier;

        final isTypeNotNull =
            resolvedParam.type != null && resolvedParam.type!.type != null;

        if (isTypeNotNull && resolvedParam.type!.type!.isDartCoreList) {
          identifier = '...${resolvedParam.identifier}';
        } else {
          identifier = resolvedParam.identifier.toString();
        }

        final str = param.isOptional ? '<$identifier>' : '[$identifier]';
        stringParams.add(str);
      }
    }
    sb.write('''
  ${id.argumentList.arguments.first.toString()}: {
    'args': '${stringParams.join(' ')}',
    'description': ${id.argumentList.arguments.first.toString().split('\'').join().replaceAll('-', '')}CommandDescription,
  },
''');
  }

  sb.write('};');

  await File(outPath).writeAsString(sb.toString());
}

class FunctionBuilderVisitor extends EntireAstVisitor {
  final List<InvocationExpression> ids = [];

  FunctionBuilderVisitor(AnalysisContext context, bool slow)
      : super(context, slow);

  @override
  void visitMethodInvocation(MethodInvocation node) {
    super.visitMethodInvocation(node);

    Expression function = node.function;

    if (function is Identifier &&
        function.staticElement?.location?.encoding ==
            'package:nyxx_commands/src/util/util.dart;package:nyxx_commands/src/util/util.dart;id') {
      ids.add(node);
    }
  }
}
