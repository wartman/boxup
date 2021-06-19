package boxup.stream;

abstract class Duplex<In, Out> extends Writable<In> {
  public final output:Readable<Out> = new ReadStream();

  public function new() {
    StreamTools.forwardListeners(this, output);
  }

  public function pipe<W:Writable<Out>>(writer:W):W {
    return output.pipe(writer);
  }
}
