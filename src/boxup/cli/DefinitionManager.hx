package boxup.cli;

import haxe.ds.Option;

using haxe.io.Path;

class DefinitionManager {
  final reporter:Reporter;
  final resolver:DefinitionIdResolverCollection;
  final loader:LoaderCollection;
  final compiler:Compiler<Definition>;
  final definitions:Map<DefinitionId, Definition> = [];

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

  public function addDefinition(id:DefinitionId, definition:Definition) {
    definitions.set(id, definition);
  }

  public function removeDefinition(id:DefinitionId) {
    definitions.remove(id);
  }

  inline public function resolveDefinitionId(nodes, source) {
    return resolver.resolveDefinitionId(nodes, source);
  }

  public function findDefinition(nodes:Array<Node>, source:Source):Option<Definition> {
    return switch resolveDefinitionId(nodes, source) {
      case Some(id): loadDefinition(id);
      case None: None;
    }
  }

  public function loadDefinition(id:DefinitionId):Option<Definition> {
    if (definitions.exists(id)) {
      return Some(definitions.get(id));
    }

    return switch loader.load(id) {
      case Some(source): 
        switch compiler.compile(source) {
          case Some(def):
            definitions.set(id, def);
            Some(def);
          case None:
            None;
        }
      case None:
        reportNotFound(id);
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
