package boxup.cli.definitions;

final coreDefinitionLoader = new StringMapLoader([
  'markup' => '
[/ 
 / Definitions for generic markup -- might be used anywhere
 / Markdown would be. Designed to target HTML and Markdown
 / outputs. 
 /]

[Root]
  [Child name=Paragraph]
  [Child name=Header]
  [Child name=Title]
  [Child name=SubTitle]
  [Child name=Section symbol="#"]
  [Child name=Link symbol="@"]
  [Child name=List]
  [Child name=Image]

[Block name=Paragraph kind=Paragraph]
  [Child name=Link]

[Block name=Header]
  [IdProperty name=id]
  [Child name=Paragraph]
  [Child name=Title]
  [Child name=SubTitle]

[Block name=Title]
  [RenderHint.Header]
  [Child name=Paragraph]

[Block name=SubTitle]
  [RenderHint.SubHeader]
  [Child name=Paragraph]

[Block name=Section]
  [RenderHint.Section]
  [IdProperty name=title]
  [Child name=Paragraph]
  [Child name=Header]
  [Child name=Title]
  [Child name=SubTitle]
  [Child name=Link]
  [Child name=List]
  [Child name=Image]

[Block name=Note]
  [Property name=id]
  [Child name=Paragraph]
  [Child name=Title]
  [Child name=Link]
  [Child name=List]
  [Child name=Image]

[Block name=Link kind=Tag]
  [RenderHint.Link]
  [IdProperty name=href required=true]
  [Child name=Paragraph]
  [Child name=Image]

[Block name=Image]
  [RenderHint.Image]
  [Property name=src required=true]
  [Property name=alt required=true]
  [Property name=href]

[Block name=List]
  [RenderHint.ListContainer]
  [EnumProperty name=type]
    [Option value=Ordered]
    [Option value=Unordered]
  [Child name=Item symbol="-"]

[Block name=Item]
  [RenderHint.ListItem]
  [Child name=Paragraph]
  [Child name=Image]
  [Child name=Section]
'

// @todo: maybe more?

]);