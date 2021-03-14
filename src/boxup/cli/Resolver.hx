package boxup.cli;

import haxe.ds.Option;

interface Resolver {
  public function resolveDefinitionType(nodes:Array<Node>, source:Source):Option<String>;
}
