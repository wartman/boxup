package boxup.core;

class ReadStream<T> implements Readable<T> {
  public final onData:Signal<T> = new Signal();
  public final onClose:Signal<Noise> = new Signal();
  
  var closed:Bool = false;

  public function new() {}

  public function isReadable():Bool {
    return !closed;
  }

  public function pipe(writable:Writable<T>):Void {
    StreamTools.pipeReadableToWriteable(this, writable);
  }

  public function close():Void {
    if (closed) return;

    closed = true;

    onClose.emit(null);

    onData.clear();
    onClose.clear();
  }
}
