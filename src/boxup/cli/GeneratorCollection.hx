package boxup.cli;

import boxup.definition.Definition;

@:forward(get, set, iterator, keyValueIterator)
abstract GeneratorCollection<T>(Map<String, (defintion:Definition)->Generator<T>>)
  from Map<String, (defintion:Definition)->Generator<T>>
{
  public inline function new(?definitions) {
    this = definitions != null ? definitions : [];
  }

  public function getNames() {
    return [ for (key in this.keys()) key ];
  }
}
