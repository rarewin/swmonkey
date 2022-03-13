class Ast {
  enum StatementNode: Equatable {
    case letStatement(name: Token, value: ExpressionNode)
  }

  enum ExpressionNode: Equatable {
    case identifier(token: Token)
    case integerLiteral(token: Token)
    case stringLiteral(token: Token)
  }

  enum OperationPrecedence: Int, Equatable {
    case lowest
    case equals
    case lessGreater
    case sum
    case product
    case prefix
    case call
    case index
  }
}
