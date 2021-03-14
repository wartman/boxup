package boxup.cli;

import haxe.ds.Option;

using haxe.io.Path;

class DefinitionManager {
  final resolver:Resolver;
  final reporter:Reporter;
  final loader:Loader;
  final compiler:Compiler<Definition>;
  final definitions:Map<String, Definition> = [];

  public function new(resolver, loader, reporter) {
    this.resolver = resolver;
    this.reporter = reporter;
    this.loader = loader;
    this.compiler = new Compiler(
      reporter,
      new DefinitionGenerator(),
      DefinitionValidator.validator
    );
  }

  public function findDefinition(nodes:Array<Node>, source:Source):Option<Definition> {
    return switch resolver.resolveDefinitionType(nodes, source) {
      case Some(type): loadDefinition(type);
      case None: None;
    }
  }

  public function loadDefinition(type:String):Option<Definition> {
    if (definitions.exists(type)) {
      return Some(definitions.get(type));
    }

    return switch loader.load(type) {
      case Some(source): 
        switch compiler.compile(source) {
          case Some(def):
            definitions.set(type, def);
            Some(def);
          case None:
            None;
        }
      case None:
        reportNotFound(type);
        None;
    }
  }

  function reportNotFound(path:String) {
    reporter.report([
      new Error('Defintion not found: ${path}', {
        min: 0,
        max: 0,
        file: path
      })
    ], new Source(path, ''));
  }
}
