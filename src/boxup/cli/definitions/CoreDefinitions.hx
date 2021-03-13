package boxup.cli.definitions;

import boxup.cli.loader.StringMapLoader;

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
  [Child name=Link]
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
  [Meta/renderHint value=Header]
  [Child name=Paragraph]

[Block name=SubTitle]
  [Meta/renderHint value=SubHeader]
  [Child name=Paragraph]

[Block name=Section]
  [Meta/renderHint value=Section]
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
  [Meta/renderHint value=Link]
  [IdProperty name=href required=true]
  [Child name=Paragraph]
  [Child name=Image]

[Block name=Image]
  [Meta/renderHint value=Image]
  [Property name=src required=true]
  [Property name=alt required=true]

[Block name=List]
  [Meta/renderHint value=ListContainer]
  [EnumProperty name=type]
    [Option value=Ordered]
    [Option value=Unordered]
  [Child name=Item symbol="-"]

[Block name=Item]
  [Meta/renderHint value=ListItem]
  [Child name=Paragraph]
  [Child name=Image]
  [Child name=Section]
'

// @todo: maybe more?

]);