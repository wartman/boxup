package boxup.stream;

typedef Chunk<T> = {
  public final result:Result<T>;
  public final source:Source;
}
