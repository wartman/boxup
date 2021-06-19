package boxup;

import boxup.stream.Duplex;

abstract class Generator<T> extends Duplex<Array<Node>, T> {
  public function write(nodes) {
    generate(nodes);
  }

  abstract private function generate(nodes:Array<Node>):Void;
}
