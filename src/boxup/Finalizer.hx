package boxup;

class Finalizer<T> implements Writable<T> {
  final handle:(data:Result<T>, source:Source)->Void;

  public function new(handle) {
    this.handle = handle;
  }

  public function write(data:Result<T>, source:Source):Void {
    handle(data, source);
  }
}
