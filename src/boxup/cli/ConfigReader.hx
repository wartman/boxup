package boxup.cli;

import haxe.ds.Option;
import sys.io.File;
import boxup.core.*;
import boxup.cli.loader.StaticLoader;

using sys.FileSystem;
using haxe.io.Path;

class ConfigReader extends ReadStream<Chunk<Config>> {
  final root:String;
  final allowedGenerators:Array<String>;

  public function new(root, allowedGenerators) {
    this.root = root;
    this.allowedGenerators = allowedGenerators;
    super();
  }

  public function read() {
    switch scanForBoxConfig(root) {
      case Some(path):
        var loader = new StaticLoader([ new Source(path, File.getContent(path)) ]);
        var scanner = new ScannerStream();
        
        scanner
          .map(new ParserStream())
          .map(new CompileStep(ConfigValidator.create(allowedGenerators).validate))
          .map(new CompileStep(new ConfigGenerator().generate))
          .pipe(new WriteStream(onData.emit, close));
        
        loader.pipe(scanner);
        loader.load();
      case None:
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
