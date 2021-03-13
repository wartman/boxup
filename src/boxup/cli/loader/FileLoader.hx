package boxup.cli.loader;

import haxe.ds.Option;
import sys.FileSystem;
import sys.io.File;

using StringTools;
using haxe.io.Path;

class FileLoader implements Loader {
  final root:String;

  public function new(root) {
    this.root = root;
  }

  public function load(filename:String):Option<Source> {
    var path = Path.join([ root, filename ]);
    if (path.extension() == '') {
      path = path.withExtension('box');
    }
    if (FileSystem.exists(path)) {
      var content = File.getContent(path);
      return Some(new Source(path, content));
    }
    return None;
  }
}
