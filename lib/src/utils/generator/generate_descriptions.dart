import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:kiwiibot_dart/src/utils/parse_doc.dart';
import 'package:source_gen/source_gen.dart';

Builder generateDocs(BuilderOptions options) => LibraryBuilder(
      CommentGenerator(),
      generatedExtension: '.descs.part.g.dart',
    );

class CommentGenerator extends Generator {
  @override
  String generate(LibraryReader library, BuildStep buildStep) {
    final sb = StringBuffer();
    final commands = getCommands(library);
    for (final command in commands) {
      if (command.variable.documentationComment != null) {
        sb.write('''
const ${command.displayName}Description = \'\'\'
${stripComments(command.variable.documentationComment!).replaceAll('\'', '\\\'')}
\'\'\';

''');
      }
    }

    return sb.toString();
  }
}

const c = ['ChatCommand', 'ChatGroup', 'UserCommand', 'MessageCommand'];

Iterable<PropertyAccessorElement> getCommands(LibraryReader reader) =>
    reader.allElements.whereType<PropertyAccessorElement>().where(
          (el) => c.contains(
            el.type.returnType.element?.displayName ??
                el.type.returnType.toString(),
          ),
        );
