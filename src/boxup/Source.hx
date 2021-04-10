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
  
  var _tokens:Result<Array<Token>>;
  public var tokens(get, never):Result<Array<Token>>;
  function get_tokens() {
    if (_tokens == null) {
      _tokens = new Scanner(this).scan();
    }
    return _tokens;
  }
}
