package boxup.definition;

import haxe.ds.Option;

using haxe.io.Path;

class DefinitionCollection implements Validator {
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

  inline public function resolveDefinitionId(nodes, source) {
    return resolver.resolveDefinitionId(nodes, source);
  }

  public function findDefinition(nodes:Array<Node>, source:Source):Option<Definition> {
    return switch resolveDefinitionId(nodes, source) {
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

  public function validate(nodes:Array<Node>, source:Source):Result<Array<Node>> {
    return switch findDefinition(nodes, source) {
      case Some(def): 
        def.validate(nodes, source);
      case None: 
        Ok(nodes);
    }
  }
}
