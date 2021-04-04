package boxup.core;

interface Readable<T> {
  public final onData:Signal<T>;
  public final onClose:Signal<Noise>;
  public function isReadable():Bool;
  public function pipe(writable:Writable<T>):Void;
  public function close():Void;
}
