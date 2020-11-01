package boxup.cli;

import sys.FileSystem;
import sys.io.File;

using haxe.io.Path;

class FileWriter implements Writer {
  final root:String;

  public function new(root) {
    this.root = root;
  }
  
  public function write(path:String, content:String) {
    var fullPath = Path.join([ root, path ]);
    var dir = fullPath.directory();
    
    if (!FileSystem.exists(dir)) {
      FileSystem.createDirectory(dir);
    }
    if (!FileSystem.isDirectory(dir)) {
      throw 'Not a directiory: ${dir}';
    }

    File.saveContent(fullPath, content);
  }
}
