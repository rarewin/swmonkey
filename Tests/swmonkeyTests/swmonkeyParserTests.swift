import XCTest

@testable import swmonkey

final class swmonkeyParserTests: XCTestCase {

  func testLetStatement(parsed: Ast.StatementNode?, ident: String, node: Ast.ExpressionNode) throws
  {

    guard case let .letStatement(token: token, name: name, value: value) = parsed
    else {
      XCTFail("\(String(describing: parsed)) is not a let statement")
      return
    }

    XCTAssertEqual(token, Token.let)
    XCTAssertEqual(
      name,
      Ast.Identifier(token: Token.ident(literal: ident), value: ident)
    )
    XCTAssertEqual(value, node)
  }

  func testLetStatements() throws {

    XCTAssertEqual(
      Ast.ExpressionNode.identifier(token: Token.assign, value: "="),
      Ast.ExpressionNode.identifier(token: Token.assign, value: "=")
    )

    XCTAssertNotEqual(
      Ast.ExpressionNode.identifier(token: Token.assign, value: "="),
      Ast.ExpressionNode.identifier(token: Token.eq, value: "==")
    )

    let tests = [
      (
        input: "let x = 5;",
        ident: "x",
        node: Ast.ExpressionNode.integer(token: Token.int(value: 5), value: 5)
      ),
      (
        input: "let y = true;",
        ident: "y",
        node: Ast.ExpressionNode.boolean(token: Token.true)
      ),
      (
        input: "let x = false;",
        ident: "x",
        node: Ast.ExpressionNode.boolean(token: Token.false)
      ),
      (
        input: "let foobar = y;",
        ident: "foobar",
        node: Ast.ExpressionNode.identifier(token: Token.ident(literal: "y"), value: "y")
      ),
    ]

    for t in tests {
      let lexer = Lexer(input: t.input)
      let parser = Parser(lexer: lexer)

      try testLetStatement(parsed: try parser.next(), ident: t.ident, node: t.node)
    }
  }

  func testReturnStatements() throws {
    try [
      (
        input: "return 5;",
        returnValue: Ast.ExpressionNode.integer(token: Token.int(value: 5), value: 5)
      ),
      (
        input: "return 10;",
        returnValue: Ast.ExpressionNode.integer(token: Token.int(value: 10), value: 10)
      ),
      (
        input: "return 993322;",
        returnValue: Ast.ExpressionNode.integer(token: Token.int(value: 993322), value: 993322)
      ),
    ].forEach { test in
      let lexer = Lexer(input: test.input)
      let parser = Parser(lexer: lexer)

      XCTAssertEqual(
        try parser.next(),
        Ast.StatementNode.returnStatement(
          token: Token.return,
          returnValue: test.returnValue
        )
      )
    }
  }

  func testExpressionStatement() throws {
    do {
      let input = "foobar;"
      let lexer = Lexer(input: input)
      let parser = Parser(lexer: lexer)

      XCTAssertEqual(
        try parser.next(),
        Ast.StatementNode.expressionStatement(
          expression: Ast.ExpressionNode.identifier(
            token: Token.ident(literal: "foobar"),
            value: "foobar"
          )
        )
      )
    }
  }

  func testIntegerLiteralExpression() throws {
    do {
      let input = "5;"
      let lexer = Lexer(input: input)
      let parser = Parser(lexer: lexer)

      XCTAssertEqual(
        try parser.next(),
        Ast.StatementNode.expressionStatement(
          expression: Ast.ExpressionNode.integer(
            token: Token.int(value: 5),
            value: 5
          )
        )
      )
    }
  }

  func testPrefixExpressions() throws {
    try [
      (
        input: "!5;",
        token: Token.bang,
        right: Ast.ExpressionNode.integer(
          token: Token.int(value: 5),
          value: 5
        )
      ),
      (
        input: "-15;",
        token: Token.minus,
        right: Ast.ExpressionNode.integer(
          token: Token.int(value: 15),
          value: 15
        )
      ),
      (
        input: "!true;",
        token: Token.bang,
        right: Ast.ExpressionNode.boolean(token: Token.true)
      ),
      (
        input: "!false;",
        token: Token.bang,
        right: Ast.ExpressionNode.boolean(token: Token.false)
      ),
    ].forEach { test in
      let lexer = Lexer(input: test.input)
      let parser = Parser(lexer: lexer)

      let parsed = try parser.next()

      guard case let .expressionStatement(expression: expression) = parsed
      else {
        XCTFail("\(String(describing: parsed)) is not an expression statement")
        return
      }

      XCTAssertEqual(
        Ast.ExpressionNode.prefixExpression(token: test.token, right: test.right),
        expression
      )
    }
  }

  func testInfixExpressionsIntegers() throws {

    XCTAssert(Ast.OperationPrecedence.lowest < Ast.OperationPrecedence.equals)

    try [
      (
        input: "5 + 5;",
        expectedToken: Token.plus,
        expectedLeftInt: 5,
        expectedRightInt: 5
      ),
      (
        input: "5 - 5;",
        expectedToken: Token.minus,
        expectedLeftInt: 5,
        expectedRightInt: 5
      ),
      (
        input: "5 * 5;",
        expectedToken: Token.asterisk,
        expectedLeftInt: 5,
        expectedRightInt: 5
      ),
      (
        input: "5 / 5;",
        expectedToken: Token.slash,
        expectedLeftInt: 5,
        expectedRightInt: 5
      ),
      (
        input: "5 == 5;",
        expectedToken: Token.eq,
        expectedLeftInt: 5,
        expectedRightInt: 5
      ),
      (
        input: "5 != 5;",
        expectedToken: Token.notEq,
        expectedLeftInt: 5,
        expectedRightInt: 5
      ),
      (
        input: "5 > 5;",
        expectedToken: Token.gt,
        expectedLeftInt: 5,
        expectedRightInt: 5
      ),
      (
        input: "5 < 5;",
        expectedToken: Token.lt,
        expectedLeftInt: 5,
        expectedRightInt: 5
      ),
    ].forEach { test in
      let lexer = Lexer(input: test.input)
      let parser = Parser(lexer: lexer)

      let parsed = try parser.next()

      guard case let .expressionStatement(expression: expression) = parsed
      else {
        XCTFail("\(String(describing: parsed)) is not an expression statement")
        return
      }

      XCTAssertEqual(
        expression,
        Ast.ExpressionNode.infixExpression(
          token: test.expectedToken,
          left: Ast.ExpressionNode.integer(
            token: Token.int(value: Int64(test.expectedLeftInt)),
            value: Int64(test.expectedLeftInt)
          ),
          right: Ast.ExpressionNode.integer(
            token: Token.int(value: Int64(test.expectedRightInt)),
            value: Int64(test.expectedRightInt))
        )
      )
    }
  }

  func testInfixExpressionsBooleans() throws {
    try [
      (
        input: "true == true",
        expectedLeft: Token.true,
        expectedToken: Token.eq,
        expectedRight: Token.true
      ),
      (
        input: "true != false",
        expectedLeft: Token.true,
        expectedToken: Token.notEq,
        expectedRight: Token.false
      ),
      (
        input: "false == false",
        expectedLeft: Token.false,
        expectedToken: Token.eq,
        expectedRight: Token.false
      ),
    ].forEach { test in
      let lexer = Lexer(input: test.input)
      let parser = Parser(lexer: lexer)

      let parsed = try parser.next()

      guard case let .expressionStatement(expression: expression) = parsed
      else {
        XCTFail("\(String(describing: parsed)) is not an expression statement")
        return
      }

      XCTAssertEqual(
        expression,
        Ast.ExpressionNode.infixExpression(
          token: test.expectedToken,
          left: Ast.ExpressionNode.boolean(token: test.expectedLeft),
          right: Ast.ExpressionNode.boolean(token: test.expectedRight)
        )
      )
    }
  }

  func testOperatorPrecedenceParsing() throws {
    try [
      (
        input: "-a * b",
        expected: "((-a) * b)"
      ),
      (
        input: "!-a",
        expected: "(!(-a))"
      ),
      (
        input: "a + b + c",
        expected: "((a + b) + c)"
      ),
      (
        input: "a + b - c",
        expected: "((a + b) - c)"
      ),
      (
        input: "a * b * c",
        expected: "((a * b) * c)"
      ),
      (
        input: "a * b / c",
        expected: "((a * b) / c)"
      ),
      (
        input: "a + b / c",
        expected: "(a + (b / c))"
      ),
      (
        input: "a + b * c + d / e - f",
        expected: "(((a + (b * c)) + (d / e)) - f)"
      ),
      (
        input: "3 + 4; -5 * 5",
        expected: "(3 + 4)((-5) * 5)"
      ),
      (
        input: "5 > 4 == 3 < 4",
        expected: "((5 > 4) == (3 < 4))"
      ),
      (
        input: "5 < 4 != 3 > 4",
        expected: "((5 < 4) != (3 > 4))"
      ),
      (
        input: "3 + 4 * 5 == 3 * 1 + 4 * 5",
        expected: "((3 + (4 * 5)) == ((3 * 1) + (4 * 5)))"
      ),
      (
        input: "true",
        expected: "true"
      ),
      (
        input: "false",
        expected: "false"
      ),
      (
        input: "3 > 5 == false",
        expected: "((3 > 5) == false)"
      ),
      (
        input: "3 < 5 == true",
        expected: "((3 < 5) == true)"
      ),
      (
        input: "1 + (2 + 3) + 4",
        expected: "((1 + (2 + 3)) + 4)"
      ),
      (
        input: "(5 + 5) * 2",
        expected: "((5 + 5) * 2)"
      ),
      (
        input: "2 / (5 + 5)",
        expected: "(2 / (5 + 5))"
      ),
      (
        input: "-(5 + 5)",
        expected: "(-(5 + 5))"
      ),
      (
        input: "!(true == true)",
        expected: "(!(true == true))"
      ),
    ].forEach { test in
      let lexer = Lexer(input: test.input)
      let parser = Parser(lexer: lexer)

      var ret = ""

      while let statement = try parser.next() {
        ret += String(describing: statement)
      }

      XCTAssertEqual(ret, test.expected)
    }
  }

  func testIfExpression() throws {
    let lexer = Lexer(input: "if (x < y) { x }")
    let parser = Parser(lexer: lexer)

    let parsed = try parser.next()

    guard case let .expressionStatement(expression: expression) = parsed
    else {
      XCTFail("\(String(describing: parsed)) is not an expression statement")
      return
    }

    guard
      case let .ifExpression(
        token: token, condition: condition, consequence: consequence, alternative: alternative) =
        expression
    else {
      XCTFail("\(expression) is not an if expression")
      return
    }

    XCTAssertEqual(token, .if)
    XCTAssertEqual(
      condition,
      .infixExpression(
        token: Token.lt,
        left: .identifier(token: Token.ident(literal: "x"), value: "x"),
        right: .identifier(token: Token.ident(literal: "y"), value: "y")
      )
    )

    guard case let .blockStatement(statements: consequence) = consequence else {
      XCTFail("\(consequence) is not a block statement")
      return
    }

    XCTAssert(consequence.count == 1)
    XCTAssertEqual(
      consequence[0],
      .expressionStatement(
        expression: .identifier(token: Token.ident(literal: "x"), value: "x")
      )
    )
    XCTAssert(alternative == nil)
  }

  func testIfElseExpression() throws {
    let lexer = Lexer(input: "if (x < y) { x } else { y }")
    let parser = Parser(lexer: lexer)

    let parsed = try parser.next()

    guard case let .expressionStatement(expression: expression) = parsed
    else {
      XCTFail("\(String(describing: parsed)) is not an expression statement")
      return
    }

    guard
      case let .ifExpression(
        token: token, condition: condition, consequence: consequence, alternative: alternative) =
        expression
    else {
      XCTFail("\(expression) is not an if expression")
      return
    }

    XCTAssertEqual(token, .if)
    XCTAssertEqual(
      condition,
      .infixExpression(
        token: Token.lt,
        left: .identifier(token: Token.ident(literal: "x"), value: "x"),
        right: .identifier(token: Token.ident(literal: "y"), value: "y")
      )
    )

    guard case let .blockStatement(statements: consequence) = consequence else {
      XCTFail("\(consequence) is not a block statement")
      return
    }

    XCTAssert(consequence.count == 1)
    XCTAssertEqual(
      consequence[0],
      .expressionStatement(
        expression: .identifier(token: Token.ident(literal: "x"), value: "x")
      )
    )

    guard let alternative = alternative else {
      XCTFail("insufficient alternative")
      return
    }

    guard case let .blockStatement(statements: alternative) = alternative else {
      XCTFail("\(consequence) is not a block statement")
      return
    }

    XCTAssert(alternative.count == 1)
    XCTAssertEqual(
      alternative[0],
      .expressionStatement(
        expression: .identifier(token: Token.ident(literal: "y"), value: "y")
      )
    )
  }

  func testFunctionLiteral() throws {
    let lexer = Lexer(input: "fn(x, y) {x + y;}")
    let parser = Parser(lexer: lexer)

    let parsed = try parser.next()

    guard case let .expressionStatement(expression: expression) = parsed
    else {
      XCTFail("\(String(describing: parsed)) is not an expression statement")
      return
    }

    guard
      case let .functionExpression(token: token, parameters: parameters, body: body) = expression
    else {
      XCTFail("\(String(describing: expression)) is not a function expression statement")
      return
    }

    XCTAssertEqual(token, .function)

    XCTAssert(parameters.count == 2)
    XCTAssertEqual(parameters[0], .identifier(token: Token(str: "x"), value: "x"))
    XCTAssertEqual(parameters[1], .identifier(token: Token(str: "y"), value: "y"))

    guard case let .blockStatement(statements: body) = body else {
      XCTFail("\(body) is not a block statement")
      return
    }

    XCTAssert(body.count == 1, "body.count should be 1, but \(body.count)")
    XCTAssertEqual(
      body[0],
      .expressionStatement(
        expression:
          .infixExpression(
            token: Token(str: "+"),
            left: .identifier(token: Token(str: "x"), value: "x"),
            right: .identifier(token: Token(str: "y"), value: "y")
          )
      )
    )
  }
}
