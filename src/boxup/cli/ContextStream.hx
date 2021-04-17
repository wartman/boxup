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
      var nodes = new NodeStream();
  
      nodes
        .map(new CompileStream(
          DefinitionValidator.validator,
          new DefinitionGenerator()
        ))
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
              manager: manager
            }),
            source: chunk.source
          });
        }));
  
      reader.pipe(nodes);
      reader.load();
    });
    chunk.result.handleError(error -> {
      forward({
        result: Fail(error),
        source: chunk.source
      });
    });
  }
}
