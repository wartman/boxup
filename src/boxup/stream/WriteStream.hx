package boxup.stream;

class WriteStream<T> extends Writable<T> {
  final writeHandler:(data:T)->Void;

  public function new(?writeHandler:(data:T)->Void, ?handleEnd:()->Void) {
    this.writeHandler = writeHandler == null ? (_) -> {} : writeHandler;
    if (handleEnd != null) onEnd.add(_ -> handleEnd());
  }

  public function write(data:T):Void {
    writeHandler(data);
  }
}
