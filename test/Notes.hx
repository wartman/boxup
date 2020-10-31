import boxup.Block;
import boxup.Children;
import boxup.block.Paragraph;

class Notes implements Block {
  @children var content:Children<Paragraph>;
}
