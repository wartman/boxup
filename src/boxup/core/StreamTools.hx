package boxup.core;

class StreamTools {
  public static function pipeReadableToWriteable<T>(
    source:Readable<T>,
    target:Writable<T>
  ) {
    if (!source.isReadable()) return target;
    if (!target.isWritable()) return target;

    source.onData.add(data -> target.write(data));
    source.onClose.add(_ -> target.end());

    return target;
  }
}
