package boxup.cli;

import haxe.ds.Option;

class DefinitionLoader {
  final validatior = new DefinitionValidator();
  final generator = new DefinitionGenerator();
  final loader:Loader;
  final reporter:Reporter;

  public function new(loader, reporter) {
    this.loader = loader;
    this.reporter = reporter;
  }

  public function load(path:String):Option<Definition> {
    return switch loader.load(path) {
      case Some(source):
        var parser = new Parser(source);
        var nodes:Array<Node> = try parser.parse() catch (e:Error) {
          reporter.report([ e ], source);
          [];
        }
        var result = validatior.validate(nodes);
        if (result.hasErrors) {
          reporter.report(result.errors, source);
          None;
        } else {
          var result = generator.generate(nodes);
          if (result.hasErrors) reporter.report(result.errors, source);
          Some(result.result);
        }
      case None:
        reporter.report([
          new Error('File not found: ${path}', {
            min: 0,
            max: 0,
            file: path
          })
        ], { filename: path, content: '' });
        None;
    }
  }
}
