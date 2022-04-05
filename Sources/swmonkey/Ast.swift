class Ast {
  enum StatementNode: Equatable {
    case letStatement(token: Token, name: Identifier, value: ExpressionNode)
    case returnStatement(token: Token, returnValue: ExpressionNode)
    case expressionStatement(expression: ExpressionNode)
  }

  enum ExpressionNode: Equatable {
    case identifier(token: Token, value: String)
    case integer(token: Token, value: Int64)
    case string(token: Token, value: String)
    case boolean(token: Token, value: Bool)
    indirect case prefixExpression(token: Token, right: Ast.ExpressionNode)
    indirect case infixExpression(token: Token, left: Ast.ExpressionNode, right: Ast.ExpressionNode)

    init?(token: Token, value: Bool) {
      self = .boolean(token: token, value: value)
    }
  }

  enum OperationPrecedence: Equatable, Comparable {
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
