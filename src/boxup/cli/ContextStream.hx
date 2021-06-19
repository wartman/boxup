package boxup.cli;

import boxup.stream.Duplex;
import boxup.definition.DefinitionGenerator;
import boxup.definition.DefinitionValidator;
import boxup.definition.DefinitionCollection;
import boxup.definition.DefinitionIdResolverCollection;
import boxup.stream.WriteStream;

using boxup.stream.StreamTools;

class ContextStream extends Duplex<Config, Context> {
  final loaderFactory:LoaderFactory;
  final resolver:DefinitionIdResolverCollection;
  final sources:SourceCollection;

  public function new(loaderFactory, resolver, sources) {
    this.loaderFactory = loaderFactory;
    this.resolver = resolver;
    this.sources = sources;
    super();
  }

  public function write(config:Config) {
    var context = new Context(
      config, 
      new DefinitionCollection(resolver),
      sources
    );
    var loader = loaderFactory(config.definitionRoot, context.sources);
    var compiler = new Compiler(
      new DefinitionGenerator(), 
      new DefinitionValidator()
    );

    loader
      .pipe(compiler)
      .pipe(new WriteStream(context.definitions.addDefinition));

    loader.onClose.add(_ -> {
      output.end(context);
      close();
    });
    
    loader.load();
  }
}