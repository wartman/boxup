package boxup.cli;

import haxe.ds.Option;
import boxup.Typer;
import boxup.Parser;
import boxup.ParserException;
import boxup.Source;

using haxe.io.Path;

class Compiler {
  final typer:Typer;
  final loader:Loader;
  final writer:Writer;
  final generator:Generator;
  final reporter:Reporter;

  public function new(typer, loader, writer, generator, reporter) {
    this.typer = typer;
    this.loader = loader;
    this.generator = generator;
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
      var nodes = new Parser(source).parse();
      var blocks = typer.type(nodes);
      return Some(generator.generate(blocks));
    } catch (e:ParserException) {
      reporter.report(e, source);
      return None;
    }
  }
}
