package boxup.cli.resolver;

import boxup.definition.DefinitionIdResolver;
import boxup.definition.DefinitionId;
import haxe.ds.Option;

using haxe.io.Path;

class DirectoryResolver implements DefinitionIdResolver {
  public final priority:Int = 1;

  public function new() {}

  public function resolveDefinitionId(nodes:Array<Node>):Option<DefinitionId> {
    var id:DefinitionId = nodes[0].pos.file.directory().withoutDirectory();
    if (id == null || id.length == 0) return None;
    return Some(id);
  }
}
