package boxup;

interface Writable<T> {
  public function write(data:Result<T>, source:Source):Void;
}
