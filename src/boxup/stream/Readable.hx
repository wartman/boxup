package boxup.stream;

class Readable<T> {
  public final onData:Signal<T> = new Signal();
  public final onEnd:Signal<Null<T>> = new Signal();
  public final onClose:Signal<Readable<T>> = new Signal();
  var closed:Bool = false;

  public function new() {}

  public function isReadable() {
    return !closed;
  }

  public function push(data:T) {
    if (!isReadable()) return;
    onData.emit(data);
  }

  public function pipe<R>(pipe:Duplex<T, R>):Readable<R> {
    into(pipe.writer);
    return pipe.reader;
  }

  public function into(writer:Writable<T>):Void {
    if (!isReadable() || !writer.isWriteable()) return;

    var cancelDataListener = onData.add(writer.write);
    var cancelEndListener = onEnd.add(writer.end);
    
    writer.onClose.add(_ -> {
      cancelDataListener();
      cancelEndListener();
    });
    writer.onPiped.emit(this);
  }

  /**
    Signal that this readable stream has ended. This will *not* close
    the stream -- it just indicates that we've reached the end of some
    batch of data. 
  **/
  public function end(?data:T) {
    if (!isReadable()) return;
    onEnd.emit(data);
  }

  /**
    Close the stream and clear all listeners.

    Note that this is NOT the same as `end`, and that no `end`
    handlers will be emitted when you close a stream! A stream can
    be ended many times but only closed once.
  **/
  public function close() {
    if (!isReadable()) return;
    
    closed = true;
    onClose.emit(this);

    onData.clear();
    onEnd.clear();
    onClose.clear();
  }
}
