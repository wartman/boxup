package boxup;

import boxup.internal.ParserException;
import boxup.internal.AstNode;

using Lambda;

@:genericBuild(boxup.ParserBuilder.build())
class Parser<Rest> {}

class ParserBase {
  public final blockTypes:Array<BlockType> = [];

  public function parse(nodes:Array<AstNode>):Array<Block> {
    return nodes.map(parseNode);
  }

  public function parseNode(node:AstNode):Block {
    return switch blockTypes.find(b -> b.__blockName == node.block) {
      case null:
        throw new ParserException(
          'Invalid block: the block [' + node.block + '] is not allowed here.',
          node.pos
        );
      case blockType:
        return blockType.__createBlock(node);
    }
  }
}
