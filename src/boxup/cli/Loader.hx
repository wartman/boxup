package boxup.cli;

import boxup.core.Readable;

interface Loader extends Readable<Source> {
  public function load():Void;
}
