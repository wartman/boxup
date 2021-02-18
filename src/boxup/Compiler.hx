package boxup;

import haxe.ds.Option;

class Compiler<T> {
  final reporter:Reporter;
  final generator:Generator<T>;
  final validator:Null<Validator>;

  public function new(reporter, generator, ?validator) {
    this.reporter = reporter;
    this.generator = generator;
    this.validator = validator;
  }

  public function compile(source:Source):Option<T> {
    try {
      var parser = new Parser(source);
      var nodes = parser.parse();
      if (validator == null) {
        return Some(generator.generate(nodes));
      }
      switch validator.validate(nodes) {
        case Failed(errors): 
          reporter.report(errors, source);
          return None;
        case Passed:
          return Some(generator.generate(nodes));
      }
    } catch (e:Error) {
      reporter.report([ e ], source);
      return None;
    }
  }
}
