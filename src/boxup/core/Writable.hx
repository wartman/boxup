package boxup.core;

interface Writable<T> {
  public final onEnd:Signal<Noise>;
  public function isWritable():Bool;
  public function write(data:T):Void;
  public function end():Void;
}
