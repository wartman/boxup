package boxup.cli;

import boxup.stream.Chunk;
import boxup.stream.Readable;
import boxup.definition.DefinitionCollection;
import boxup.definition.DefinitionId;

using boxup.stream.Stream;
using boxup.cli.CompileStream;
using boxup.cli.NodeStream;

class TaskStream {
  public static function pipeContextIntoTasks<T>(
    stream:Readable<Chunk<Context>>,
    generators:GeneratorCollection<T>
  ) {
    return stream.pipe(createTaskStream(generators));
  }

  public static function pipeTaskIntoCompiler<T>(
    stream:Readable<Chunk<Task<T>>>,
    loaderFactory:(root:String)->Loader
  ) {
    return stream.pipe(Stream.throughChunk((next:Readable<Chunk<Output<T>>>, task:Task<T>, source:Source) -> {
      var loader = loaderFactory(task.source);
      
      loader.stream
        .pipeSourceThroughParser()
        .pipeNodesThroughFilter(createNodeFilter(task.context.definitions, task.filter))
        .pipeNodesIntoGenerator(task.context.definitions, task.generator)
        .into(Stream.write((chunk:Chunk<T>) -> next.push({
          source: chunk.source,
          result: chunk.result.map(content -> Ok({
            task: task,
            content: content
          }))
        })));
      
      loader.run();
    }));
  }

  @:noUsing
  public static inline function createNodeFilter(
    definitions:DefinitionCollection, 
    allowedIds:Array<DefinitionId>
  ) {
    return (nodes:Array<Node>, source:Source) -> switch definitions.resolveDefinitionId(nodes, source) {
      case Some(id) if (!allowedIds.contains(id) && !allowedIds.contains('*')):
        false;
      case None if (!allowedIds.contains('*')): 
        false;
      default:
        true;
    };
  }

  @:noUsing
  public static inline function createTaskStream<T>(generators:GeneratorCollection<T>) {
    return Stream.throughChunk((reader:Readable<Chunk<Task<T>>>, context:Context, source:Source) -> {
      for (task in context.config.tasks) reader.push({
        result: Ok({
          context: context,
          source: task.source,
          destination: task.destination,
          generator: new GeneratorFactory(
            context.definitions, 
            generators.get(task.generator)
          ),
          filter: task.filter,
          extension: task.extension
        }),
        source: source
      });
    });
  }
}
