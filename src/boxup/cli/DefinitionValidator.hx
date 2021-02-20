package boxup.cli;

import boxup.Node;
import boxup.Validator;
import boxup.Builtin;

class DefinitionValidator implements Validator {
  static final impl = new Definition([
    {
      name: BRoot,
      isTag: false,
      isParagraph: false,
      properties: [],
      children: [
        { name: 'Root', required: true, multiple: false },
        { name: 'Block' },
        { name: 'Paragraph' }
      ]
    },
    {
      name: 'Root',
      isTag: false,
      isParagraph: false,
      properties: [],
      children: [ 
        { name: 'Child' }
      ]
    },
    {
      name: 'Block',
      isTag: false,
      isParagraph: false,
      properties: [
        { name: 'isRoot', type: 'Bool', required: false },
        { name: 'isTag', type: 'Bool', required: false },
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
      isTag: false,
      isParagraph: false,
      properties: [
        { name: 'name', type: 'String', required: true },
        { name: 'type', type: 'String', required: false },
        { name: 'required', type: 'Bool', required: false },
        { name: 'default', type: 'String', required: false  }
      ],
      children: []
    },
    {
      name: 'EnumProperty',
      isTag: false,
      isParagraph: false,
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
      isTag: false,
      isParagraph: false,
      properties: [
        { name: 'value', type: 'String', required: true }
      ],
      children: []
    },
    {
      name: 'Paragraph',
      isTag: false,
      isParagraph: false,
      properties: [
        { name: 'name', type: 'String', required: true },
        { name: 'isRoot', type: 'Bool', required: false }
      ],
      children: [ 
        { name: 'Child' }
      ]
    },
    {
      name: 'Child',
      isTag: false,
      isParagraph: false,
      properties: [
        { name: 'name', type: 'String', required: true },
        { name: 'required', type: 'Bool', required: false },
        { name: 'multiple', type: 'Bool', required: false }
      ],
      children: []
    }
  ]);

  public function new() {}

  public function validate(nodes:Array<Node>):ValidationResult {
    return impl.validate(nodes);
  }
}
