package boxup;

interface Readable<T> {
  public function into(writeable:Writable<T>):Void;
  public function pipe<R>(stream:Stream<T, R>):Stream<T, R>;
  public function read():Void;
  public function onDrained(cb:()->Void):Void;
}
