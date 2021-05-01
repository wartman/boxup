package boxup.cli;

import boxup.core.Readable;

abstract class Loader {
  public final stream:Readable<Result<Source>> = new Readable();

  public function new() {}

  abstract function load(next:(data:Result<Source>)->Void, end:()->Void):Void;

  public function run() {
    load(stream.push, () -> {
      stream.end();
      stream.close();
    });
  }
}
