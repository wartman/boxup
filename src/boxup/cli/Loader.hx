package boxup.cli;

import haxe.ds.Option;

interface Loader {
  public function load(file:String):Option<Source>;
}
