package boxup.cli;

import boxup.Builtin;
import boxup.TokenType;
import boxup.cli.Definition.BlockDefinitionKind;

final validator = new Definition([
  {
    name: BRoot,
    properties: [],
    children: [
      { name: 'Root', required: true, multiple: false },
      { name: 'Block' }
    ]
  },
  {
    name: 'Root',
    properties: [],
    children: [ 
      { name: 'Child' }
    ]
  },
  {
    name: 'Block',
    properties: [
      { name: 'kind', type: 'String', required: false, allowedValues: [
        BlockDefinitionKind.BArrow,
        BlockDefinitionKind.BTag,
        BlockDefinitionKind.BNormal,
        BlockDefinitionKind.BParagraph
      ] },
      { name: 'name', type: 'String', required: true }
    ],
    children: [ 
      { name: 'Child' },
      { name: 'Property' },
      { name: 'EnumProperty' }
    ]
  },
  {
    name: 'Property',
    properties: [
      { name: 'name', type: 'String', required: true },
      { name: 'type', type: 'String', required: false },
      { name: 'required', type: 'Bool', required: false },
      { name: 'isId', type: 'Bool', required: false },
      { name: 'default', type: 'String', required: false, allowedValues: [
        'String', 'Int', 'Float', 'Bool'
      ] }
    ],
    children: []
  },
  {
    name: 'EnumProperty',
    properties: [
      { name: 'name', type: 'String', required: true },
      { name: 'type', type: 'String', required: false },
      { name: 'required', type: 'Bool', required: false },
      { name: 'default', type: 'String', required: false  }
    ],
    children: [
      { name: 'Option', required: true, multiple: true }
    ]
  },
  { 
    name: 'Option',
    properties: [
      { name: 'value', type: 'String', required: true }
    ],
    children: []
  },
  {
    name: 'Child',
    properties: [
      { name: 'name', type: 'String', required: true },
      { name: 'required', type: 'Bool', required: false },
      { name: 'multiple', type: 'Bool', required: false },
      { name: 'symbol', type: 'String', allowedValues: [
        TokSymbolExcitement, TokSymbolAt, TokSymbolHash, TokSymbolPercent, 
        TokSymbolDollar, TokSymbolAmp, TokSymbolCarat
      ] },
    ],
    children: []
  }
]);
