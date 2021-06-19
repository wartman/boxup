package boxup.cli;

@:forward(get, set, iterator, keyValueIterator)
abstract GeneratorCollection<T>(Map<String, GeneratorFactory<T>>)
  from Map<String, GeneratorFactory<T>>
{
  public inline function new(?definitions) {
    this = definitions != null ? definitions : [];
  }

  public function getNames() {
    return [ for (key in this.keys()) key ];
  }
}
