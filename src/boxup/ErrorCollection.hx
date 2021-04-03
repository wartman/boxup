package boxup;

@:forward(iterator)
abstract ErrorCollection(Array<Error>) from Array<Error> to Array<Error> {
  inline public static function empty() {
    return new ErrorCollection([]);
  }

  @:from public static inline function ofError(error:Error) {
    return new ErrorCollection([ error ]);
  }
  
  public inline function new(errors) {
    this = errors;
  }

  public inline function hasErrors() {
    return this.length > 0;
  }

  public inline function add(error:Error) {
    this.push(error);
  }

  public inline function merge(errors:ErrorCollection) {
    return this.concat(errors);
  }

  public inline function addAll(errors:ErrorCollection) {
    for (e in errors) add(e);
    return this;
  }

  public inline function toString() {
    return this.map(e -> e.toString()).join('\n');
  }
}
