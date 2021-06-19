package boxup;

import boxup.stream.Duplex;

abstract class Validator extends Duplex<Array<Node>, Array<Node>> {
  public function write(nodes) {
    validate(nodes);
  }

  public function fail(error:ErrorCollection) {
    output.fail(error);
    close();
  }

  public function pass(nodes) {
    output.push(nodes);
  }

  abstract private function validate(nodes:Array<Node>):Void;
}
