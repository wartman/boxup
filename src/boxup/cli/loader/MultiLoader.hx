package boxup.cli.loader;

import haxe.ds.Option;

/**
  Load a file using a number of different options.
**/
class MultiLoader implements Loader {
  final loaders:Array<Loader>;

  public function new(loaders) {
    this.loaders = loaders;
  }

  public function load(file:String):Option<Source> {
    for (loader in loaders) switch loader.load(file) {
      case Some(source): 
        return Some(source);
      case None:
    }
    return None;
  }
}
