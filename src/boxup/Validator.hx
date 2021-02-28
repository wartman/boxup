package boxup;

interface Validator {
  public function validate(nodes:Array<Node>):Outcome<Array<Node>>;
}
