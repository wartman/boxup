package boxup.cli.writer;

import sys.FileSystem;
import sys.io.File;

using haxe.io.Path;

class FileWriter implements Writable<String> {
  final task:Task;

  public function new(task) {
    this.task = task;
  }

  public function write(content:Result<String>, source:Source) {
    content.handleValue(content -> {
      var fullPath = Path.join([ task.destination, getDestName(source.filename) ]);
      var dir = fullPath.directory();

      if (!FileSystem.exists(dir)) {
        FileSystem.createDirectory(dir);
      }
      if (!FileSystem.isDirectory(dir)) {
        throw 'Not a directiory: ${dir}';
      }
  
      File.saveContent(fullPath, content);
    });
  }

  function getDestName(filename:String) {
    return switch filename.withoutDirectory().split('.') {
      case [name, _, 'box']: name.withExtension(task.extension);
      default: filename.withExtension(task.extension);
    }
  }
}
