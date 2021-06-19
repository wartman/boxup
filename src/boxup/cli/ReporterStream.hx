package boxup.cli;

import boxup.stream.Duplex;

class ReporterStream<T> extends Duplex<Output<T>, Output<T>> {
  final reporter:Reporter;
  final sources:SourceCollection;

  public function new(reporter, sources) {
    super();
    this.reporter = reporter;
    this.sources = sources;
    onError.add(handleError);
  }

  public function write(data) {
    output.push(data);
  }

  function handleError(error:ErrorCollection) {
    for (e in error) {
      var source = sources.get(e.pos.file);
      reporter.report(e, source);
    }
  }
}
