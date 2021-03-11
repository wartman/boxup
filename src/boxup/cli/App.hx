package boxup.cli;

import haxe.Json;
import haxe.Exception;
import boxup.cli.generator.HtmlGenerator;
import boxup.cli.definitions.CoreDefinitions.coreDefinitionLoader;

using Reflect;

class App {
  public static function runUsingEnv(factory:(defintion:Definition)->Generator<String>, loader:Loader, writer:Writer, reporter:Reporter) {
    var defLoader = new DefinitionCompiler(loader, reporter);
    return switch loader.load('.boxuprc') {
      case Some(source):
        var json:Dynamic = Json.parse(source.content);
        var path = json.field('definition');

        switch defLoader.load(path) {
          case Some(def): 
            var app = new App(
              new Compiler(reporter, factory(def), def),
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
  
  public static function runDefault() {
    var reporter = new DefaultReporter();
    var compiler = new DefinitionCompiler(coreDefinitionLoader, reporter);
    switch compiler.load('markup') {
      case Some(def):
        var app = new App(
          new Compiler(reporter, new HtmlGenerator(def), def),
          new FileLoader(Sys.getCwd()),
          new FileWriter(Sys.getCwd())
        );
        app.run();
      case None:
        Sys.println('Could not load the markup.definition resource');
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
