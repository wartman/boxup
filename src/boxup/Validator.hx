package boxup;

interface Validator {
  public function validate(nodes:Array<Node>, source:Source):Result<Array<Node>>;
}
