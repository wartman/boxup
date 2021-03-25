package boxup.cli;

import sys.FileSystem;
import boxup.cli.generator.*;
import boxup.cli.writer.FileWriter;
import boxup.cli.loader.FileLoader;
import boxup.cli.config.BoxConfig;

using haxe.io.Path;

// @todo: this is a bit messy
class Task {
  final root:String;
  final ext:String;
  final loader:Loader;
  final writer:Writer;
  final compiler:Compiler<String>;

  public function new(
    reporter:Reporter, 
    manager:DefinitionManager, 
    task:CompileTask,
    generators:Map<DefinitionId, (definition:Definition)->Generator<String>>
  ) {
    root = task.source;
    ext = task.generator;
    loader = new FileLoader({ root: task.source });
    writer = new FileWriter(task.destination);

    // @todo: this needs work :V
    generators.set('*', switch task.generator {
      case 'html': 
        HtmlGenerator.new;
      case 'json':
        _ -> new JsonGenerator();
      default:
        throw 'Invalid generator: ${task.generator}';
    });

    compiler = new Compiler(
      reporter,
      new AutoGenerator(manager, generators), 
      manager.getValidator()
    );
  }

  function getDestName(filename:String) {
    return switch filename.split('.') {
      case [name, _, 'box']: name.withExtension(ext);
      default: filename.withExtension(ext);
    }
  }

  public function run() {
    for (filename in FileSystem.readDirectory(root)) {
      if (filename.extension() == 'box') switch loader.load(filename) {
        case Some(source): switch compiler.compile(source) {
          case Some(output): 
            writer.write(getDestName(filename), output);
          case None:
            throw 'Failed to compile';
        }
        case None:
          throw 'File does not exist: ${filename}';
      } 
    }
  }
}
