package boxup;

import boxup.core.*;

class CompileStep<In, Out> extends TransformStream<Chunk<In>, Chunk<Out>>  {
  public function new(next:(result:In, source:Source)->Result<Out>) {
    super(function (chunk:Chunk<In>) {
      return {
        result: chunk.result.map(value -> next(value, chunk.source)),
        source: chunk.source
      };
    });
  }
}
