package boxup.cli;

import haxe.ds.Option;
import sys.io.File;
import boxup.cli.reader.StaticReader;

using sys.FileSystem;
using haxe.io.Path;

class ConfigReader extends ReadableBase<Config> {
  final root:String;
  final allowedGenerators:Array<String>;

  public function new(root, allowedGenerators) {
    this.root = root;
    this.allowedGenerators = allowedGenerators;
  }

  function handle(done:()->Void) {
    switch scanForBoxConfig(root) {
      case Some(path):
        var reader = new StaticReader(new Source(path, File.getContent(path)));
        
        reader
          .pipe(new NodeStream())
          .pipe(new ValidatorStream(ConfigValidator.create(allowedGenerators)))
          .pipe(new GeneratorStream(new ConfigGenerator()))
          .into(new Writer((data, source) -> {
            dispatch(data, source);
            done();
          }));
        
          reader.read();
      case None:
        dispatch(Fail(new Error('Could not find a .boxconfig file', Position.unknown())), Source.none());
        done();
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
