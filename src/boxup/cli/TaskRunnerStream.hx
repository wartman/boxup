package boxup.cli;

import boxup.cli.nodes.FilteredNodeStream;
import boxup.core.*;
import boxup.core.AbstractStream;
import boxup.cli.loader.DirectoryLoader;

class TaskRunnerStream extends AbstractStream<Chunk<Task>, Chunk<Output>> {
  public function write(chunk:Chunk<Task>) {
    chunk.result.handleValue(task -> {
      var loader = new DirectoryLoader(task.source);
      var scanner = Scanner.toStream();
      
      scanner
        .map(new FilteredNodeStream(task.context.definitions, task.filter))
        .map(new CompileStep(task.context.definitions.validate))
        .map(new CompileStep(task.generator.generate))
        .pipe(new WriteStream((chunk:Chunk<String>) -> {
          forward({
            result: chunk.result.map(content -> Ok({
              task: task,
              content: content
            })),
            source: chunk.source
          });
        }));
      
      loader.pipe(scanner);
      loader.load();
    });

    chunk.result.handleError(error -> forward({
      result: Fail(error),
      source: chunk.source
    }));
  }
}
