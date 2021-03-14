package boxup.cli.resolver;

import haxe.ds.Option;

/**
  Always resolve to the given type.
**/
class StaticResolver implements Resolver {
  final type:String;

  public function new(type) {
    this.type = type;
  }

  public function resolveDefinitionType(nodes:Array<Node>, source:Source):Option<String> {
    return Some(type);
  }  
}
