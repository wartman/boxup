package boxup.reporter;

import sys.io.File;

using StringTools;
using Lambda;
using sys.FileSystem;
using boxup.reporter.TokenTools;
using boxup.stream.StreamTools;

// Todo: make the loading of sources more flexible
class VisualReporter implements Reporter {
  final print:(str:String)->Void;

  public function new(?print) {
    this.print = print == null
      ? Sys.println
      : print;
  }

  public function report(errors:ErrorCollection) {
    for (e in errors) reportError(e);
  }

  function reportError(e:Error) {
    if (!e.pos.file.exists()) {
      return handle(e, [], Source.none());
    }

    var scanner = new Scanner();
    var source = new Source(e.pos.file, File.getContent(e.pos.file));
    scanner.output.finish(tokens -> handle(e, tokens, source));
    scanner.write(source);
  }

  function handle(e:Error, tokens:Array<Token>, source:Source) {
    var pos = e.pos;

    if ((pos.min == 0 && pos.max == 0) || source.filename == Source.unknown) {
      print('ERROR: ${pos.file}:1 [${pos.min} ${pos.max}]');
      print('');
      print(e.message);
      print('');
      return;
    }

    var len = pos.max - pos.min;
    var line = tokens.getLineAt(pos.min);
    var relativePos = tokens.getPosRelativeToNewline(pos);
    
    print('ERROR: ${pos.file}:${line.line} [${pos.min} ${pos.max}]');
    print('');
    print(e.message);
    print('');
    
    if (line.line > 1) printLine(source, tokens, line.line - 1);
    printLine(source, tokens, line.line);
    print(repeat(3) + '| ' + repeat(relativePos.min) + repeat(len, '^'));
    printLine(source, tokens, line.line + 1);

    print('');
  }

  function printLine(source:Source, tokens:Array<Token>, number:Int) {
    var line = tokens.getLine(number);
    if (line != null) {
      var content = source.content.substring(line.pos.min, line.pos.max);
      print(formatNumber(line.line) + content);
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
