package boxup.cli.reporter;

using StringTools;
using Lambda;

class VisualReporter implements Reporter {
  public function new() {}

  public function report(errors:ErrorCollection, source:Source) {
    for (e in errors) reportError(e, source);
  }

  function reportError(e:Error, source:Source) {
    var pos = e.pos;

    if (pos.min == 0 && pos.max == 0) {
      Sys.println('ERROR: ${pos.file}:1 [${pos.min} ${pos.max}]');
      Sys.println('');
      Sys.println(e.message);
      Sys.println('');
      return;
    }

    var len = pos.max - pos.min;
    var line = source.getLineAt(pos.min);
    var relativePos = source.getPosRelativeToNewline(pos);
    
    Sys.println('ERROR: ${pos.file}:${line.line} [${pos.min} ${pos.max}]');
    Sys.println('');
    Sys.println(e.message);
    Sys.println('');
    
    if (line.line > 1) printLine(source, line.line - 1);
    printLine(source, line.line);
    Sys.println(repeat(3) + '| ' + repeat(relativePos.min) + repeat(len, '^'));
    printLine(source, line.line + 1);

    Sys.println('');
  }

  function printLine(source:Source, number:Int) {
    var line = source.getLine(number);
    if (line != null) {
      var content = source.content.substring(line.pos.min, line.pos.max);
      Sys.println(formatNumber(line.line) + content);
    }
  }

  function formatNumber(lineNumber:Int) {
    var num = Std.string(lineNumber);
    var toAdd = 3 - num.length;
    return [ for (_ in 0...(toAdd - 1)) ' ' ].join('') + '$num | ';
  }

  function repeat(len:Int, value:String = ' ') {
    return [ for (_ in 0...len) value ].join('');
  }
}