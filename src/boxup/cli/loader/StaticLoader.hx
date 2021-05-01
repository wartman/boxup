package boxup.cli.loader;

class StaticLoader extends Loader {
  final data:Array<Source>;

  public function new(data) {
    this.data = data;
    super();
  }
  
  function load(next:(data:Result<Source>)->Void, end:()->Void) {
    var item = data.pop();
    while (item != null) {
      next(Ok(item));
      item = data.pop();
    }
    end();
  }
}
