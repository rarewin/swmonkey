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

  enum ParseError: Error {
    case unexpectedToken(token: Token, msg: String)
  }

  /// パースして次のstatementを取得する
  ///
  /// - Returns: statement node
  func next() throws -> Ast.StatementNode? {
    let node = try parseStatement()
    nextToken()
    return node
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
  func parseStatement() throws -> Ast.StatementNode? {
    guard let token = currentToken else {
      return nil
    }

    switch token {
    case .let:
      return try parseLetStatement()
    case .return:
      return try parseReturnStatement()
    default:
      return try parseExpressionStatement()
    }
  }

  /// let statementをパース
  func parseLetStatement() throws -> Ast.StatementNode? {

    guard let token = consumeExpectedToken(expected: .let) else {
      throw ParseError.unexpectedToken(token: currentToken ?? .eof, msg: "let should be here")
    }

    guard let identToken = consumeExpectedToken(expected: .ident(literal: "ignored")) else {
      throw ParseError.unexpectedToken(token: currentToken ?? .eof, msg: "should be identifier")
    }

    guard case let .ident(value) = identToken else {
      fatalError("this condition can't be true")
    }

    let name = Ast.Identifier(token: identToken, value: value)

    guard consumeExpectedToken(expected: .assign) != nil else {
      throw ParseError.unexpectedToken(token: currentToken ?? .eof, msg: "should be assign `='")
    }

    guard let value = try parseExpression(precedence: .lowest) else {
      return nil
    }

    if peekToken == .semicolon {
      nextToken()
    }

    return .letStatement(token: token, name: name, value: value)
  }

  /// return statementをパース
  func parseReturnStatement() throws -> Ast.StatementNode? {
    guard let token = consumeExpectedToken(expected: .return) else {
      throw ParseError.unexpectedToken(token: currentToken ?? .eof, msg: "should be return")
    }

    guard let returnValue = try parseExpression(precedence: .lowest) else {
      return nil
    }

    if peekToken == .semicolon {
      nextToken()
    }

    return .returnStatement(token: token, returnValue: returnValue)
  }

  /// expression statementをパース
  ///
  /// - Returns: パース結果
  func parseExpressionStatement() throws -> Ast.StatementNode? {
    guard let expression = try parseExpression(precedence: .lowest) else {
      return nil
    }

    if peekToken == .semicolon {
      nextToken()
    }

    return .expressionStatement(expression: expression)
  }

  /// expresionをパース
  ///
  /// - Parameter
  ///   - precedence: 順位
  /// - Returns: パース結果
  func parseExpression(precedence: Ast.OperationPrecedence) throws -> Ast.ExpressionNode? {

    guard var left = try prefixParse() else {
      return nil
    }

    while peekToken != .semicolon && precedence < peekPrecedence {
      if isInfixParsable {
        nextToken()
        if let new = try infixParse(left: left) {
          left = new
        }
      } else {
        return left
      }
    }

    return left
  }

  /// prefixをパース
  func prefixParse() throws -> Ast.ExpressionNode? {

    guard let token = currentToken else {
      return nil
    }

    switch token {
    case let .ident(literal):
      return Ast.ExpressionNode.identifier(token: token, value: literal)
    case let .int(value):
      return Ast.ExpressionNode.integer(token: token, value: value)
    case .true:
      return Ast.ExpressionNode.boolean(token: token)
    case .false:
      return Ast.ExpressionNode.boolean(token: token)
    case .bang, .minus:
      nextToken()
      guard let right = try parseExpression(precedence: .prefix) else {
        return nil
      }
      return Ast.ExpressionNode.prefixExpression(token: token, right: right)

    case .leftParen:
      nextToken()
      guard let exp = try parseExpression(precedence: .lowest) else {
        return nil
      }
      guard peekToken == .rightParen else {
        throw ParseError.unexpectedToken(token: currentToken ?? .eof, msg: "should be `)'")
      }
      nextToken()
      return exp

    case .if:
      nextToken()  // consume "if"
      guard let _ = consumeExpectedToken(expected: .leftParen) else {
        throw ParseError.unexpectedToken(
          token: currentToken ?? .eof, msg: "should be left parenthesis"
        )
      }
      guard let condition = try parseExpression(precedence: .lowest) else {
        return nil
      }
      nextToken()
      guard let _ = consumeExpectedToken(expected: .rightParen) else {
        throw ParseError.unexpectedToken(
          token: currentToken ?? .eof, msg: "should be right parenthesis"
        )
      }
      guard let consequence = try parseBlockStatement() else {
        return nil
      }

      if currentToken != .else {
        return Ast.ExpressionNode.ifExpression(
          token: token, condition: condition, consequence: consequence, alternative: nil
        )
      }
      nextToken()

      guard let alternative = try parseBlockStatement() else {
        return nil
      }

      return .ifExpression(
        token: token, condition: condition, consequence: consequence, alternative: alternative
      )

    case .function:
      nextToken()  // consume fn

      guard let _ = consumeExpectedToken(expected: .leftParen) else {
        return nil
      }

      var parameters: [Ast.ExpressionNode] = []

      while currentToken != .rightParen {
        guard let identToken = consumeExpectedToken(expected: .ident(literal: "ignored")) else {
          return nil
        }

        guard case let .ident(value) = identToken else {
          return nil
        }

        parameters.append(Ast.ExpressionNode.identifier(token: identToken, value: value))

        if let _ = consumeExpectedToken(expected: .comma) {
          guard currentToken != .rightParen else {
            return nil
          }
        }
      }

      guard let _ = consumeExpectedToken(expected: .rightParen) else {
        return nil
      }

      guard let body = try parseBlockStatement() else {
        return nil
      }

      return .functionExpression(
        token: token, parameters: parameters, body: body
      )

    default:
      throw ParseError.unexpectedToken(token: token, msg: "")
    }
  }

  var isInfixParsable: Bool {
    switch peekToken {
    case .plus, .minus, .asterisk, .slash,
      .eq, .notEq, .gt, .lt:
      return true
    default:
      return false
    }
  }

  /// infixをパース
  func infixParse(left: Ast.ExpressionNode) throws -> Ast.ExpressionNode? {

    guard let operationToken = currentToken else {
      return nil
    }

    switch operationToken {
    case .plus, .minus, .asterisk, .slash,
      .eq, .notEq, .gt, .lt:
      let precedence = currentPrecedence
      nextToken()

      guard let right = try parseExpression(precedence: precedence) else {
        return nil  // ??
      }

      return Ast.ExpressionNode.infixExpression(token: operationToken, left: left, right: right)

    default:
      return nil
    }
  }

  func parseBlockStatement() throws -> Ast.StatementNode? {
    guard let _ = consumeExpectedToken(expected: .leftBrace) else {
      throw ParseError.unexpectedToken(token: currentToken ?? .eof, msg: "should be left brace")
    }
    var statements: [Ast.StatementNode] = []
    while currentToken != .rightBrace {
      guard let statement = try parseStatement() else {
        throw ParseError.unexpectedToken(token: currentToken ?? .eof, msg: "statement not found")
      }
      nextToken()
      statements.append(statement)
    }

    guard let _ = consumeExpectedToken(expected: .rightBrace) else {
      throw ParseError.unexpectedToken(token: currentToken ?? .eof, msg: "should be right brace")
    }

    return .blockStatement(statements: statements)
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
