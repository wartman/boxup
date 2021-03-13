package boxup.cli.loader;

import haxe.Resource;
import haxe.ds.Option;

class ResourceLoader implements Loader {
  public function new() {}

  public function load(name:String):Option<Source> {
    return switch Resource.getString(name) {
      case null:
        None;
      case data:
        Some(new Source('<resource:$name>', data));
    }
  }
}