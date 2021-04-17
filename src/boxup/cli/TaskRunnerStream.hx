package boxup.cli;

import boxup.cli.nodes.FilteredNodeStream;
import boxup.cli.loader.DirectoryLoader;

class TaskRunnerStream extends AbstractStream<Chunk<Task>, Chunk<Output>> {
  final loaderFactory:(root:String)->Loader;

  public function new(?loaderFactory) {
    this.loaderFactory = loaderFactory == null
      ? DirectoryLoader.new
      : loaderFactory;
    super();
  }

  public function write(chunk:Chunk<Task>) {
    chunk.result.handleValue(task -> {
      var loader = loaderFactory(task.source);
      var nodes = new FilteredNodeStream(task.context.manager, task.filter);
      
      nodes
        .map(new CompileStream(
          task.context.manager,
          task.generator
        ))
        .pipe(new WriteStream((chunk:Chunk<String>) -> {
          forward({
            result: chunk.result.map(content -> Ok({
              task: task,
              content: content
            })),
            source: chunk.source
          });
        }));
      
      loader.pipe(nodes);
      loader.load();
    });

    chunk.result.handleError(error -> forward({
      result: Fail(error),
      source: chunk.source
    }));
  }
}
