package boxup.cli;

@:structInit
class Task {
  public final context:Context;
  public final source:String;
  public final destination:String;
  public final generator:Generator<String>;
  public final filter:Array<DefinitionId>;
  public final extension:String;
}
