package boxup.cli;

import haxe.Exception;
import boxup.cli.definitions.CoreDefinitions.coreDefinitionLoader;
import boxup.cli.loader.*;
import boxup.cli.writer.*;
import boxup.cli.resolver.*;
import boxup.cli.generator.HtmlGenerator;

using Reflect;

class App {
  public static function runWithGenerators(generators) {
    var reporter = new DefaultReporter();
    var resolver = new MultiResolver([
      new FileNameResolver(),
      new StaticResolver('markup') // Fallback
    ]); 
    var manager = new DefinitionManager(
      resolver,
      new MultiLoader([
        new DotBoxupDefintionLoader(Sys.getCwd()),
        coreDefinitionLoader
      ]), 
      reporter
    );
    var app = new App(
      new Compiler(
        reporter,
        new DynamicGenerator(resolver, manager, generators),
        new DynamicValidator(manager)
      ),
      new FileLoader(Sys.getCwd()),
      new FileWriter(Sys.getCwd())
    );

    app.run();
  }

  public static function runDefault() {
    runWithGenerators([
      'markup' => HtmlGenerator.new,
      '*' => HtmlGenerator.new
    ]);
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
