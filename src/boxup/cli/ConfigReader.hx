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
        var scanner = Scanner.toStream();
        
        scanner
          .map(Parser.toStream())
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

// import haxe.ds.Option;
// import sys.io.File;
// import boxup.cli.reader.StaticReader;

// using sys.FileSystem;
// using haxe.io.Path;

// class ConfigReader extends ReadableBase<Config> {
//   final root:String;
//   final allowedGenerators:Array<String>;

//   public function new(root, allowedGenerators) {
//     this.root = root;
//     this.allowedGenerators = allowedGenerators;
//   }

//   function handle(done:()->Void) {
//     switch scanForBoxConfig(root) {
//       case Some(path):
//         var reader = new StaticReader(new Source(path, File.getContent(path)));
        
//         reader
//           .pipe(new NodeStream())
//           .pipe(new ValidatorStream(ConfigValidator.create(allowedGenerators)))
//           .pipe(new GeneratorStream(new ConfigGenerator()))
//           .into(new Finalizer(dispatch));
        
//         reader.onDrained(done);
//         reader.read();
//       case None:
//         dispatch(Fail(new Error('Could not find a .boxconfig file', Position.unknown())), Source.none());
//         done();
//     }
//   }

//   function scanForBoxConfig(path:String):Option<String> {
//     var filepath = Path.join([ path, '.boxconfig' ]);

//     if (filepath.exists()) {
//       if (filepath.isDirectory()) return None;
//       return Some(filepath);
//     }
    
//     if (path.directory().isDirectory()) 
//       return scanForBoxConfig(path.directory());

//     return None;
//   }
// }
