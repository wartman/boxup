import boxup.Block;
import boxup.Children;

class Page implements Block {
  @children var content:Children<Panel, Notes>;
}
