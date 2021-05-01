package boxup.core;

typedef Duplex<T, R> = {
  public final writer:Writable<T>;
  public final reader:Readable<R>;
}
