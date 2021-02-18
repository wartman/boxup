package boxup;

import boxup.Parser.Source;

interface Reporter {
  public function report(errors:Array<Error>, source:Source):Void;
}
