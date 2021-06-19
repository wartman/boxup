package boxup.cli;

import boxup.cli.SourceCollection;

typedef LoaderFactory = (root:String, sources:SourceCollection) -> Loader;
