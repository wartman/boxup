package boxup.cli;

interface Writer {
  public function write(path:String, content:String):Void;
}