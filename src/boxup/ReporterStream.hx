package boxup;

import boxup.core.*;

class ReporterStream<T> extends AbstractStream<Chunk<T>, Chunk<T>> {
  final reporter:Reporter;

  public function new(reporter:Reporter) {
    this.reporter = reporter;
    super();
  }

  public function write(chunk:Chunk<T>) {
    chunk.result.handleError(error -> reporter.report(error, chunk.source));
    forward(chunk);  
  }
}
