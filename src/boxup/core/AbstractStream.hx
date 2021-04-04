package boxup.core;

abstract class AbstractStream<In, Out> implements Stream<In, Out>  {
  public final onData:Signal<Out>;
  public final onClose:Signal<Noise>;
  public final onEnd:Signal<Noise> = new Signal();
  final reader:Readable<Out>;
  var closed:Bool = false;

  public function new(?reader) {
    this.reader = reader == null
      ? new ReadStream()
      : reader;

    onClose = this.reader.onClose;
    onData = this.reader.onData;
  }

  abstract public function write(data:In):Void;

  public function map<R>(stream:Stream<Out, R>):Stream<Out, R> {
    StreamTools.pipeReadableToWriteable(this, stream);
    return stream;
  }

  final inline function forward(data:Out) {
    reader.onData.emit(data);
  }

  final public function isReadable() {
    return reader.isReadable();
  }

  final public function isWritable():Bool {
    return !closed;
  }

  final public function pipe(writable:Writable<Out>) {
    reader.pipe(writable);
  }

  final public function close() {
    if (closed) return;

    closed = true;
    reader.close();
  }

  final public function end():Void {
    if (closed) return;

    onEnd.emit(null);
    onEnd.clear();
    close();
  }
}
