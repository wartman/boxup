package boxup;

import boxup.internal.AstNode;
import boxup.Parser;

// THIS IS A BAD WAY TO DO THIS.
//
// Rethink how this should work.
@:genericBuild(boxup.ChildrenBuilder.build())
class Children<Rest> {}

class ChildrenBase {
  public final parser:ParserBase;
  public final children:Array<Block>;

  public function new(nodes:Array<AstNode>, parser) {
    this.parser = parser;
    this.children = parser.parse(nodes);
  }
}
