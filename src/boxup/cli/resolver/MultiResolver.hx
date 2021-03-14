package boxup.cli.resolver;

import haxe.ds.Option;

class MultiResolver implements Resolver {
  final resolvers:Array<Resolver>;

  public function new(resolvers) {
    this.resolvers = resolvers;
  }
  
  public function resolveDefinitionType(nodes:Array<Node>, source:Source):Option<String> {
    for (r in resolvers) switch r.resolveDefinitionType(nodes, source) {
      case Some(name): return Some(name);
      case None:
    }
    return None;
  }
}
