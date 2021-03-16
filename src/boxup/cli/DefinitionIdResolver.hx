package boxup.cli;

import haxe.ds.Option;

/**
  Implements a strategey for finiding a DefinitionId for a given Boxup 
  document. This could happen in a number of ways: from a filename
  (`document.${id}.box`), from one of the nodes in the document, whatever
  else you might want.
**/
interface DefinitionIdResolver {
  public final priority:Int;
  public function resolveDefinitionId(nodes:Array<Node>, source:Source):Option<DefinitionId>;
}
