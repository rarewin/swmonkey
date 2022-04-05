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

  /// パースして次のstatementを取得する
  ///
  /// - Returns: statement node
  func next() -> Ast.StatementNode? {
    return parseStatement()
  }

  /// 次のトークンを取得する
  func nextToken() {
    currentToken = peekToken
    peekToken = lexer.next()
  }

  func getPrecedence(token: Token?) -> Ast.OperationPrecedence {
    switch token {
    case .eq, .notEq:
      return .equals
    case .lt, .gt:
      return .lessGreater
    case .plus, .minus:
      return .sum
    case .asterisk, .slash:
      return .product
    default:
      return .lowest
    }
  }

  var peekPrecedence: Ast.OperationPrecedence {
    getPrecedence(token: peekToken)
  }

  var currentPrecedence: Ast.OperationPrecedence {
    getPrecedence(token: currentToken)
  }

  /// `expected` なトークンであれば消費する
  ///
  /// - Parameter
  ///   - expected: 期待するトークン(連想値は無視される)
  /// - Returns: 期待したトークン。currentが異なるtypeであればnilが帰る
  func consumeExpectedToken(expected: Token) -> Token? {
    guard let token = currentToken else {
      return nil
    }

    if Token.hasSameType(lhs: token, rhs: expected) {
      nextToken()
      return token
    } else {
      return nil
    }
  }

  /// statementをパース
  ///
  /// - Returns: statement node
  func parseStatement() -> Ast.StatementNode? {
    guard let token = currentToken else {
      return nil
    }

    switch token {
    case .let:
      return parseLetStatement()
    case .return:
      return parseReturnStatement()
    default:
      return parseExpressionStatement()
    }
  }

  /// let statementをパース
  func parseLetStatement() -> Ast.StatementNode? {

    guard let token = consumeExpectedToken(expected: .let) else {
      return nil
    }

    guard let identToken = consumeExpectedToken(expected: .ident(literal: "ignored")) else {
      return nil
    }

    guard case let .ident(value) = identToken else {
      return nil
    }

    let name = Ast.Identifier(token: identToken, value: value)

    guard consumeExpectedToken(expected: .assign) != nil else {
      return nil
    }

    guard let value = parseExpression(precedence: .lowest) else {
      return nil
    }

    return .letStatement(token: token, name: name, value: value)
  }

  /// return statementをパース
  func parseReturnStatement() -> Ast.StatementNode? {
    guard let token = consumeExpectedToken(expected: .return) else {
      return nil
    }

    guard let returnValue = parseExpression(precedence: .lowest) else {
      return nil
    }

    return .returnStatement(token: token, returnValue: returnValue)
  }

  /// expression statementをパース
  ///
  /// - Returns: パース結果
  func parseExpressionStatement() -> Ast.StatementNode? {
    guard let expression = parseExpression(precedence: .lowest) else {
      return nil
    }

    return .expressionStatement(expression: expression)
  }

  /// expresionをパース
  ///
  /// - Parameter
  ///   - precedence: 順位
  /// - Returns: パース結果
  func parseExpression(precedence: Ast.OperationPrecedence) -> Ast.ExpressionNode? {

    guard var left = prefixParse() else {
      return nil
    }

    // print(
    //   "peekToken: \(peekToken)  peekPrecedence: \(peekPrecedence)  currentToken: \(currentToken)"
    // )

    while peekToken != .semicolon && precedence < peekPrecedence {
      if let new = infixParse(left: left) {
        left = new
      } else {
        fatalError()
      }
    }

    return left
  }

  /// prefixをパース
  func prefixParse() -> Ast.ExpressionNode? {

    guard let token = currentToken else {
      return nil
    }

    switch token {
    case let .ident(literal):
      return Ast.ExpressionNode.identifier(token: token, value: literal)
    case let .int(value):
      return Ast.ExpressionNode.integer(token: token, value: value)
    case .true:
      return Ast.ExpressionNode.boolean(token: token, value: true)
    case .false:
      return Ast.ExpressionNode.boolean(token: token, value: false)
    case .bang, .minus:
      guard let right = parseExpression(precedence: .prefix) else {
        return nil
      }
      return Ast.ExpressionNode.prefixExpression(token: token, right: right)
    default:
      fatalError("unimplemented: \(#function) - \(#line) for \(token)")
    }
  }

  /// infixをパース
  func infixParse(left: Ast.ExpressionNode) -> Ast.ExpressionNode? {

    nextToken()

    guard let operationToken = currentToken else {
      return nil
    }

    switch operationToken {
    case .plus, .minus, .asterisk, .slash,
      .eq, .notEq, .gt, .lt:
      let precedence = currentPrecedence
      nextToken()

      guard let right = parseExpression(precedence: precedence) else {
        return nil  // ??
      }

      return Ast.ExpressionNode.infixExpression(token: operationToken, left: left, right: right)

    default:
      fatalError("unimplemented: \(#function) - \(#line)")
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
