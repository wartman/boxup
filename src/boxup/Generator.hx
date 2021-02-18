package boxup;

typedef GeneratorResult<T> = {
  public final hasErrors:Bool;
  public final errors:Null<Array<Error>>;
  public final result:T;
} 

interface Generator<T> {
  public function generate(nodes:Array<Node>):GeneratorResult<T>;
}
