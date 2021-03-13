package boxup.cli.loader;

import haxe.ds.Option;

using haxe.io.Path;
using sys.FileSystem;

/**
  Loads definitions from a .boxup folder. Will scan up directories
  to find it if needed.
**/
class DotBoxupDefintionLoader extends FileLoader {
  public function new(root) {
    var path = switch scanForDotBoxupPath(root) {
      case Some(v): v;
      case None: 
        throw 'Could not find a .boxup folder';
        root;
    }

    super(path);
  }

  function scanForDotBoxupPath(path:String):Option<String> {
    var root = Path.join([ path, '.boxup' ]);
    
    if (root.isDirectory()) 
      return Some(root);
    
    if (path.directory().isDirectory()) 
      return scanForDotBoxupPath(path.directory());

    return None;
  }

  override function load(filename:String):Option<Source> {
    return super.load('${filename}.definition.box');
  }
}
