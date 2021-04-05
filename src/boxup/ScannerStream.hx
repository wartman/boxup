package boxup;

class ScannerStream extends AbstractStream<Result<Source>, Chunk<Array<Token>>> {
  public function write(result:Result<Source>) {
    result.handleValue(source -> forward({
      result: new Scanner(source).scan(),
      source: source
    }));
    result.handleError(err -> forward({
      result: Fail(err),
      source: Source.none()
    }));
  }
}
