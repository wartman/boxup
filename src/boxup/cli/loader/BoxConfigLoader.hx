package boxup.cli.loader;

import haxe.ds.Option;
import sys.io.File;

using sys.FileSystem;
using haxe.io.Path;

class BoxConfigLoader extends Loader {final root:String;
  public function new(root) {
    this.root = root;
    super();
  }

  function load(next:(data:Result<Source>)->Void, end:()->Void) {
    switch scanForBoxConfig(root) {
      case Some(path):
        var source = new Source(path, File.getContent(path));
        next(Ok(source));
        end();
      case None:
        next(Fail(new Error('Could not find a .boxconfig file', Position.unknown())));
        end();
    }
  }

  function scanForBoxConfig(path:String):Option<String> {
    var filepath = Path.join([ path, '.boxconfig' ]);

    if (filepath.exists()) {
      if (filepath.isDirectory()) return None;
      return Some(filepath);
    }
    
    if (path.directory().isDirectory()) 
      return scanForBoxConfig(path.directory());

    return None;
  }
}
