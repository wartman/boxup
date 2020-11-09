package boxup.cli;

import boxup.Source;
import boxup.ParserException;

interface Reporter {
  public function report(e:ParserException, source:Source):Void;
}
