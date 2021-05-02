package boxup.stream;

class Stream {
  public static inline function map<In, Out>(stream:Readable<In>, transformer:(data:In)->Out):Readable<Out> {
    return stream.pipe(transform(transformer));
  }

  public static inline function finish<T>(reader:Readable<T>, write, ?end):Void {
    reader.into(new Writable(write, end));
  }

  @:noUsing
  public inline static function read<T>():Readable<T> {
    return new Readable();
  }

  @:noUsing
  public inline static function write<T>(write, ?end):Writable<T> {
    return new Writable(write, end);
  }

  @:noUsing
  public static function through<In, Out>(
    write:(reader:Readable<Out>, data:In)->Void, 
    ?end:(reader:Readable<Out>)->Void
  ):Duplex<In, Out> {
    var reader = new Readable();
    var writer = new Writable(
      data -> write(reader, data), 
      if (end != null) 
        () -> end(reader) 
      else 
        () -> reader.end()
    );

    writer.onClose.add(_ -> reader.close());

    return {
      reader: reader,
      writer: writer
    };
  }

  /**
    Handle a Chunk, automatically forwarding failures if encountered.
  **/
  @:noUsing
  public inline static function throughChunk<In, Out>(
    write:(reader:Readable<Chunk<Out>>, data:In, source:Source)->Void,
    ?end:(reader:Readable<Chunk<Out>>)->Void
  ):Duplex<Chunk<In>, Chunk<Out>> {
    return through(
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
  public inline static function transform<In, Out>(transform:(data:In)->Out) {
    return through((reader, data) -> reader.push(transform(data)));
  }

  @:noUsing
  public static function compose<T>(
    streams:Array<Readable<T>>,
    ?end:(reader:Readable<T>)->Void
  ):Duplex<T, T> {
    var remaining = streams.length;
    var pipe = through(
      (reader, data) -> reader.push(data),
      reader -> {
        if (remaining <= 0) {
          if (end != null) end(reader) else reader.end();
        }
      }
    );
    for (source in streams) {
      source.onEnd.add(_ -> remaining--); // needs to run first
      source.into(pipe.writer);
    }
    return pipe;
  }
}
