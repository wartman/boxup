package boxup.cli.loader;

import boxup.core.ReadStream;

class StaticLoader extends ReadStream<Source> implements Loader {
  final data:Array<Source>;

  public function new(data) {
    this.data = data;
    super();
  }
  
  public function load() {
    var item = data.pop();
    while (item != null) {
      onData.emit(item);
      item = data.pop();
    }
    close();
  }
}
