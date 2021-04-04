package boxup;

import boxup.core.*;

class ScannerStream extends AbstractStream<Source, Chunk<Array<Token>>> {
  public function write(source:Source) {
    forward({
      result: new Scanner(source).scan(),
      source: source
    });
  }
}
