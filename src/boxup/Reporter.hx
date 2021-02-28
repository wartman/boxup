package boxup;

interface Reporter {
  public function report(error:ErrorCollection, source:Source):Void;
}
