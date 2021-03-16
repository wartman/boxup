package boxup.cli;

import haxe.ds.Option;
import boxup.cli.DefinitionIdResolver;

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

  public function resolveDefinitionId(nodes, source):Option<DefinitionId> {
    for (resolver in this) switch resolver.resolveDefinitionId(nodes, source) {
      case Some(id): return Some(id);
      case None:
    }
    return None;
  }
}
