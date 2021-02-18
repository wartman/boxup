package boxup;

interface Reporter {
  public function report(errors:Array<Error>, source:Source):Void;
}
