package boxup.core;

class TransformStream<In, Out> implements Stream<In, Out> {
  public final onEnd:Signal<Noise> = new Signal();
  public final onData:Signal<Out> = new Signal();
  public final onClose:Signal<Noise> = new Signal();

  final transform:(value:In)->Out;
  var closed:Bool = false;

  public function new(transform) {
    this.transform = transform;
  }
  
  public function isReadable() {
    return !closed;
  }

  public function isWritable() {
    return !closed;
  }

  public function write(value:In) {
    if (isWritable()) onData.emit(transform(value));
  }

  public function pipe(writable:Writable<Out>):Void {
    StreamTools.pipeReadableToWriteable(this, writable);
  }

  public function map<R>(stream:Stream<Out, R>):Stream<Out, R> {
    StreamTools.pipeReadableToWriteable(this, stream);
    return stream;
  }

  public function end():Void {
    if (closed) return;

    onEnd.emit(null);
    onEnd.clear();

    close();
  }

  public function close():Void {
    if (closed) return;

    closed = true;

    onClose.emit(null);

    onData.clear();
    onClose.clear();
  }
}
