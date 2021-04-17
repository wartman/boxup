package boxup.cli;

class ConfigStream extends AbstractStream<Result<Source>, Chunk<Config>> {
  final allowedGenerators:Array<String>;

  public function new(allowedGenerators) {
    this.allowedGenerators = allowedGenerators;
    super();
  }

  public function write(result:Result<Source>) {
    var nodes = new NodeStream();
    nodes
      .map(new CompileStream(
        ConfigValidator.create(allowedGenerators),
        new ConfigGenerator()
      ))
      .pipe(new WriteStream(forward));
    nodes.write(result);
  }
}
