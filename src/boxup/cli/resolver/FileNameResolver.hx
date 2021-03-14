package boxup.cli.resolver;

import haxe.ds.Option;

using haxe.io.Path;

class FileNameResolver implements Resolver {
  public function new() {}

  public function resolveDefinitionType(nodes:Array<Node>, source:Source):Option<String> {
    return switch source.filename.withoutDirectory().split('.') {
      case [_, type, 'box']: Some(type);
      default: None;
    }
  }
}
