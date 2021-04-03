package boxup;

class ValidatorStream extends StreamBase<Array<Node>, Array<Node>> {
  final validator:Validator;

  public function new(validator) {
    this.validator = validator;
  }

  function transform(nodes:Result<Array<Node>>, source:Source) {
    return nodes.map(nodes -> validator.validate(nodes, source));
  }
}
