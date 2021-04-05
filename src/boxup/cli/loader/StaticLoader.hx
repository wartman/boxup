package boxup.cli.loader;

class StaticLoader extends ReadStream<Result<Source>> implements Loader {
  final data:Array<Source>;

  public function new(data) {
    this.data = data;
    super();
  }
  
  public function load() {
    var item = data.pop();
    while (item != null) {
      onData.emit(Ok(item));
      item = data.pop();
    }
    close();
  }
}
