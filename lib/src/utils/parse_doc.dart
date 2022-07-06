import 'dart:convert' show HtmlEscape;

// TODO: Remove this.
@Deprecated('Not useful anymore')
String parseDoc(String src) {
  return stripComments(stripDartdocCommentsFromSource(src));
}

/// {@ndd}
/// Strpis dart doc comments from the given [source].
String stripDartdocCommentsFromSource(String source) {
  var skipNext = false;
  return source.split('\n').where((String line) {
    line = line.trimLeft();
    var lineComments =
        line.startsWith(_tripleSlash) || line.startsWith(_escapedTripleSlash);
    var blockComments = line.startsWith(_slashStarStar) ||
        line.startsWith(_escapedSlashStarStar);
    final ndd = line.startsWith('$_tripleSlash $_ndd') ||
        line.startsWith('$_escapedTripleSlash $_ndd') ||
        line.startsWith('$_slashStarStar $_ndd') ||
        line.startsWith('$_escapedSlashStarStar $_ndd');

    if (ndd) {
      skipNext = true;
      return false;
    }
    if (!(lineComments || blockComments)) {
      skipNext = false;
    }
    if ((lineComments || blockComments) && skipNext) {
      return false;
    }

    if (lineComments) {
      if (line.startsWith(_tripleSlash) ||
          line.startsWith(_escapedTripleSlash)) {
        return true;
      }
      lineComments = false;
      return false;
    } else if (blockComments) {
      if (line.contains(_starSlash) || line.contains(_escapedStarSlash)) {
        blockComments = false;
        return true;
      }
      if (line.startsWith(_slashStarStar) ||
          line.startsWith(_escapedSlashStarStar)) {
        return true;
      }
      return true;
    }

    return false;
  }).join('\n');
}

const HtmlEscape _escape = HtmlEscape();

const String _tripleSlash = '///';

final String _escapedTripleSlash = _escape.convert(_tripleSlash);

const String _slashStarStar = '/**';

final String _escapedSlashStarStar = _escape.convert(_slashStarStar);

const String _starSlash = '*/';

final String _escapedStarSlash = _escape.convert(_starSlash);

const _ndd = '{@ndd}';

String stripComments(String str) {
  if (str.isEmpty) return '';
  final buf = StringBuffer();

  if (str.startsWith(_tripleSlash)) {
    for (final line in stripCommonWhitespace(str)) {
      if (line.startsWith('$_tripleSlash ')) {
        buf.writeln(line.substring(4));
      } else if (line.startsWith(_tripleSlash)) {
        buf.writeln(line.substring(3));
      } else {
        buf.writeln(line);
      }
    }
  } else {
    var cStyle = false;
    if (str.startsWith(_slashStarStar)) {
      str = str.substring(3);
      cStyle = true;
    }
    if (str.endsWith(_starSlash)) {
      str = str.substring(0, str.length - 2);
    }
    for (final line in stripCommonWhitespace(str)) {
      if (cStyle && line.startsWith('* ')) {
        buf.writeln(line.substring(2));
      } else if (cStyle && line.startsWith('*')) {
        buf.writeln(line.substring(1));
      } else {
        buf.writeln(line);
      }
    }
  }
  return buf.toString().trim();
}

Iterable<String> stripCommonWhitespace(String str) sync* {
  if (str.isEmpty) return;
  final lines = str.split('\n');
  int? minimumSeen;

  for (final line in lines) {
    if (line.isNotEmpty) {
      final match = leadingWhiteSpace.firstMatch(line);
      if (match != null) {
        var groupLength = match.group(1)!.length;
        if (minimumSeen == null || groupLength < minimumSeen) {
          minimumSeen = groupLength;
        }
      }
    }
  }
  minimumSeen ??= 0;
  for (final line in lines) {
    if (line.length >= minimumSeen) {
      yield line.substring(minimumSeen);
    } else {
      yield '';
    }
  }
}

final RegExp leadingWhiteSpace = RegExp(r'^([ \t]*)[^ ]');
