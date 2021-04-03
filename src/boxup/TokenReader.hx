package boxup;

class TokenReader extends ReadableBase<Array<Token>> {
  final sources:Array<Source>;

  public function new(sources) {
    this.sources = sources;
  }

  function handle(done:()->Void) {
    for (source in sources)
      for (writer in writers) 
        writer.write(new Scanner(source).scan(), source);
    done();
  }
}
