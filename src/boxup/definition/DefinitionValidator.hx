package boxup.definition;

import boxup.Builtin;
import boxup.TokenType;
import boxup.definition.Definition;

final validator = new Definition('d', [
  {
    name: BRoot,
    properties: [],
    children: [
      { name: 'Definition', multiple: false },
      { name: 'Root', required: true, multiple: false },
      { name: 'Meta' },
      { name: 'Block' }
    ]
  },
  {
    name: 'Definition',
    properties: [
      { name: 'id', required: true, isId: true }
    ],
    children: []
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
        BlockDefinitionKind.BTag,
        BlockDefinitionKind.BNormal,
        BlockDefinitionKind.BParagraph
      ] },
      { name: 'name', type: 'String', isId: true, required: true }
    ],
    children: [ 
      { name: 'Child' },
      { name: 'Property' },
      { name: 'IdProperty', multiple: false },
      { name: 'EnumProperty' },
      { name: 'Meta' }
    ]
  },
  {
    name: 'Property',
    properties: [
      { name: 'name', type: 'String', isId: true, required: true },
      { name: 'type', type: 'String', required: false },
      { name: 'required', type: 'Bool', required: false },
      { name: 'type', type: 'String', required: false, allowedValues: [
        'String', 'Int', 'Float', 'Bool'
      ] }
    ],
    children: []
  },
  {
    name: 'IdProperty',
    properties: [
      { name: 'name', isId: true, type: 'String', required: true },
      { name: 'type', type: 'String', required: false },
      { name: 'required', type: 'Bool', required: false }
    ],
    children: []
  },
  {
    name: 'EnumProperty',
    properties: [
      { name: 'name', isId: true, type: 'String', required: true },
      { name: 'type', type: 'String', required: false },
      { name: 'required', type: 'Bool', required: false }
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
      { name: 'name', isId: true, type: 'String', required: true },
      { name: 'required', type: 'Bool', required: false },
      { name: 'multiple', type: 'Bool', required: false },
      { name: 'symbol', type: 'String', allowedValues: [
        TokBang, TokAt, TokHash, TokPercent, 
        TokDollar, TokAmp, TokCarat, TokDash,
        TokColon, TokOpenAngleBracket, TokCloseAngleBracket,
        TokQuestion, TokPlus, TokStar
      ] },
    ],
    children: []
  },
  {
    name: 'Meta',
    kind: BPropertyBag,
    properties: [
      { name: 'metaNamespace', isId: true }
    ],
    children: []
  }
], []);
