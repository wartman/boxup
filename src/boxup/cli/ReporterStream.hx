package boxup.cli;

import boxup.stream.Duplex;

class ReporterStream<T> extends Duplex<Output<T>, Output<T>> {
  final reporter:Reporter;

  public function new(reporter) {
    super();
    this.reporter = reporter;
    onError.add(handleError);
  }

  public function write(data) {
    output.push(data);
  }

  function handleError(error:ErrorCollection) {
    for (e in error) reporter.report(e);
  }
}
