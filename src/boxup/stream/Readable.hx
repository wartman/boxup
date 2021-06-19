package boxup.stream;

abstract class Readable<T> {
  public final onData:Signal<T> = new Signal();
  public final onEnd:Signal<Readable<T>> = new Signal();
  public final onClose:Signal<Readable<T>> = new Signal();
  public final onError:Signal<ErrorCollection> = new Signal();
  var closed:Bool = false;

  public function isReadable() {
    return !closed;
  }

  public function push(data:T) {
    if (!isReadable()) return;
    onData.emit(data);
  }

  public function fail(error:ErrorCollection) {
    if (!isReadable()) return;
    onError.emit(error);
    end();
    close();
  }

  /**
    Pipe to a writeable.
  **/
  public function pipe<W:Writable<T>>(writer:W):W {
    if (!isReadable() || !writer.isWriteable()) return writer;

    var cancelDataListener = onData.add(writer.write);
    var cancelEndListener = onEnd.add(_ -> writer.end());
    var cancelErrorListener = onError.add(writer.onError.emit);
    onClose.add(_ -> writer.close());
    
    writer.onClose.add(_ -> {
      cancelDataListener();
      cancelEndListener();
      cancelErrorListener();
    });
    writer.onPiped.emit(this);

    return writer;
  }

  /**
    Signal that this readable stream has ended. This will *not* close
    the stream -- it just indicates that we've reached the end of some
    batch of data. 
  **/
  public function end(?data:T) {
    if (!isReadable()) return;
    if (data != null) push(data);
    onEnd.emit(this);
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
    onError.clear();
  }
}