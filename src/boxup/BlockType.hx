package boxup;

import boxup.internal.AstNode;

typedef BlockType = {
  public final __blockName:String;
  public function __createBlock(node:AstNode):Block;
}
