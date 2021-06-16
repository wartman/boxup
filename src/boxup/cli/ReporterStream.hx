package boxup.cli;

import boxup.stream.Chunk;
import boxup.stream.Readable;

using boxup.stream.Stream;

class ReporterStream {
  public static function pipeChunkThroughReporter<T>(stream:Readable<Chunk<T>>, reporter:Reporter) {
    return stream.through((reader, chunk:Chunk<T>) -> {
      chunk.result.handleError(error -> reporter.report(error, chunk.source));
      reader.push(chunk);
    });
  }
}
