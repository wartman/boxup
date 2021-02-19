package boxup.cli;

import haxe.ds.Option;

class DefinitionLoader {
  final compiler:Compiler<Definition>;
  final loader:Loader;
  final reporter:Reporter;

  public function new(loader, reporter) {
    this.loader = loader;
    this.reporter = reporter;
    this.compiler = new Compiler(
      reporter,
      new DefinitionGenerator(),
      new DefinitionValidator()
    );
  }

  public function load(path:String):Option<Definition> {
    return switch loader.load(path) {
      case Some(source): 
        compiler.compile(source);
      case None:
        reporter.report([
          new Error('File not found: ${path}', {
            min: 0,
            max: 0,
            file: path
          })
        ], { filename: path, content: '' });
        None;
    }
  }
}
