package boxup;

import boxup.internal.Position;

@:autoBuild(boxup.BlockBuilder.build())
interface Block {
  public final pos:Position;
}
