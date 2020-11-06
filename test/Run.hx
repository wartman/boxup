import boxup.internal.Source;
import boxup.internal.ParserException;
import boxup.internal.AstParser;

// import boxup.Parser;
// import boxup.cli.Compiler;
// import boxup.cli.App;
// import boxup.cli.FileLoader;
// import boxup.cli.FileWriter;
// import boxup.cli.DefaultReporter;

// class Run {
//   static function main() {
//     var app = new App(new Compiler(
//       new Parser<Comic, Page>(),
//       new HtmlGenerator(),
//       new FileLoader(Sys.getCwd()),
//       new FileWriter(Sys.getCwd()),
//       new DefaultReporter()
//     ));
//     app.run();
//   }
// }

class Run {
  static function main() {
    var source:Source = {
      filename: 'test',
      content: '
[@block Note]
  [@property title type=String]

[@block Code]
  [@property language type=String]
  [@text content canBeInline=true]

[@block Paragraph]
  [@text text]
  [@block Link]
    [@property href type=String]
    [@text label]
  [@block Emphasis]
    [@text text]

[Note]
  title = Foo

This should parse!
'
    }
    try {
      var nodes = new AstParser(source).parse();
      trace(nodes);
    } catch (e:ParserException) {
      report(e, source);
    }
  }

  static function report(e:ParserException, source:Source) {
    // todo: visual error reporting! Generate some user-friendly
    //       messages too.
    Sys.println('ERROR: ${e.pos.file} [${e.pos.min}]');
    Sys.println('    ${e.message}');

    var pos = e.pos;
    var content = source.content;
    var start = if (pos.min > 50) pos.min - 50 else 0;
    var before = content.substring(start, pos.min);
    var err = content.substring(pos.min, pos.max);
    var after = content.substring(pos.max, pos.max + 50);
    
    Sys.println(before + '->' + err + after);
  }
}