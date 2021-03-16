package boxup.cli;

import haxe.ds.Option;

abstract LoaderCollection(Array<Loader>) from Array<Loader> {
  @:from inline public static function ofLoader(loader:Loader) {
    return new LoaderCollection([ loader ]);
  }

  inline public function new(loaders) {
    this = loaders;
  }

  public function load(path:String):Option<Source> {
    for (loader in this) switch loader.load(path) {
      case Some(source): return Some(source);
      case None:
    }
    return None;
  }
}
