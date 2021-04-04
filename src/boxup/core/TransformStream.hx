package boxup.core;

class TransformStream<In, Out> extends AbstractStream<In, Out> {
  final transform:(value:In)->Out;

  public function new(transform) {
    this.transform = transform;
    super();
  }

  public function write(value:In) {
    if (isWritable()) onData.emit(transform(value));
  }
}
