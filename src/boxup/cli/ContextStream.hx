package boxup.cli;

import boxup.stream.Chunk;
import boxup.stream.Readable;
import boxup.definition.DefinitionCollection;
import boxup.definition.Definition;
import boxup.definition.DefinitionGenerator;
import boxup.definition.DefinitionIdResolverCollection;
import boxup.definition.DefinitionValidator.validator;

using boxup.stream.Stream;
using boxup.cli.CompileStream;

class ContextStream {
  public static function pipeSourceIntoContext(
    stream:Readable<Result<Source>>,
    allowedGenerators,
    loaderFactory,
    resolver
  ) {
    var configStream = stream.pipeSourceIntoGenerator(
      ConfigValidator.create(allowedGenerators),
      new ConfigGenerator()
    );
    return pipeConfigIntoContext(configStream, loaderFactory, resolver);
  }

  public static function pipeConfigIntoContext(
    configStream:Readable<Chunk<Config>>, 
    loaderFactory:(root:String)->Loader, 
    resolver:DefinitionIdResolverCollection
  ) {
    return configStream
      .throughChunk((next, config:Config, source:Source) -> {
        var errorsEncountered:Bool = false;
        var loader = loaderFactory(config.definitionRoot); 
        var context = new Context(
          config, 
          new DefinitionCollection(resolver)
        );
        
        loader.stream
          .pipeSourceIntoGenerator(validator, new DefinitionGenerator())
          .through((next:Readable<Chunk<Context>>, chunk:Chunk<Definition>) -> {
            chunk.result.handleValue(context.definitions.addDefinition);
            chunk.result.handleError(error -> {
              errorsEncountered = true;
              next.push({
                result: Fail(error),
                source: source
              });
            });
          }, (next:Readable<Chunk<Context>>) -> {
            if (!errorsEncountered) next.push({
              result: Ok(context),
              source: source
            });
          })
          .pipe(Stream.write(next.push));

        loader.run();
      }); 
  }
}
