package boxup.cli;

import haxe.ds.Option;
import boxup.internal.Typer;
import boxup.internal.AstParser;
import boxup.internal.ParserException;
import boxup.internal.Source;

using haxe.io.Path;

class Compiler {
  final typer:Typer;
  final loader:Loader;
  final writer:Writer;
  final reporter:Reporter;

  public function new(typer, loader, writer, reporter) {
    this.typer = typer;
    this.loader = loader;
    this.writer = writer;
    this.reporter = reporter;
  }

  public function run(src:String, dst:String) {
    switch loader.load(src) {
      case None:
        Sys.println('File does not exist: ${src}');
        Sys.exit(1);
      case Some(source): switch compile(source) {
        case None:
          Sys.exit(1);
        case Some(output):
          writer.write(dst, output);
      }
    }
  }

  function compile(source:Source):Option<String> {
    try {
      var nodes = new AstParser(source).parse();
      var blocks = typer.type(nodes);
      trace(haxe.Json.stringify(blocks, '  '));
      // todo
      return None;
    } catch (e:ParserException) {
      reporter.report(e, source);
      return None;
    }
  }
}
