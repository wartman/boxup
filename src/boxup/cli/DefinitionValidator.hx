package boxup.cli;

import boxup.Node;
import boxup.Validator;

class DefinitionValidator implements Validator {
  static final impl = new Definition([
    {
      name: 'Block',
      isTag: false,
      isRoot: true,
      isParagraph: false,
      required: false,
      properties: [
        { name: 'required', type: 'Bool', required: false, defaultValue: null },
        { name: 'isRoot', type: 'Bool', required: false, defaultValue: null },
        { name: 'isTag', type: 'Bool', required: false, defaultValue: null },
        { name: 'name', type: 'String', required: true, defaultValue: null }
      ],
      children: [ 'Child', 'Property' ]
    },
    {
      name: 'Property',
      isTag: false,
      isRoot: false,
      isParagraph: false,
      required: false,
      properties: [
        { name: 'name', type: 'String', required: true, defaultValue: null },
        { name: 'type', type: 'String', required: false, defaultValue: 'String' },
        { name: 'required', type: 'Bool', required: false, defaultValue: null },
        { name: 'default', type: 'String', required: false, defaultValue: null  }
      ],
      children: []
    },
    {
      name: 'Paragraph',
      isTag: false,
      isRoot: true,
      isParagraph: false,
      required: false,
      properties: [
        { name: 'name', type: 'String', required: true, defaultValue: null },
        { name: 'isRoot', type: 'Bool', required: false, defaultValue: null }
      ],
      children: [ 'Child' ]
    },
    {
      name: 'Child',
      isTag: false,
      isRoot: false,
      isParagraph: false,
      required: false,
      properties: [
        { name: 'name', type: 'String', required: true, defaultValue: null }
      ],
      children: []
    }
  ]);

  public function new() {}

  public function validate(nodes:Array<Node>):ValidationResult {
    return impl.validate(nodes);
  }
}

// class DefinitionValidator implements Validator {
//   public function new() {}

//   public function validate(nodes:Array<Node>):ValidationResult {
//     var errors:Array<Error> = [];
//     for (node in nodes) switch node.type {
//       case Block(name):
//         try {
//           validateBlock(node, [ 'Block', 'Paragraph' ]);
//         } catch (e:Error) {
//           errors.push(e);
//         }
//       case Paragraph: 
//         // errors.push(new Error('Paragraphs are not alowed in definitions', node.pos));
//       case Text:
//         // errors.push(new Error('Text is not alowed in definitions', node.pos));
//     }
//     return errors.length > 0 ? Failed(errors) : Passed;
//   }

//   function validateBlock(node:Node, allowedChildren:Array<String>) {
//     switch node.type {
//       case Block(name):
//         if (!allowedChildren.contains(name)) {
//           throw new Error('Invalid child', node.pos);
//         }
//         switch name {
//           case 'Block':
//             validateProperties(node, [
//               'required' => { type: 'Bool', required: false },
//               'isRoot' => { type: 'Bool', required: false },
//               'isTag' => { type: 'Bool', required: false },
//               'name' => { type: 'String', required: true }
//             ]);
//             for (child in node.children) { 
//               validateBlock(child, [ 'Child', 'Property' ]);
//             }
//           case 'Property':
//             validateProperties(node, [
//               'required' => { type: 'Bool', required: false },
//               'name' => { type: 'String', required: true },
//               'type' => { type: 'String', required: false },
//               'default' => { type: 'String', required: false }
//             ]);
//             if (node.children.length > 0) {
//               throw new Error('Properties cannot have children', node.children[0].pos);
//             }
//           case 'Paragraph':
//             validateProperties(node, [
//               'allowInRoot' => { type: 'Bool', required: false }
//             ]);
//             for (child in node.children) {
//               validateBlock(child, [ 'Child' ]);
//             }
//           case 'Child':
//             validateProperties(node, [
//               'name' => { type: 'String', required: true }
//             ]);
//           default:
//             throw new Error('Invalid block type', node.pos);
//         }
//       case Paragraph: 
//         throw new Error('Paragraphs are not alowed in definitions', node.pos);
//       case Text:
//         throw new Error('Text is not alowed in definitions', node.pos);
//     }
//   }

//   function validateProperties(node:Node, propTypes:Map<String, { type:String, required:Bool }>) {
//     var found:Array<String> = [];

//     function checkForDuplicates(prop:Property) {
//       if (found.contains(prop.name)) {
//         throw new Error('Duplicate property', prop.pos);
//       }
//       found.push(prop.name);
//     }

//     function checkType(prop:Property) {
//       var value = prop.value;
//       var kind = propTypes.get(prop.name);

//       if (kind == null) {
//         throw new Error('Invalid property name', prop.pos);
//       }

//       if (value.type != kind.type) {
//         throw new Error('Unexpected ${value.type} -- expected a ${kind.type}', value.pos);
//       }
//     }

//     for (prop in node.properties) {
//       checkType(prop);
//       checkForDuplicates(prop);
//     }

//     for (name => kind in propTypes) {
//       if (kind.required && !found.contains(name)) {
//         throw new Error('Requires property ${name}', node.pos);
//       }
//     }
//   }
// }