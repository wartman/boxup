package boxup;

class ReadStream<T> implements Readable<T> {
  public final onData:Signal<T> = new Signal();
  public final onClose:Signal<Readable<T>> = new Signal();
  
  var closed:Bool = false;

  public function new() {}

  public function isReadable():Bool {
    return !closed;
  }

  public function pipe(writable:Writable<T>):Void {
    if (!isReadable() || !writable.isWritable()) return;
    onData.add(writable.write);
    onClose.add(_ -> writable.end());
  }

  public function close():Void {
    if (closed) return;

    closed = true;

    onClose.emit(this);

    onData.clear();
    onClose.clear();
  }
}
