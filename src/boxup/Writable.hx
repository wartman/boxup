package boxup;

interface Writable<T> {
  public final onEnd:Signal<Writable<T>>;
  public function isWritable():Bool;
  public function write(data:T):Void;
  public function end():Void;
}
