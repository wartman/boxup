package boxup.cli.resolver;

import boxup.definition.DefinitionIdResolver;
import boxup.definition.DefinitionId;
import haxe.ds.Option;

using haxe.io.Path;

class FileNameResolver implements DefinitionIdResolver {
  public final priority:Int = 1;

  public function new() {}

  public function resolveDefinitionId(nodes:Array<Node>):Option<DefinitionId> {
    if (nodes.length == 0) return None;
    return switch nodes[0].pos.file.withoutDirectory().split('.') {
      case [_, id, 'box']: Some(id);
      default: None;
    }
  }
}
