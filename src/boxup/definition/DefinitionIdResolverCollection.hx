package boxup.definition;

import haxe.ds.Option;

abstract DefinitionIdResolverCollection(Array<DefinitionIdResolver>) from Array<DefinitionIdResolver> {
  @:from inline public static function ofDefinitionIdResolver(resolver:DefinitionIdResolver) {
    return new DefinitionIdResolverCollection([ resolver ]);
  }

  inline public function new(resolvers) {
    this = resolvers;
    this.sort((a, b) -> a.priority - b.priority);
  }

  inline public function add(resolver:DefinitionIdResolver) {
    this.push(resolver);
    this.sort((a, b) -> a.priority - b.priority);
  }

  public function resolveDefinitionId(nodes):Option<DefinitionId> {
    for (resolver in this) switch resolver.resolveDefinitionId(nodes) {
      case Some(id): return Some(id);
      case None:
    }
    return None;
  }
}
