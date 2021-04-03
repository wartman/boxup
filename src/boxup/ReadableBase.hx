package boxup;

abstract class ReadableBase<T> implements Readable<T> {
  final writers:Array<Writable<T>> = [];
  final drained:Array<()->Void> = [];

  public function into(writeable:Writable<T>) {
    writers.push(writeable);
  }

  public function pipe<R>(stream:Stream<T, R>) {
    into(stream);
    onDrained(() -> stream.read());
    return stream;
  }

  public function read() {
    handle(() -> for (cb in drained) cb());
  }

  public function onDrained(cb:()->Void):Void {
    drained.push(cb);
  }

  abstract function handle(done:()->Void):Void;

  function dispatch(result:Result<T>, source:Source) {
    for (writer in writers) writer.write(result, source);
  }
}
