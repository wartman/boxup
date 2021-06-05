package boxup.cli;

import boxup.stream.Readable;
import boxup.stream.Reader;

abstract class Loader {
  public final stream:Readable<Result<Source>>;

  public function new() {
    stream = new Reader();
  }

  abstract function load(next:(data:Result<Source>)->Void, end:()->Void):Void;

  public function run() {
    load(stream.push, () -> {
      stream.end();
      stream.close();
    });
  }
}
