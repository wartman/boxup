package boxup.cli;

import boxup.cli.Config;

typedef Output<T> = {
  public final task:ConfigTask;
  public final chunks:Array<T>;
  public final source:Source;
}
