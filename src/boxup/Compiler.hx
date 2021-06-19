package boxup;

import boxup.stream.Writable;

using boxup.stream.StreamTools;

class Compiler<T> extends Writable<Source> {
  final scanner:Scanner = new Scanner();
  final parser:Parser = new Parser();
  final generator:Generator<T>;
  final validator:Null<Validator>;

  public function new(generator, ?validator) {
    this.generator = generator;
    this.validator = validator;

    scanner.pipe(parser);

    if (validator != null) {
      parser
        .pipe(validator)
        .pipe(generator);
    } else {
      parser.pipe(generator);
    }
  }

  public function write(source:Source) {
    scanner.write(source);
  }

  public function pipe<W:Writable<T>>(writer:W):W {
    generator.pipe(writer);
    return writer;
  }
}
