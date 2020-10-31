import boxup.Block;
import boxup.Children;
import boxup.block.Paragraph;

class Panel implements Block {
  @children var children:Children<Dialog, Notes, Paragraph>;
}

