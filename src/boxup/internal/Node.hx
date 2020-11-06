package boxup.internal;

import haxe.ds.Option;

typedef Node = {
  public final pragma:Option<String>;
  public final block:String;
  public final properties:Array<Property>;
  public final children:Array<Node>;
  public final pos:Position;
}
