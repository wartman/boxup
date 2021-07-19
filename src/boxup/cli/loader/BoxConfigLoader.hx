package boxup.cli.loader;

import haxe.ds.Option;
import sys.io.File;

using sys.FileSystem;
using haxe.io.Path;

class BoxConfigLoader extends Loader {
  final root:String;
  
  public function new(root) {
    this.root = root;
  }

  function load() {
    switch scanForBoxConfig(root) {
      case Some(path):
        end(new Source(path, File.getContent(path)));
        close();
      case None:
        fail(new Error('Could not find a .boxconfig file', Position.unknown()));
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
