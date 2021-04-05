package boxup;

class WriteStream<T> implements Writable<T> {
  public final onEnd:Signal<Writable<T>> = new Signal();
  final handler:(data:T)->Void;

  var closed:Bool = false;

  public function new(handler, ?finisher) {
    this.handler = handler;
    if (finisher != null) onEnd.add(_ -> finisher());
  }

  public function isWritable():Bool {
    return !closed;
  }

  public function write(value:T) {
    if (isWritable()) handler(value);
  }

  public function end():Void {
    if (closed) return;
    
    closed = true;

    onEnd.emit(null);
    onEnd.clear();
  }
}
