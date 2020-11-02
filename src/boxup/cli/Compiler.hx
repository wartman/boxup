package boxup.cli;

import haxe.ds.Option;
import boxup.Parser;
import boxup.internal.AstParser;
import boxup.internal.ParserException;
import boxup.internal.Source;

using haxe.io.Path;

class Compiler {
  final parser:ParserBase;
  final generator:Generator<String>;
  final loader:Loader;
  final writer:Writer;
  final reporter:Reporter;

  public function new(parser, generator, loader, writer, reporter) {
    this.parser = parser;
    this.generator = generator;
    this.loader = loader;
    this.writer = writer;
    this.reporter = reporter;
  }

  public function run(src:String, dst:String) {
    switch loader.load(src) {
      case None:
        Sys.println('File does note exist: ${src}');
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
      var blocks = parser.parseSource(source);
      return Some(generator.generateString(blocks));
    } catch (e:ParserException) {
      reporter.report(e, source);
      return None;
    }
  }
}
