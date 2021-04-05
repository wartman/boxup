package boxup;

class ValidatorStream extends AbstractStream<Chunk<Array<Node>>, Chunk<Array<Node>>> {
  final validator:Validator;

  public function new(validator) {
    this.validator = validator;
    super();
  }
  
  public function write(chunk:Chunk<Array<Node>>) {
    forward({
      result: chunk.result.map(nodes -> validator.validate(nodes, chunk.source)),
      source: chunk.source 
    });
  }
}
