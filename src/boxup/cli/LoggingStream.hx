package boxup.cli;

import boxup.stream.Readable;
import boxup.stream.Chunk;

using boxup.stream.Stream;

class LoggingStream {
  public static function pipeTasksThroughLogger<T>(stream:Readable<Chunk<Task<T>>>) {
    return stream.throughChunk((next, task:Task<T>, source) -> {
      Sys.println('------');
      Sys.println('Starting task: ${task.source} -> ${task.destination}');
      next.push({ result: Ok(task),  source: source });
    });
  }

  public static function pipeOutputThroughLogger<T>(stream:Readable<Chunk<Output<T>>>) {
    return stream.throughChunk((next, output:Output<T>, source) -> {
      Sys.println('   Compiling: ${source.filename} into ${output.task.extension}');
      next.push({ result: Ok(output), source: source });
    });
  }
}
