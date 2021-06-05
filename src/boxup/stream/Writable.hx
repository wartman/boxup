package boxup.stream;

interface Writable<T> {
  public final onEnd:Signal<Writable<T>>;
  public final onPiped:Signal<Readable<T>>;
  public final onClose:Signal<Writable<T>>;
  public function isWriteable():Bool;
  public function write(data:T):Void;
  public function end(?data:T):Void;
  public function close():Void;
}
