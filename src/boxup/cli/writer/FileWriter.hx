package boxup.cli.writer;

import sys.FileSystem;
import sys.io.File;

using haxe.io.Path;

class FileWriter extends WriteStream<Chunk<Output>> {
  public function new() {
    super(chunk -> handleChunk(chunk.result, chunk.source));
  }

  function handleChunk(content:Result<Output>, source:Source) {
    content.handleValue(output -> {
      var fullPath = Path.join([ 
        output.task.destination, 
        getDestName(source.filename, output.task.extension) 
      ]);
      var dir = fullPath.directory();

      if (!FileSystem.exists(dir)) {
        FileSystem.createDirectory(dir);
      }
      if (!FileSystem.isDirectory(dir)) {
        throw 'Not a directiory: ${dir}';
      }
  
      File.saveContent(fullPath, output.content);
    });
  }

  function getDestName(filename:String, extension:String) {
    return switch filename.withoutDirectory().split('.') {
      case [name, _, 'box']: name.withExtension(extension);
      default: filename.withExtension(extension);
    }
  }
}
