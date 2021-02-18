package boxup.cli;

import haxe.ds.Option;
import boxup.Parser.Source;

interface Loader {
  public function load(file:String):Option<Source>;
}
