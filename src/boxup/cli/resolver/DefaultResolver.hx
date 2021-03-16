package boxup.cli.resolver;

import haxe.ds.Option;

class DefaultResolver implements DefinitionIdResolver {
  public final priority:Int = 10;
  final type:String;

  public function new(type) {
    this.type = type;
  }

  public function resolveDefinitionId(nodes:Array<Node>, source:Source):Option<DefinitionId> {
    return Some(type);
  }  
}
