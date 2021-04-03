package boxup.cli.reader;

import sys.io.File;

using sys.FileSystem;
using haxe.io.Path;

class DirectoryReader extends ReadableBase<Array<Token>> {
  final root:String;

  public function new(root) {
    this.root = root;
  }

  function handle(done:()->Void) {
    readDir(root);
    done();
  }

  function readDir(path:String) {
    for (name in FileSystem.readDirectory(path)) {
      if (name.extension() == 'box') {
        var filename = Path.join([ path, name ]);
        var content = File.getContent(filename);
        var source = new Source(filename, content);
        dispatch(new Scanner(source).scan(), source);
      } else {
        var filename = Path.join([ path, name ]);
        if (filename.isDirectory()) {
          readDir(filename);
        }
      }
    }
  }
}
