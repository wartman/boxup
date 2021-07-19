package boxup.stream;

class StreamTools {
  public static inline function map<In, Out>(stream:Readable<In>, transform:(data:In)->Out):Readable<Out> {
    return through(stream, (reader, data) -> reader.push(transform(data)));
  }

  public static inline function handleError<T>(stream:Readable<T>, handler):Readable<T> {
    stream.onError.add(handler);
    return stream;
  }

  public static function forwardListeners<T, R>(writer:Writable<T>, reader:Readable<R>) {
    var removeErrorHandler = writer.onError.add(reader.onError.emit);
    writer.onClose.add(_ -> {
      reader.close();
      removeErrorHandler();
    });
  }

  public static function through<In, Out>(
    stream:Readable<In>, 
    write:(reader:Readable<Out>, data:In)->Void,
    ?end:(reader:Readable<Out>)->Void
  ):Readable<Out> {
    var reader = new ReadStream();
    var writer = new WriteStream(
      data -> write(reader, data), 
      if (end != null) 
        () -> end(reader) 
      else 
        () -> reader.end()
    );
    
    forwardListeners(writer, reader);
    stream.pipe(writer);

    return reader;
  }

  public static inline function finish<T>(reader:Readable<T>, write, ?end):Void {
    reader.pipe(new WriteStream(write, end));
  }

  @:noUsing
  public inline static function read<T>():Readable<T> {
    return new ReadStream();
  }

  @:noUsing
  public inline static function write<T>(write, ?end):Writable<T> {
    return new WriteStream(write, end);
  }

  @:noUsing
  public static function compose<T>(
    streams:Array<Readable<T>>,
    ?end:(reader:Readable<T>)->Void
  ):Readable<T> {
    var remaining = streams.length;
    var reader = new ReadStream();
    var writer = new WriteStream(data -> reader.push(data), () -> {
      if (remaining <= 0) {
        if (end != null) end(reader) else reader.end();
      }
    });

    forwardListeners(writer, reader);
    
    for (source in streams) {
      source.onEnd.add(_ -> remaining--); // needs to run first
      source.pipe(writer);
    }

    return reader;
  }
}
