package boxup;

using StringTools;

@:structInit
class Source {
  public final filename:String;
  public final content:String;

  public function fixLineEndings():Source {
    // @todo: something more robust
    return {
      filename: filename,
      content: content.replace('\r\n', '\n')
    };
  }
}
