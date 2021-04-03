package boxup.cli;

@:structInit
class Config {
  public final definitionRoot:String;
  public final definitionSuffix:String;
  public final tasks:Array<ConfigTask>;
}

@:structInit
class ConfigTask {
  public final source:String;
  public final destination:String;
  public final generator:String;
  public final filter:Array<String>;
  public final extension:String;
}