package boxup.cli.loader;

import haxe.ds.Option;
import sys.FileSystem;
import sys.io.File;

using StringTools;
using haxe.io.Path;

typedef FileLoaderOptions = {
  public final ?suffix:String;
  public final root:String;
} 

class FileLoader implements Loader {
  final options:FileLoaderOptions;

  public function new(options) {
    this.options = options;
  }

  public function load(filename:String):Option<Source> {
    filename = switch filename.split('.') {
      case [ name, 'box' ] | [ name ] if (options.suffix != null):
        [ name, options.suffix, 'box' ].join('.');
      case [ name, ext ] if (options.suffix != null && ext == options.suffix):
        [ name, options.suffix, 'box' ].join('.');
      default:
        filename.withExtension('box');
    }
    var path = Path.join([ options.root, filename ]);

    if (FileSystem.exists(path)) {
      var content = File.getContent(path);
      return Some(new Source(path, content));
    }

    return None;
  }
}
