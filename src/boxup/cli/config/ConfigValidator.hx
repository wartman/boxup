package boxup.cli.config;

import boxup.Builtin;

final validator = new Definition([
  {
    name: BRoot,
    properties: [],
    children: [
      { name: 'Definitions', required: true, multiple: false },
      { name: 'Compile', required: true }
    ]
  },
  {
    name: 'Definitions',
    properties: [
      { name: 'root', required: true },
      { name: 'suffix', required: false }
    ],
    children: []
  },
  {
    name: 'Compile',
    properties: [
      { name: 'source', isId: true, required: true },
      { name: 'destination', required: true },
      { name: 'generator', required: true, allowedValues: [
        // These are the builtin generators we have:
        'html', 'json' 
      ] }
    ],
    children: []
  }
], []);
