package boxup;

interface Validator {
  public function validate(nodes:Array<Node>, source:Source):Outcome<Array<Node>>;
}
