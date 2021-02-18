package boxup.cli;

import haxe.Exception;
import haxe.ds.Option;
import boxup.Parser;

class Compiler {
  final validator:Null<Validator>;
  final generator:Generator<String>;
  final loader:Loader;
  final writer:Writer;
  final reporter:Reporter;

  public function new(validator, generator, loader, writer, reporter) {
    this.validator = validator;
    this.generator = generator;
    this.loader = loader;
    this.writer = writer;
    this.reporter = reporter;
  }

  public function run(src:String, dst:String) {
    switch loader.load(src) {
      case None:
        throw new Exception('File does not exist: ${src}');
      case Some(source): switch compile(source) {
        case None:
          throw new Exception('Failed to compile');
        case Some(output):
          writer.write(dst, output);
      }
    }
  }

  public function compile(source:Source):Option<String> {
    try {
      var parser =new Parser(source);
      var nodes = parser.parse();
      if (validator != null) {
        var result = validator.validate(nodes);
        if (result.hasErrors) {
          reporter.report(result.errors, source);
          return None;
        }
      }
      var result = generator.generate(nodes);
      if (result.hasErrors) {
        reporter.report(result.errors, source);
        return None;
      }
      return Some(result.result);
    } catch (e:Error) {
      reporter.report([ e ], source);
      return None;
    }
  }
}
