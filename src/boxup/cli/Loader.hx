package boxup.cli;

interface Loader extends Readable<Result<Source>> {
  public function load():Void;
}
