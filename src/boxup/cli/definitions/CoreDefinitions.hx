package boxup.cli.definitions;

final coreDefinitionLoader = new StringMapLoader([
  'markup' => '
[/ Definitions for generic markup -- might be used anywhere
  Markdown would be. Designed to target HTML and Markdown
  outputs. ]

[Root]
  [Child name=Paragraph]
  [Child name=Header]
  [Child name=Title]
  [Child name=Section]
  [Child name=Link]
  [Child name=List]
  [Child name=Image]

[Paragraph name=Paragraph]
  [Child name=Link]

[Block name=Header]
  [Property name=id]
  [Child name=Paragraph]
  [Child name=Title]

[Block name=Title]
  [EnumProperty name=type]
    [Option value=Main]
    [Option value=Secondary]
    [Option value=Tertiary]
  [Child name=Paragraph]

[Block name=Section]
  [Property name=id]
  [Child name=Paragraph]
  [Child name=Header]
  [Child name=Title]
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

[Block name=Link isTag=true]
  [Property name=href required=true]
  [Child name=Paragraph]
  [Child name=Image]

[Block name=Image]
  [Property name=src required=true]
  [Property name=alt required=true]
  [Property name=href]

[Block name=List]
  [EnumProperty name=type]
    [Option value=Ordered]
    [Option value=UnOrdered]
  [EnumProperty name=order]
    [Option value=Desc]
    [Option value=Asc]
  [Child name=ListItem]

[Block name=ListItem]
  [Property name=id]
  [Child name=Paragraph]
  [Child name=Image]
  [Child name=Section]
'

// @todo: maybe more?

]);