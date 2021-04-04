package boxup;

import boxup.core.*;

class ParserStream extends AbstractStream<Chunk<Array<Token>>, Chunk<Array<Node>>> {
  public function write(chunk:Chunk<Array<Token>>) {
    forward({
      result: chunk.result.map(tokens -> new Parser(tokens).parse()),
      source: chunk.source
    });
  }
}
