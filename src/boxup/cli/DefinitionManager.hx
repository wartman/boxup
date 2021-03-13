package boxup.cli;

import haxe.ds.Option;

using haxe.io.Path;

class DefinitionManager {
  final reporter:Reporter;
  final compiler:Null<DefinitionCompiler>;
  final definitions:Map<String, Definition> = [];

  public function new(loader, reporter) {
    this.reporter = reporter;
    compiler = new DefinitionCompiler(loader, reporter);
  }
  public function loadDefinition(type:String):Option<Definition> {
    if (definitions.exists(type)) return Some(definitions.get(type));
    
    var def = compiler.load(type);

    switch def {
      case Some(def):
        definitions.set(type, def);
      case None:
    }

    return def;
  }

  public function getDocumentType(name:String):Option<String> {
    return switch name.withoutDirectory().split('.') {
      case [_, type, 'box']: Some(type);
      default: None;
    }
  }
}