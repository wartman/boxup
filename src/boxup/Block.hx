package boxup;

// @todo: This seems like a strange intermediate step. Maybe we should skip this
//        and just give `Node` a `toJson` method? The Typer wouldn't return anything
//        -- it would just check the Nodes to make sure they're correct.
@:structInit
class Block {
  public final name:String;
  public final properties:Map<String, Dynamic>;
  public final children:Array<Block>;

  public function toJson():Dynamic {
    if (name == Builtin.text) {
      return properties.get(Builtin.textProperty);
    }

    var out = {
      name: name,
      properties: {},
      children: children.map(child -> child.toJson())
    };
    for (key => value in properties) {
      Reflect.setField(out.properties, key, value);
    }
    return out;
  }
}
