import boxup.*;
import boxup.block.*;

class Comic implements Block {
  @prop var title:String;
  @prop var author:String;
  @prop var version:Int = 1;
  @prop var date:Date = Date.now();
}

class Page implements Block {
  @prop var description:String = null;
  @children var children:Children<Panel, Notes>;
}

class Notes implements Block {
  @content var content:Text;
}

class Panel implements Block {
  @children var children:Children<Text, Notes, Dialog, Caption>;
}

class Caption implements Block {
  @content var content:Text;
}

class Dialog implements Block {
  @prop var character:String;
  @children var children:Children<Text, Attached, Mood, Notes>;
}

class Attached implements Block {
  @children var children:Children<Text, Mood, Notes>;
}

class Mood implements Block {
  @prop var description:String;
  @content var content:Text;
}
