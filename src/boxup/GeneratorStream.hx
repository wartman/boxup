package boxup;

class GeneratorStream<T> extends AbstractStream<Chunk<Array<Node>>, Chunk<T>> {
  final generator:Generator<T>;

  public function new(generator) {
    this.generator = generator;
    super();
  }
  
  public function write(chunk:Chunk<Array<Node>>) {
    forward({
      result: chunk.result.map(nodes -> generator.generate(nodes, chunk.source)),
      source: chunk.source 
    });
  }
}
