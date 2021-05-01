package boxup.cli;

import boxup.definition.DefinitionId;

@:structInit
class Task<T> {
  public final context:Context;
  public final source:String;
  public final destination:String;
  public final generator:Generator<T>;
  public final filter:Array<DefinitionId>;
  public final extension:String;  
}
