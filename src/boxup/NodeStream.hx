package boxup;

class NodeStream extends AbstractStream<Result<Source>, Chunk<Array<Node>>> {
  public function write(source:Result<Source>) {
    source.handleValue(source -> forward({
      result: source.tokens.map(tokens -> new Parser(tokens).parse()),
      source: source
    }));
    source.handleError(err -> forward({
      result: Fail(err),
      source: Source.none()
    }));
  }
}
