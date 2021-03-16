package boxup.cli;

import haxe.ds.Option;

interface Loader {
  public function load(path:String):Option<Source>;
}
