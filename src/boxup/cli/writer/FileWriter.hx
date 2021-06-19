package boxup.cli.writer;

import sys.io.File;
import sys.FileSystem;
import boxup.stream.Writable;

using haxe.io.Path;

class FileWriter extends Writable<Output<String>> {
  public function new() {}

  public function write(output:Output<String>) {
    if (output.source == null) {
      throw 'No source found -- something went horribly wrong';
    }

    var fullPath = Path.join([ 
      output.task.destination, 
      getDestName(output.source.filename, output.task.extension) 
    ]);
    var dir = fullPath.directory();

    if (!FileSystem.exists(dir)) {
      FileSystem.createDirectory(dir);
    }

    if (!FileSystem.isDirectory(dir)) {
      throw 'Not a directiory: ${dir}';
    }

    File.saveContent(fullPath, output.chunks.join(''));
  }

  function getDestName(filename:String, extension:String) {
    return switch filename.withoutDirectory().split('.') {
      case [name, _, 'box']: name.withExtension(extension);
      default: filename.withExtension(extension);
    }
  }
}
