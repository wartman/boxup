package boxup.stream;

class Accumulator<T> extends Writable<T> {
  var data:Array<T> = [];
  final handler:(data:Array<T>)->Void;

  public function new(handler) {
    this.handler = handler;
  }

  public function write(item) {
    data.push(item);
  }

  override function finish() {
    handler(data);
    data = [];
  }
}
