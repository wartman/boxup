package boxup;

enum ValidationResult {
  Passed;
  Failed(errors:Array<Error>);
}

interface Validator {
  public function validate(nodes:Array<Node>):ValidationResult;
}
