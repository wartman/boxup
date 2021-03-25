package boxup.cli.config;

import haxe.ds.Option;

using haxe.io.Path;

class ConfigResolver implements DefinitionIdResolver {
  public final priority:Int = 1;

  public function new() {}

  public function resolveDefinitionId(nodes:Array<Node>, source:Source):Option<DefinitionId> {
    return switch source.filename.withoutDirectory() {
      case 'config.box': Some('config');
      default: None;
    }
  }
}
