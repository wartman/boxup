package boxup;

class ErrorStream<T> extends StreamBase<T, T> {
  final reporter:Reporter;
  
  public function new(reporter) {
    this.reporter = reporter;
  }

  public function transform(result:Result<T>, source:Source) {
    result.handleError(errors -> reporter.report(errors, source));
    return result;
  }
}
