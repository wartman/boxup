package boxup.stream;

interface Readable<T> {
  public final onData:Signal<T>;
  public final onEnd:Signal<Null<T>>;
  public final onClose:Signal<Readable<T>>;
  public function isReadable():Bool;
  public function push(data:T):Void;
  public function pipe(writer:Writable<T>):Void;
  public function end(?data:T):Void;
  public function close():Void;
}
