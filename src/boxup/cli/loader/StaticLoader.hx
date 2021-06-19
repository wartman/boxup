package boxup.cli.loader;

class StaticLoader extends Loader {
  final data:Array<Source>;

  public function new(data, sources) {
    super(sources);
    this.data = data;
  }
  
  function load() {
    var item = data.pop();
    while (item != null) {
      push(item);
      item = data.pop();
    }
    end();
    close();
  }
}
