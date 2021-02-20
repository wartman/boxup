package boxup.cli;

import boxup.Node;
import boxup.Validator;

class DefinitionValidator implements Validator {
  static final impl = new Definition([
    {
      name: '@root',
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
        { name: 'required', type: 'Bool', required: false, defaultValue: null },
        { name: 'isRoot', type: 'Bool', required: false, defaultValue: null },
        { name: 'isTag', type: 'Bool', required: false, defaultValue: null },
        { name: 'name', type: 'String', required: true, defaultValue: null }
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
        { name: 'name', type: 'String', required: true, defaultValue: null },
        { name: 'type', type: 'String', required: false, defaultValue: 'String' },
        { name: 'required', type: 'Bool', required: false, defaultValue: null },
        { name: 'default', type: 'String', required: false, defaultValue: null  }
      ],
      children: []
    },
    {
      name: 'EnumProperty',
      isTag: false,
      isParagraph: false,
      properties: [
        { name: 'name', type: 'String', required: true, defaultValue: null },
        { name: 'type', type: 'String', required: false, defaultValue: 'String' },
        { name: 'required', type: 'Bool', required: false, defaultValue: null },
        { name: 'default', type: 'String', required: false, defaultValue: null  }
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
        { name: 'value', type: 'String', required: true, defaultValue: null }
      ],
      children: []
    },
    {
      name: 'Paragraph',
      isTag: false,
      isParagraph: false,
      properties: [
        { name: 'name', type: 'String', required: true, defaultValue: null },
        { name: 'isRoot', type: 'Bool', required: false, defaultValue: null }
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
        { name: 'name', type: 'String', required: true, defaultValue: null },
        { name: 'required', type: 'Bool', required: false, defaultValue: null },
        { name: 'multiple', type: 'Bool', required: false, defaultValue: 'true' }
      ],
      children: []
    }
  ]);

  public function new() {}

  public function validate(nodes:Array<Node>):ValidationResult {
    return impl.validate(nodes);
  }
}
