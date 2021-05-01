package boxup.cli.loader;

import sys.io.File;

using sys.FileSystem;
using haxe.io.Path;

class DirectoryLoader extends Loader {
  final root:String;

  public function new(root) {
    this.root = root;
    super();
  }
  
  function load(next:(data:Result<Source>)->Void, end:()->Void) {
    var data = readDir(root);
    var item = data.pop();
    while (item != null) {
      next(Ok(item));
      item = data.pop();
    }
    end();
  }

  function readDir(path:String):Array<Source> {
    var out:Array<Source> = [];
    for (name in FileSystem.readDirectory(path)) {
      if (name.extension() == 'box') {
        var filename = Path.join([ path, name ]);
        var content = File.getContent(filename);
        out.push(new Source(filename, content));
      } else {
        var filename = Path.join([ path, name ]);
        if (filename.isDirectory()) {
          out = out.concat(readDir(filename));
        }
      }
    }
    return out;
  }
}
