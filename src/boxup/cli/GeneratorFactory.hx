package boxup.cli;

import boxup.Generator;
import boxup.definition.Definition;

typedef GeneratorFactory<T> = (definition:Definition) -> Generator<T>;
 