package boxup;

interface Readable<T> {
  public final onData:Signal<T>;
  public final onClose:Signal<Readable<T>>;
  public function isReadable():Bool;
  public function pipe(writable:Writable<T>):Void;
  public function close():Void;
}
