package boxup.stream;

class Stream {
  public static inline function map<In, Out>(stream:Readable<In>, transform:(data:In)->Out):Readable<Out> {
    return through(stream, (reader, data) -> reader.push(transform(data)));
  }

  public static function through<In, Out>(
    stream:Readable<In>, 
    write:(reader:Readable<Out>, data:In)->Void,
    ?end:(reader:Readable<Out>)->Void
  ):Readable<Out> {
    var reader = new Reader();
    var writer = new Writer(
      data -> write(reader, data), 
      if (end != null) 
        () -> end(reader) 
      else 
        () -> reader.end()
    );
    
    writer.onClose.add(_ -> reader.close());

    stream.pipe(writer);

    return reader;
  }

  public static inline function finish<T>(reader:Readable<T>, write, ?end):Void {
    reader.pipe(new Writer(write, end));
  }

  @:noUsing
  public inline static function read<T>():Readable<T> {
    return new Reader();
  }

  @:noUsing
  public inline static function write<T>(write, ?end):Writable<T> {
    return new Writer(write, end);
  }

  /**
    Handle a Chunk, automatically forwarding failures if encountered.
  **/
  public inline static function throughChunk<In, Out>(
    stream:Readable<Chunk<In>>,
    write:(reader:Readable<Chunk<Out>>, data:In, source:Source)->Void,
    ?end:(reader:Readable<Chunk<Out>>)->Void
  ):Readable<Chunk<Out>> {
    return through(
      stream,
      (reader, chunk:Chunk<In>) -> {
        chunk.result.handleValue(value -> write(reader, value, chunk.source));
        chunk.result.handleError(error -> reader.push({
          result: Fail(error),
          source: chunk.source
        }));
      },
      end
    );
  }

  @:noUsing
  public static function compose<T>(
    streams:Array<Readable<T>>,
    ?end:(reader:Readable<T>)->Void
  ):Readable<T> {
    var remaining = streams.length;
    var reader = new Reader();
    var writer = new Writer(data -> reader.push(data), () -> {
      if (remaining <= 0) {
        if (end != null) end(reader) else reader.end();
      }
    });

    writer.onClose.add(_ -> reader.close());

    for (source in streams) {
      source.onEnd.add(_ -> remaining--); // needs to run first
      source.pipe(writer);
    }

    return reader;
  }
}
