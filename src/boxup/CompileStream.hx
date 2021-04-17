package boxup;

class CompileStream<T> extends AbstractStream<Chunk<Array<Node>>, Chunk<T>> {
  final validator:Validator;
  final generator:Generator<T>;

  public function new(validator, generator) {
    this.validator = validator;
    this.generator = generator;
    super();
  }
 
  public function write(chunk:Chunk<Array<Node>>) {
    forward({
      result: chunk.result
        .map(nodes -> validator.validate(nodes, chunk.source))
        .map(nodes -> generator.generate(nodes, chunk.source)),
      source: chunk.source
    });
  }
}
