package boxup.cli.config;

import sys.io.File;
import haxe.ds.Option;

using haxe.io.Path;
using sys.FileSystem;

class ConfigFinder {
  final compiler:Compiler<BoxConfig>;
  final root:String;

  public function new(reporter, root) {
    this.root = root;
    compiler = new Compiler(
      reporter,
      new ConfigGenerator(this.root),
      ConfigValidator.validator
    );
  }

  public function findConfig():Option<BoxConfig> {
    return switch scanForBoxConfig(root) {
      case Some(path):
        var source = new Source(path, File.getContent(path));
        compiler.compile(source);
      case None:
        None;
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
