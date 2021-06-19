# Boxup Docs | Syntax

## Blocks
Blocks are what everything in Boxup are built out of. A block is simple: it consists of a block header -- a block name and (potentially) properties inside square brackets (e.g. `[foo bar=bin]` or just `[foo]`) -- and block children, which may be properties, text, other blocks or a combination of all of these.

## Comments
Comments are written like this: `[/ Comment /]`. They can come anywhere in a Boxup document. They _should_ be nest-able soon too (although they aren't quite yet).

## Multiline Strings
Multiline strings start and end with the pipe (`|`) operator. All strings can technically span several lines, but this special syntax strips whitespace from the start of each line of the string up to the index where the **first non-whitespace character was encountered**.

For example:

```boxup

    [SomeBlock]
      foo = |
        This is where indentation starts.
          Thus, When rendered, this line will only have two spaces
          in front of it!
        
        Also, any whitespace after the first \| will be ignored,
        and any whitespace before the last \| will be skipped.

        Also note that you need to escape pipes in these examples.
      |
  
```

