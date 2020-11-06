package boxup;

import boxup.internal.Node;

typedef BlockType = {
  public final __blockName:String;
  public function __createBlock(node:Node):Block;
}
