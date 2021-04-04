package boxup;

import haxe.ds.Map;
import boxup.core.*;

class ParserStream extends AbstractStream<Chunk<Array<Token>>, Chunk<Array<Node>>> {
  final parsed:Map<String, Result<Array<Node>>> = [];
  
  public function write(chunk:Chunk<Array<Token>>) {
    forward({
      result: parsed.exists(chunk.source.filename)
        ? parsed.get(chunk.source.filename)
        : chunk.result.map(tokens -> {
          var nodes = new Parser(tokens).parse();
          parsed.set(chunk.source.filename, nodes);
          return nodes;
        }),
      source: chunk.source
    });
  }
}
