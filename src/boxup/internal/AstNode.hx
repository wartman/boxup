package boxup.internal;

typedef AstNode = {
  public final block:String;
  public final properties:Array<AstProperty>;
  public final children:Array<AstNode>;
  public final pos:Position;
}
