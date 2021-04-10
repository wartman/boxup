package boxup;

/**
  Combines multiple read streams and only emits a `close` signal
  when all source streams are finished.
**/
class CompoundReadStream<T> extends ReadStream<T> {
  final sources:Array<Readable<T>> = [];

  public function new(?sources:Array<Readable<T>>) {
    if (sources != null)
      for (source in sources) addSource(source);
    super();
  }

  public function addSource(source:Readable<T>) {
    sources.push(source);
    var cancel = source.onData.add(onData.emit);
    source.onClose.add(_ -> {
      cancel();
      sources.remove(source);
      if (sources.length == 0) close();
    });
  }
}
