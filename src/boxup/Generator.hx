package boxup;

interface Generator<T> {
  public function generate(nodes:Array<Node>, source:Source):Result<T>;
}
