package boxup.cli;

import boxup.stream.Readable;

abstract class Loader extends Readable<Source> {
  abstract public function load():Void;
}
