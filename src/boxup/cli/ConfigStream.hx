package boxup.cli;

class ConfigStream extends AbstractStream<Result<Source>, Chunk<Config>> {
  final allowedGenerators:Array<String>;

  public function new(allowedGenerators) {
    this.allowedGenerators = allowedGenerators;
    super();
  }

  public function write(result:Result<Source>) {
    var scanner = new ScannerStream();
    scanner
      .map(new ParserStream())
      .map(new ValidatorStream(ConfigValidator.create(allowedGenerators)))
      .map(new GeneratorStream(new ConfigGenerator()))
      .pipe(new WriteStream(forward));
    scanner.write(result);
  }
}
