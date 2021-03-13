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
    var outcome = source.tokens
      .map(tokens -> new Parser(tokens).parse())
      .map(nodes -> 
        if (validator == null) 
          Ok(nodes) 
        else 
          validator.validate(nodes, source)
      )
      .map(nodes -> generator.generate(nodes, source));

    return switch outcome {
      case Ok(data): 
        Some(data);
      case Fail(error):
        reporter.report(error, source);
        None;
    }
  }
}
