package boxup.cli;

import haxe.ds.Map;

@:forward
abstract SourceCollection(Map<String, Source>) {
  public function new() {
    this = [];
  }

  public function add(source:Source) {
    this.set(source.filename, source);
  }

  public function fromNodes(nodes:Array<Node>) {
    var file = nodes[0].pos.file;
    return this.get(file);
  }
}
