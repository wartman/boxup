[boxup]
=======

Typed markup.

Example
-------

Here's an example of a simple Boxup document: 

```boxup

[/ Comments look like this! /]

[Article]
  title = Hello world!
  slug = hello_world

[Section/one]
  [Header] Hello!

  Boxup is a very simple markup language based around square brackets
  and indentation. What sets it apart is that it is typed and uses
  definition files to validate your markup.

```

Syntax
------

> Note: this is very much a work in progress. It'll probably be broken out into neater sections later, or replaced by the stuff in the `docs` directory.

Boxup has a very simple, indentation-based syntax. It's based around _blocks_, which are started by an identifier in square brackets called the _block declaration_:

```boxup
[Block]
```

There are two kinds of blocks: _property blocks_ and _content blocks_. A property block simply contains a list of properties:

```boxup
[Block]
  foo = foo
  bar = bar
```

A content block can contain a mix of paragraphs and child blocks:

```boxup
[ParentBlock]
  Some text

  [ChildBlock]
    Some other content

    Note the indentation here -- this will all go into the ChildBlock.

  Back to the ParentBlock.
```

If the compiler finds a property assignment (e.g. `foo = bar`) right after the block declaration it will treat the block as a property block. This means the following will throw an error:

```boxup
[Block]
  foo = foo

  And then a paragraph.
```

... and that `foo = foo` will be treated as if it was text in this case:

```boxup
[Block]
  A paragraph.
  
  foo = foo
```

If you need to use properties in a content block, you can place them inside the block declaration:

```boxup
[Block foo = foo bar = bar]
  A paragraph.

  And some more content.
```

You'll note that we don't use commas or other delimiters. Instead, properties are split by _whitespace_ (spaces, newlines or comments) when they're inside the block declaration and by _newlines_ when they're in a property block.

```boxup
[Block foo='This has spaces so it needs to be in quotes to work' bar = bin
  other = "newlines are fine inside the brackets too"
]

[Block]
  foo = This has spaces but it's fine here!
  bin = "
    If we need to have newlines in our value
    We need to use quotes.

    Note that using single or double quotes preserves indentation, and
    that all strings can contain newlines.
  "
  baf = |
    If you want to strip indentation from content, use the special
    pipe operator. It'll strip newlines and whitespace from the
    start and end of the string, and any whitespace from the
    start of each line based on the indentation of the
    _first_ line.
  |
  bar = bar
```

Blocks may also have an id, which are placed after the block identifier using a forward slash (`/`):

```boxup
[Block/id]
[Block/underlines_can_be_used_to_indicate_spaces_for_ids]
[Block/'Or you can just use a string']
```

Blocks can also use "_symbols_" instead of block identifiers, in which case the slash is not needed for the id:

```boxup
[@id]
[#some_other_id]
[!'This is valid too']
```

The current list of valid symbols is as follows:

```
!, @, #, $, %, ^, &, *, :, <, >, ?, +
```

These are handy for things like section headers, so you might write `[#About_Foo]` instead of `[Section/About_Foo]`.

Paragraphs are the final part of the Boxup syntax. As far as Boxup is concerned, a _paragraph_ is any text before at least two newlines. For example, here are two boxup paragraphs:

```boxup
this is
the first
paragraph.

this is the second
paragraph.
```

When parsed, all newlines will be removed and replaced with a single space.

> Note: Eventually you'll be able to preserve newlines by placing a `\` at the end of the string, but that isn't implemented yet.

```
this is the first paragraph.

this is the second paragraph.
```

When a paragraph is the child of a block, its indentation will also be removed:

```boxup
[ParentBlock]
  [SomeBlock]
    this is
    the first
    paragraph.
    It is a child of SomeBlock.

    this is the second
    paragraph. Also a child
    of SomeBlock.
```

Results in:

```
this is the first paragraph. It is a child of SomeBlock.

this is the second paragraph. Also a child of SomeBlock.
```

> Todo: explain tags

Definitions
-----------

All Boxup documents use definition files for validation. Definitions tell the Boxup compiler what blocks are allowed and where they can occur. Definitions are also written in Boxup, and look something like this (using a simple markup definition):

```boxup
[Root]
  [Child/Paragraph]
  [Child/Header]
  [Child/Title]
  [Child/SubTitle]
  [Child/Section symbol="#"]
  [Child/Link]
  [Child/List]
  [Child/Image]

[Block/Paragraph kind=Paragraph]
  [Child/Link symbol='@']

[Block/Header]
  [IdProperty/id]
  [Child/Paragraph]
  [Child/Title]
  [Child/SubTitle]

[Block/Title]
  [Meta/html renderHint=Header]
  [Child/Paragraph]

[Block/SubTitle]
  [Meta/html renderHint=SubHeader]
  [Child/Paragraph]

[Block/Section]
  [Meta/html]
    renderHint=Template
    template = |
      <section class="section">
        ::if title::<h3 class="section-title">::title::</h3>::end::
        ::children::
      </section>
    |
  [IdProperty/title]
  [Child/Paragraph]
  [Child/Header]
  [Child/Title]
  [Child/SubTitle]
  [Child/Link]
  [Child/List]
  [Child/Image]

[Block/Note]
  [IdProperty/id]
  [Child/Paragraph]
  [Child/Title]
  [Child/Link]
  [Child/List]
  [Child/Image]

[Block/Link kind=Tag]
  [Meta/html renderHint=Link]
  [IdProperty/href required=true]
  [Child/Paragraph]
  [Child/Image]

[Block/Image]
  [Meta/html renderHint=Image]
  [Property/src required=true]
  [Property/alt required=true]

[Block/List]
  [Meta/html renderHint=ListContainer]
  [EnumProperty/type]
    [Option value=Ordered]
    [Option value=Unordered]
  [Child/Item symbol="-"]

[Block/Item]
  [Meta/html renderHint=ListItem]
  [Child/Paragraph]
  [Child/Image]
  [Child/Section]
```

> todo: explain all this
