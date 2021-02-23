package boxup;

using Lambda;

typedef Property = {
  public final name:String;
  public final value:Value;
  public final pos:Position;
}

typedef Value = {
  public final value:String;
  public final type:String;
  public final pos:Position;
} 

enum NodeType {
  Block(name:String);
  Arrow;
  Paragraph;
  Text;
}

@:structInit
class Node {
  public final type:NodeType;
  public final isTag:Bool = false;
  public final textContent:Null<String> = null;
  public final properties:Array<Property>;
  public final children:Array<Node>;
  public final pos:Position;

  // @todo: Think of a better way to do this?
  public function getProperty(name:String, def:String = null) {
    var prop = properties.find(p -> p.name == name);
    return prop == null ? def : prop.value.value;
  }
}
