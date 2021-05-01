package boxup.cli;

import boxup.core.Chunk;
import boxup.core.Readable;

using boxup.core.Stream;

class ReporterStream {
  public static function pipeChunkThroughReporter<T>(stream:Readable<Chunk<T>>, reporter:Reporter) {
    return stream.pipe(Stream.through((reader, chunk:Chunk<T>) -> {
      chunk.result.handleValue(_ -> reader.push(chunk));
      chunk.result.handleError(error -> {
        reporter.report(error, chunk.source);
        reader.push(chunk);
      });
    }));
  }
}
