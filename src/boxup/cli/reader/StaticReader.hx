package boxup.cli.reader;

class StaticReader extends ReadableBase<Array<Token>> {
  var source:Source;

  public function new(source) {
    this.source = source;
  }

  public function handle(done:()->Void) {
    dispatch(new Scanner(source).scan(), source);
    done();
  }
}
