class Parser {
  var lexer: Lexer
  var currentToken: Token? = nil
  var peekToken: Token? = nil

  /// イニシャライザ
  init(lexer: Lexer) {
    self.lexer = lexer

    // currentToken, peekTokenを取得しておく
    nextToken()
    nextToken()
  }

  func next() -> Ast.StatementNode? {
    return parseStatement()
  }

  /// 次のトークンを取得する
  func nextToken() {
    currentToken = peekToken
    peekToken = lexer.next()
  }

  func consumeExpectedToken(expected: Token.TokenType) -> Token? {
    guard let token = peekToken else {
      return nil
    }

    if token.tokenType == expected {
      nextToken()
      return token
    } else {
      return nil
    }
  }

  func parseStatement() -> Ast.StatementNode? {
    guard let token = currentToken else {
      return nil
    }

    switch token.tokenType {
    case .let:
      return parseLetStatement()
    default:
      break
    }

    return nil
  }

  func parseLetStatement() -> Ast.StatementNode? {

    guard let token = currentToken else {
      return nil
    }

    guard token.tokenType == .let else {
      return nil
    }

    guard let identToken = consumeExpectedToken(expected: .ident) else {
      return nil
    }

    let name = Ast.Identifier(token: identToken, value: identToken.literal)

    guard consumeExpectedToken(expected: .assign) != nil else {
      return nil
    }

    guard let value = parseExpression(precedence: Ast.OperationPrecedence.lowest) else {
      return nil
    }

    return .letStatement(token: token, name: name, value: value)
  }

  func parseExpression(precedence: Ast.OperationPrecedence) -> Ast.ExpressionNode? {
    guard let _ = peekToken else {
      return nil
    }

    return prefixParse()
  }

  func prefixParse() -> Ast.ExpressionNode? {

    guard let token = peekToken else {
      return nil
    }

    switch token.tokenType {
    case .ident:
      return Ast.ExpressionNode.identifier(token: token, value: token.literal)
    case .int:
      return Ast.ExpressionNode.integer(token: token, value: Int64(token.literal)!)
    case .true:
      return Ast.ExpressionNode.boolean(token: token, value: true)
    case .false:
      return Ast.ExpressionNode.boolean(token: token, value: false)
    default:
      fatalError("unimplemented")
    }
  }
}

extension Parser: TextOutputStreamable {
  func write<Target: TextOutputStream>(to target: inout Target) {
    print(
      """
      Parser {
        current: \(String(describing: currentToken)),
        peek: \(String(describing: peekToken))
      }
      """, terminator: "", to: &target)
  }
}
