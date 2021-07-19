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

    var configLoader = new BoxConfigLoader(root);
    
    Sys.println('');
    Sys.println('[Boxup]');
    Sys.println('Starting tasks...');

    var endpoint = configLoader
      .pipe(new Compiler(
        new ConfigGenerator(),
        new ConfigValidator(ConfigValidator.create(generators.getNames()))
      ))
      .pipe(new ContextStream(DirectoryLoader.new, resolver))
      .pipe(new TaskStream(loaderFactory, generators))
      .pipe(new ReporterStream(reporter))
      .output.through((output, data:Output<String>) -> {
        Sys.println('   Compiling: ${data.source.filename} into ${data.task.extension}');
        output.push(data);
      })
      .pipe(new FileWriter());

    
    endpoint.onClose.add(_ -> {
      Sys.println('------');
      Sys.println('Tasks complete.');
      Sys.exit(0);
    });

    configLoader.load();
  }
}
