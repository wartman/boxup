package boxup;

using Lambda;

typedef Property = {
  public var name:String;
  public var value:Value;
  public var pos:Position;
}

typedef Value = {
  public var value:String;
  public var type:String;
  public var pos:Position;
} 

enum NodeType {
  Block(name:String);
  Paragraph;
  Text;
}

@:structInit
class Node {
  public var type:NodeType;
  public var id:Null<Value> = null;
  public var isTag:Bool = false;
  public var textContent:Null<String> = null;
  public var properties:Array<Property>;
  public var children:Array<Node>;
  public var pos:Position;

  // @todo: Think of a better way to do this?
  public function getProperty(name:String, def:String = null) {
    var prop = properties.find(p -> p.name == name);
    return prop == null ? def : prop.value.value;
  }
}
