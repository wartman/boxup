package boxup;

class NodeStream extends StreamBase<Array<Token>, Array<Node>> {
  public function new() {}

  function transform(tokens:Result<Array<Token>>, source:Source) {
    return tokens.map(tokens -> new Parser(tokens).parse());
  }
}
