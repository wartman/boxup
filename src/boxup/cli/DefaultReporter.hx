package boxup.cli;

using StringTools;

class DefaultReporter implements Reporter {
  public function new() {}

  public function report(errors:Array<Error>, source:Source) {
    for (e in errors) reportError(e, source);
  }

  function reportError(e:Error, source:Source) {
    var pos = e.pos;
    
    Sys.println('ERROR: ${pos.file}');
    Sys.println('');

    Sys.println(e.message);
    Sys.println('');

    if (pos.min == 0 && pos.max == 0) {
      return;
    }

    var content = source.fixLineEndings().content;
    var lineStart = findNewlineBefore(content, pos.min) + 1;
    var indent = pos.min - lineStart;
    var len = pos.max - pos.min;
    var padding = '   |  ' + [ for (_ in 0...(indent-1)) ' ' ].join('');
    var err = padding + [ for (_ in 0...len) '^' ].join('');

    if (lineStart > 1) Sys.println(formatLine(content, findNewlineBefore(content, pos.min) - 1));
    Sys.println(formatLine(content, pos.min));
    Sys.println(err);
    
    if (pos.max < (content.length - 1)) Sys.println(formatLine(content, findNewlineAfter(content, pos.max) + 1));
    Sys.println('');
  }

  function formatLine(content:String, index:Int) {
    var start = findNewlineBefore(content, index);
    var end = findNewlineAfter(content, index);
    var lineNumber:Int = 1;
    if (start != 0) {
      var pos = 0;
      while (pos < start && lineNumber < 5000) {
        lineNumber++;
        pos = findNewlineAfter(content, pos + 1);
      }
    }
    var text = content.substring(start, end).replace('\n', '');
    return formatNumber(lineNumber) + text;
  }

  function formatNumber(lineNumber:Int) {
    var num = Std.string(lineNumber);
    var toAdd = 3 - num.length;
    return [ for (_ in 0...(toAdd - 1)) ' ' ].join('') + '$num | ';
  }

  function findNewlineBefore(content:String, pos:Int):Int {
    if (content.charAt(pos) == '\n') return pos;
    if (pos == 0) return 0;
    return findNewlineBefore(content, pos - 1);
  }

  function findNewlineAfter(content:String, pos:Int):Int {
    if (pos == content.length - 1) return content.length - 1;
    if (content.charAt(pos) == '\n') return pos;
    return findNewlineAfter(content, pos + 1);
  }
}
