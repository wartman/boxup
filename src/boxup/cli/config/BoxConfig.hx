package boxup.cli.config;

@:structInit
class BoxConfig {
  /**
    The folder Boxup should find definitions in. This might be the only
    value in a config.box at the moment.
  **/
  public final definitionRoot:String;

  /**
    The suffix definition files should use (e.g. 'foo.d.box`). 
    Defaults to `d`.
  **/
  public final definitionSuffix:String;
}

