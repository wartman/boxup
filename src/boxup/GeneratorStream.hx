package boxup;

class GeneratorStream<T> extends StreamBase<Array<Node>, T> {
  final generator:Generator<T>;

  public function new(generator) {
    this.generator = generator;
  }

  function transform(nodes:Result<Array<Node>>, source:Source) {
    return nodes.map(nodes -> generator.generate(nodes, source));
  }
}
