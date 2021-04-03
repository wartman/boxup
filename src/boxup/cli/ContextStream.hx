package boxup.cli;

import boxup.cli.reader.DirectoryReader;

class ContextStream 
  extends ReadableBase<Context>
  implements Stream<Config, Context> 
{
  final manager:DefinitionManager;
  final results:Array<StreamResult<Config>> = [];

  public function new(resolver:DefinitionIdResolverCollection) {
    this.manager = new DefinitionManager(resolver);
  }

  public function write(config:Result<Config>, source:Source) {
    results.push({
      result: config,
      source: source
    });
  }

  public function handle(done:()->Void) {
    var await = results.length;
    var readers:Array<()->Void> = [];

    for (item in results) switch item.result {
      case Ok(config):
        var reader = new DirectoryReader(config.definitionRoot);
        
        reader
          .pipe(new NodeStream())
          .pipe(new ValidatorStream(DefinitionValidator.validator))
          .pipe(new GeneratorStream(new DefinitionGenerator()))
          .into(manager);

        reader.onDrained(() -> {
          await--;
          dispatch(Ok({ config: config, definitions: manager }), Source.none());
          if (await <= 0) done();
        });
        
        readers.push(reader.read);
     
      case Fail(err):
        await--;
        dispatch(Fail(err), item.source);
    }

    if (readers.length == 0 || await <= 0) 
      done();
    else 
      for (read in readers) read();
  }
}
