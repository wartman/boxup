package boxup;

using Lambda;
using StringTools;

class Source {
  public static function none() {
    return new Source('<unknown>', '');
  }

  public final filename:String;
  public final content:String;

  public function new(filename, content) {
    this.filename = filename;
    this.content = content;
  }
}
