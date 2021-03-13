package boxup.cli.loader;

import haxe.ds.Map;
import haxe.ds.Option;

class StringMapLoader implements Loader {
  final sources:Map<String, String>;

  public function new(sources) {
    this.sources = sources;
  }

  public function load(name:String):Option<Source> {
    if (!sources.exists(name)) return None;
    return Some(new Source('<string:${name}>', sources.get(name)));
  }
}
