package boxup.cli;

import boxup.cli.loader.DirectoryLoader;

class ContextStream extends AbstractStream<Chunk<Config>, Chunk<Context>> {
  final resolver:DefinitionIdResolverCollection;
  final loaderFactory:(root:String)->Loader;

  public function new(resolver, ?loaderFactory) {
    this.resolver = resolver;
    this.loaderFactory = loaderFactory == null
      ? DirectoryLoader.new
      : loaderFactory;
    super();
  }

  public function write(chunk:Chunk<Config>) {
    chunk.result.handleValue(config -> {
      var errorsEncountered:Bool = false;
      var reader = loaderFactory(config.definitionRoot);
      var manager = new DefinitionManager(resolver);
      var scanner = new ScannerStream();
  
      scanner
        .map(new ParserStream())
        .map(new ValidatorStream(DefinitionValidator.validator))
        .map(new GeneratorStream(new DefinitionGenerator()))
        .pipe(new WriteStream((chunk:Chunk<Definition>) -> {
          chunk.result
            .handleValue(manager.addDefinition)
            .handleError(error -> {
              errorsEncountered = true;
              forward({
                result: Fail(error),
                source: chunk.source
              });
            });
        }, () -> {
          if (!errorsEncountered) forward({
            result: Ok({
              config: config,
              definitions: manager
            }),
            source: chunk.source
          });
        }));
  
      reader.pipe(scanner);
      reader.load();
    });
    chunk.result.handleError(error -> {
      onData.emit({
        result: Fail(error),
        source: chunk.source
      });
    });
  }
}
