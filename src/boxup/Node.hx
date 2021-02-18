package boxup;

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
  Text;
  Paragraph;
}

typedef Node = {
  public final type:NodeType;
  @:oprional public final textContent:Null<String>;
  public final properties:Array<Property>;
  public final children:Array<Node>;
  public final pos:Position;
}
