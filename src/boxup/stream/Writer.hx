package boxup.stream;

class Writer<T> implements Writable<T> {
  public final onEnd:Signal<Writable<T>> = new Signal();
  public final onPiped:Signal<Readable<T>> = new Signal();
  public final onClose:Signal<Writable<T>> = new Signal();
  final writeHandler:(data:T)->Void;
  var closed:Bool = false;
  
  public function new(?writeHandler:(data:T)->Void, ?handleEnd:()->Void) {
    this.writeHandler = writeHandler == null ? (_) -> {} : writeHandler;
    if (handleEnd != null) onEnd.add(_ -> handleEnd());
  }

  public function isWriteable() {
    return !closed;
  }

  public function write(data:T):Void {
    writeHandler(data);
  }

  public function end(?data:T):Void {
    if (!isWriteable()) return;
    if (data != null) write(data);
    
    onEnd.emit(this);
  }

  public function close() {
    if (!isWriteable()) return;
    
    closed = true;
    onClose.emit(this);
    
    onEnd.clear();
    onClose.clear();
  }
}
