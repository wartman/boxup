package boxup;

typedef ValidationResult = {
  public final hasErrors:Bool;
  public final errors:Null<Array<Error>>;
}

interface Validator {
  public function validate(nodes:Array<Node>):ValidationResult;
}
