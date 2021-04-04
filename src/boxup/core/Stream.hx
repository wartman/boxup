package boxup.core;

interface Stream<In, Out>
  extends Writable<In>
  extends Readable<Out>
{
  public function map<R>(stream:Stream<Out, R>):Stream<Out, R>;
}
