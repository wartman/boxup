package boxup.cli;

import boxup.core.*;

class TaskStream extends AbstractStream<Chunk<Context>, Chunk<Task>> {
  final generators:Map<String, (defintion:Definition)->Generator<String>>;

  public function new(generators) {
    this.generators = generators;
    super();
  }
  
  public function write(chunk:Chunk<Context>) {
    chunk.result.handleValue(context -> {
      for (task in context.config.tasks) onData.emit({
        result: Ok({
          context: context,
          source: task.source,
          destination: task.destination,
          generator: new GeneratorFactory(context.definitions, generators.get(task.generator)),
          filter: task.filter,
          extension: task.extension
        }),
        source: chunk.source
      });
    });

    chunk.result.handleError(error -> forward({
      result: Fail(error),
      source: chunk.source
    }));
  }
}
