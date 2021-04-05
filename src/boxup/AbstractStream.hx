package boxup;

abstract class AbstractStream<In, Out> 
  extends ReadStream<Out> 
  implements Stream<In, Out> 
{
  public final onEnd:Signal<Writable<In>> = new Signal();

  abstract public function write(data:In):Void;

  public function map<R>(stream:Stream<Out, R>):Stream<Out, R> {
    pipe(stream);
    return stream;
  }

  inline function forward(data:Out) {
    onData.emit(data);
  }

  public function isWritable():Bool {
    return !closed;
  }

  public function end():Void {
    if (closed) return;

    onEnd.emit(this);
    onEnd.clear();

    close();
  }
}
