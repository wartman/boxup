package boxup.cli;

import haxe.Json;
import haxe.Exception;

using Reflect;

class App {
  public static function runUsingEnv(generator, loader:Loader, writer:Writer, reporter:Reporter) {
    var defLoader = new DefinitionLoader(loader, reporter);
    return switch loader.load('.boxuprc') {
      case Some(source):
        var json:Dynamic = Json.parse(source.content);
        var path = json.field('definition');

        switch defLoader.load(path) {
          case Some(def): 
            var app = new App(
              new Compiler(reporter, generator, def),
              loader,
              writer
            );
            app.run();
          case None:
            Sys.println('Failed to load a definition file at ${path}');
            Sys.println('It either does not exist or is invalid.');
            Sys.exit(1);
        }
      case None:
        Sys.println('Failed to find .boxuprc');
        Sys.exit(1);
    }
  }
  
  final compiler:Compiler<String>;
  final loader:Loader;
  final writer:Writer;

  public function new(compiler, loader, writer) {
    this.compiler = compiler;
    this.loader = loader;
    this.writer = writer;
  }

  public function run() {
    switch Sys.args() {
      case [ src, dst ]:
        try {
          compile(src, dst);
          Sys.exit(0);
        } catch (e) {
          Sys.println(e.message);
          Sys.exit(1);
        }
      default:
        Sys.println('Usage: [src] [dst]');
        Sys.exit(1);
    }
  }

  function compile(src:String, dst:String) {
    switch loader.load(src) {
      case None:
        throw new Exception('File does not exist: ${src}');
      case Some(source): switch compiler.compile(source) {
        case None:
          throw new Exception('Failed to compile');
        case Some(output):
          writer.write(dst, output);
      }
    }
  }
}
