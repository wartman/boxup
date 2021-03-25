package boxup.cli.config;

import boxup.Builtin;

final validator = new Definition([
  {
    name: BRoot,
    properties: [],
    children: [
      { name: 'Definitions', required: true, multiple: false }
    ]
  },
  {
    name: 'Definitions',
    properties: [
      { name: 'root', required: true },
      { name: 'suffix', required: false }
    ],
    children: []
  }
], []);
