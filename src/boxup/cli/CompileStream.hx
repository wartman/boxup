package boxup.cli;

import boxup.stream.Chunk;
import boxup.stream.Readable;

using boxup.stream.Stream;
using boxup.cli.NodeStream;

class CompileStream {
  public static function pipeSourceIntoGenerator<T>(source:Readable<Result<Source>>, validator, generator:Generator<T>) {
    return source
      .pipeSourceThroughParser()
      .map(createCompiler(validator, generator));
  }

  public static function pipeNodesIntoGenerator<T>(nodes:Readable<Chunk<Array<Node>>>, validator, generator:Generator<T>) {
    return nodes.map(createCompiler(validator, generator));
  }

  @:noUsing
  public static function createCompiler<T>(validator:Validator, generator:Generator<T>) {
    return function (chunk:Chunk<Array<Node>>):Chunk<T> return {
      result: chunk.result
        .map(nodes -> validator.validate(nodes, chunk.source))
        .map(nodes -> generator.generate(nodes, chunk.source)),
      source: chunk.source
    };
  }
}
