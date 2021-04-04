package boxup.core;

abstract class AbstractStream<In, Out> implements Stream<In, Out>  {
  public final onData:Signal<Out> = new Signal();
  public final onClose:Signal<Noise> = new Signal();
  public final onEnd:Signal<Noise> = new Signal();
  var closed:Bool = false;

  public function new() {}

  abstract public function write(data:In):Void;

  public function map<R>(stream:Stream<Out, R>):Stream<Out, R> {
    StreamTools.pipeReadableToWriteable(this, stream);
    return stream;
  }

  final inline function forward(data:Out) {
    onData.emit(data);
  }

  public function isReadable():Bool {
    return !closed;
  }

  final public function isWritable():Bool {
    return !closed;
  }

  public function pipe(writable:Writable<Out>):Void {
    StreamTools.pipeReadableToWriteable(this, writable);
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
