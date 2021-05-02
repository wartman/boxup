package boxup.cli;

import boxup.stream.Chunk;
import boxup.stream.Readable;

using boxup.stream.Stream;

class NodeStream {
  public static function pipeSourceThroughParser(source:Readable<Result<Source>>):Readable<Chunk<Array<Node>>> {
    return source.pipe(Stream.through((readable:Readable<Chunk<Array<Node>>>, result:Result<Source>) -> {
      result.handleValue(source -> {
        readable.push({
          result: source.tokens.map(Parser.parseTokens),
          source: source
        });
      });
      result.handleError(error -> {
        readable.push({
          result: Fail(error),
          source: Source.none()
        });
      });
    }));
  }

  public static function pipeNodesThroughFilter(
    nodes:Readable<Chunk<Array<Node>>>,
    filter:(nodes:Array<Node>, source:Source)->Bool
  ):Readable<Chunk<Array<Node>>> {
    return nodes.pipe(Stream.through((readable, chunk:Chunk<Array<Node>>) -> {
      chunk.result.handleValue(nodes -> if (filter(nodes, chunk.source)) readable.push(chunk));
      chunk.result.handleError(error -> readable.push({
        result: Fail(error),
        source: chunk.source
      }));
    }));
  }
}
