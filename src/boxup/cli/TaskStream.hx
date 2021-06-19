package boxup.cli;

import boxup.stream.Accumulator;
import haxe.ds.Option;
import boxup.cli.Config;
import boxup.definition.DefinitionId;
import boxup.definition.DefinitionCollection;
import boxup.definition.DefinitionCollectionValidator;
import boxup.stream.WriteStream;
import boxup.stream.Duplex;

using boxup.stream.StreamTools;

class TaskStream<T> extends Duplex<Context, Output<T>> {
  final loaderFactory:LoaderFactory;
  final generators:GeneratorCollection<T>;

  public function new(loaderFactory, generators) {
    super();
    this.loaderFactory = loaderFactory;
    this.generators = generators;
  }

  public function write(context:Context) {
    for (task in context.config.tasks) {
      runTask(task, context);
    }
    output.end();
  }

  function runTask(task:ConfigTask, context:Context) {
    var loader = loaderFactory(task.source, context.sources);
    var generatorFactory = generators.get(task.generator);
    var scanner = new Scanner();
    var parser = new Parser();
    var generators:Map<DefinitionId, Generator<T>> = [];
    var filter = createNodeFilter(context.definitions, task.filter);

    function getGeneratorForDefinition(nodes:Array<Node>):Option<Generator<T>> {
      return switch context.definitions.resolveDefinitionId(nodes) {
        case Some(id):
          if (!generators.exists(id)) switch context.definitions.getDefinition(id) {
            case Some(def):
              generators.set(id, generatorFactory(def));
            default:
          }
          var generator = generators.get(id);
          return generator != null 
            ? Some(generator)
            : None; 
        default:
          None;
      }
    }

    loader
      .pipe(scanner)
      .pipe(parser)
      .output.through((output, nodes:Array<Node>) -> {
        if (filter(nodes)) output.push(nodes);
      }).pipe(new WriteStream(nodes -> {
        var validator = new DefinitionCollectionValidator(context.definitions);
        var accumulate = new Accumulator(chunks -> output.push({
          chunks: chunks,
          task: task,
          source: context.sources.fromNodes(nodes)
        }));
        accumulate.onError.add(output.fail);
        
        switch getGeneratorForDefinition(nodes) {
          case Some(generator):
            validator
              .pipe(generator)
              .pipe(accumulate);
            
            validator.write(nodes);
          case None:
            output.fail(new Error(
              'Could not find a valid generator or definition',
              nodes[0].pos
            ));
        }
      }));

    loader.load();
  }

  inline function createNodeFilter(
    definitions:DefinitionCollection, 
    allowedIds:Array<DefinitionId>
  ) {
    return (nodes:Array<Node>) -> switch definitions.resolveDefinitionId(nodes) {
      case Some(id) if (!allowedIds.contains(id) && !allowedIds.contains('*')):
        false;
      case None if (!allowedIds.contains('*')): 
        false;
      default:
        true;
    };
  }
}
