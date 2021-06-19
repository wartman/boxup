package boxup.definition;

import haxe.ds.Option;

using haxe.io.Path;

class DefinitionCollection {
  final resolver:DefinitionIdResolverCollection;
  final definitions:Map<DefinitionId, Definition> = [];

  public function new(resolver) {
    this.resolver = resolver;
  }

  public function addDefinition(definition:Definition) {
    definitions.set(definition.id, definition);
  }

  public function removeDefinition(id:DefinitionId) {
    definitions.remove(id);
  }

  inline public function resolveDefinitionId(nodes) {
    return resolver.resolveDefinitionId(nodes);
  }

  public function findDefinition(nodes:Array<Node>):Option<Definition> {
    return switch resolveDefinitionId(nodes) {
      case Some(id): getDefinition(id);
      case None: None;
    }
  }

  public function getDefinition(id:DefinitionId):Option<Definition> {
    if (definitions.exists(id)) {
      return Some(definitions.get(id));
    }
    return None;
  }

  public function listDefinitions() {
    return [ for (key in definitions.keys()) key ];
  }
}
