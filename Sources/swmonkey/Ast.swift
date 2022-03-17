class Ast {
  enum StatementNode: Equatable {
    case letStatement(token: Token, name: Identifier, value: ExpressionNode)
  }

  enum ExpressionNode: Equatable {
    case identifier(token: Token, value: String)
    case integer(token: Token, value: Int64)
    case string(token: Token, value: String)
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

  struct Identifier: Equatable {
    let token: Token
    let value: String
  }
}
