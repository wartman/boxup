package boxup.cli;

import haxe.ds.Option;
import boxup.internal.Source;

interface Loader {
  public function load(file:String):Option<Source>;
}
