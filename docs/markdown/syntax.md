# Boxup Docs | Syntax

## Blocks

Blocks are what everything in Boxup are built out of. A block is simple: it consists of a block header -- a block name and (potentially) properties inside square brackets (e.g. `[Foo bar=bin]` or just `[Foo]`) -- and block children, which may be properties, text, other blocks or a combination of all of these.

## Comments

Comments are written like this: `[/ Comment /]`. They can come anywhere in a Boxup document. They _should_ be nestable soon too (although they aren't quite yet). 