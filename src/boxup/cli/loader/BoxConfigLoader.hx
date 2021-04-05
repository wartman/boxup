package boxup.cli.loader;

import haxe.ds.Option;
import sys.io.File;

using sys.FileSystem;
using haxe.io.Path;

class BoxConfigLoader extends ReadStream<Result<Source>> implements Loader {
  final root:String;

  public function new(root) {
    this.root = root;
    super();
  }

  public function load() {
    switch scanForBoxConfig(root) {
      case Some(path):
        var source = new Source(path, File.getContent(path));
        onData.emit(Ok(source));
        close();
      case None:
        onData.emit(Fail(new Error('Could not find a .boxconfig file', Position.unknown())));
        close();
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
