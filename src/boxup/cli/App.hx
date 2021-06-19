package boxup.cli;

import boxup.cli.loader.*;
import boxup.cli.resolver.*;
import boxup.cli.writer.*;
import boxup.reporter.*;
import boxup.generator.*;
import boxup.definition.DefinitionIdResolverCollection;

using boxup.stream.StreamTools;

class App {
  final generators:GeneratorCollection<String>;
  final loaderFactory:LoaderFactory;
  final resolver:DefinitionIdResolverCollection;
  final reporter:Reporter;

  public function new(?generators, ?loaderFactory, ?resolver, ?reporter) {
    this.generators = generators == null
      ? [
        'html' => HtmlGenerator.new,
        'md' => MarkdownGenerator.new,
        // 'json' => _ -> new JsonGenerator()
      ] : generators;
    this.loaderFactory = loaderFactory != null
      ? loaderFactory
      : DirectoryLoader.new;
    this.resolver = resolver != null
      ? resolver
      : [
        new FileNameResolver(),
        new DefaultResolver('markup') // Fallback
      ];
    this.reporter = reporter == null
      ? new VisualReporter()
      : reporter;
  }

  public function run(?root) {
    if (root == null) root = Sys.getCwd();

    var sources = new SourceCollection();
    var configLoader = new BoxConfigLoader(root, sources);
    
    Sys.println('');
    Sys.println('[Boxup]');
    Sys.println('Starting tasks...');

    var endpoint = configLoader
      .pipe(new Compiler(
        new ConfigGenerator(),
        new ConfigValidator(ConfigValidator.create(generators.getNames()))
      ))
      .pipe(new ContextStream(DirectoryLoader.new, resolver, sources))
      .pipe(new TaskStream(loaderFactory, generators))
      .output.through((output, data:Output<String>) -> {
        Sys.println('   Compiling: ${data.source.filename} into ${data.task.extension}');
        output.push(data);
      })
      .pipe(new ReporterStream(reporter, sources))
      .pipe(new FileWriter());

    
    endpoint.onClose.add(_ -> {
      Sys.println('------');
      Sys.println('Tasks complete.');
      Sys.exit(0);
    });
    endpoint.onError.add(_ -> {
      Sys.exit(1);
    });

    configLoader.load();
  }
}
