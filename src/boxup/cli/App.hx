package boxup.cli;

import boxup.Parser;
import boxup.Typer;
import boxup.ParserException;
import haxe.Json;

class App {
  final compiler:Compiler;

  public function new() {
    var loader = new FileLoader(Sys.getCwd());
    var writer = new FileWriter(Sys.getCwd());
    var reporter = new DefaultReporter();
    var types = switch loader.load('.boxrc') {
      case Some(source):
        var boxrc:{ definitions:String } = Json.parse(source.content);
        switch loader.load(boxrc.definitions) {
          case Some(source): 
            try {
              var nodes = new Parser(source).parse();
              Typer.extractTypes(nodes);
            } catch (e:ParserException) {
              reporter.report(e, source);
              Sys.exit(1);
              null;
            }
          case None: null;
        }
      case None: null; // todo: provide some default types?
    }
    this.compiler = new Compiler(
      new Typer(types),
      loader,
      writer,
      reporter
    );
  }

  public function run() {
    switch Sys.args() {
      case [ src, dst ]:
        compiler.run(src, dst);
      default:
        Sys.println('Usage: [src] [dst]');
        Sys.exit(1);
    }
  }
}
