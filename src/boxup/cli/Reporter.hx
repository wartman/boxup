package boxup.cli;

import boxup.internal.Source;
import boxup.internal.ParserException;

interface Reporter {
  public function report(e:ParserException, source:Source):Void;
}
