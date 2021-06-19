package boxup.stream;

abstract class Writable<T> {
  public final onEnd:Signal<Writable<T>> = new Signal();
  public final onPiped:Signal<Readable<T>> = new Signal();
  public final onClose:Signal<Writable<T>> = new Signal();
  public final onError:Signal<ErrorCollection> = new Signal();
  var closed:Bool = false;

  public function isWriteable() {
    return !closed;
  }

  abstract public function write(data:T):Void;

  function finish():Void {
    // noop
  }

  public function end(?data:T):Void {
    if (!isWriteable()) return;
    if (data != null) write(data);
    
    onEnd.emit(this);
    finish();
  }

  public function close() {
    if (!isWriteable()) return;
    
    closed = true;
    onClose.emit(this);
    
    onEnd.clear();
    onClose.clear();
    onError.clear();
  }
}
