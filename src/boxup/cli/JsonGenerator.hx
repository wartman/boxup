package boxup.cli;

import haxe.Json;

class JsonGenerator implements Generator {
  final options:{
    formated:Bool
  };
  
  public function new(options) {
    this.options = options;
  }

  public function generate(blocks:Array<Block>):String {
    return Json.stringify(blocks.map(b -> b.toJson()), options.formated ? '  ' : null);
  }
}