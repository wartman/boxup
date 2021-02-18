package boxup.cli;

import haxe.Json;
import haxe.ds.Option;

using Reflect;

class App {
  public static function createFromBoxuprc(generator, loader:Loader, writer:Writer, reporter:Reporter):Option<App> {
    var defLoader = new DefinitionLoader(loader, reporter);
    return switch loader.load('.boxuprc') {
      case Some(source):
        var json:Dynamic = Json.parse(source.content);
        var path = json.field('definition');

        switch defLoader.load(path) {
          case Some(def): 
            Some(new App(new Compiler(
              def,
              generator,
              loader,
              writer,
              reporter
            )));
          case None: None;
        }
      case None: None;
    }
  }
  
  final compiler:Compiler;

  public function new(compiler) {
    this.compiler = compiler;
  }

  public function run() {
    switch Sys.args() {
      case [ src, dst ]:
        try {
          compiler.run(src, dst);
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
}
