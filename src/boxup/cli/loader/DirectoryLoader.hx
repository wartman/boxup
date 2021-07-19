package boxup.cli.loader;

import sys.io.File;

using sys.FileSystem;
using haxe.io.Path;

class DirectoryLoader extends Loader {
  final root:String;

  public function new(root) {
    this.root = root;
  }

  public function load() {
    readDir(root);
    end();
    close();
  }

  function readDir(path:String) {
    for (name in FileSystem.readDirectory(path)) {
      if (name.extension() == 'box') {
        var filename = Path.join([ path, name ]);
        var content = File.getContent(filename);
        push(new Source(filename, content));
      } else {
        var filename = Path.join([ path, name ]);
        if (filename.isDirectory()) {
          readDir(filename);
        }
      }
    }
  }
}
