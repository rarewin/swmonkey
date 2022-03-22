import XCTest

@testable import swmonkey

final class swmonkeyParserTests: XCTestCase {

  func testLetStatement(parsed: Ast.StatementNode?, ident: String, node: Ast.ExpressionNode) throws
  {

    guard case let .letStatement(token: token, name: name, value: value) = parsed
    else {
      fatalError("\(String(describing: parsed)) is not a let statement")
    }

    XCTAssertEqual(token, Token(tokenType: .let, literal: "let"))
    XCTAssertEqual(
      name,
      Ast.Identifier(
        token: Token(tokenType: .ident, literal: ident),
        value: ident
      )
    )
    XCTAssertEqual(value, node)
  }

  func testLetStatements() throws {

    XCTAssertEqual(
      Ast.ExpressionNode.identifier(
        token: Token(tokenType: Token.TokenType.assign, literal: "="),
        value: "="),
      Ast.ExpressionNode.identifier(
        token: Token(tokenType: Token.TokenType.assign, literal: "="),
        value: "=")
    )

    XCTAssertNotEqual(
      Ast.ExpressionNode.identifier(
        token: Token(tokenType: Token.TokenType.assign, literal: "="),
        value: "="),
      Ast.ExpressionNode.identifier(
        token: Token(tokenType: Token.TokenType.eq, literal: "=="),
        value: "==")
    )

    let tests = [
      (
        input: "let x = 5;",
        ident: "x",
        node: Ast.ExpressionNode.integer(
          token: Token(tokenType: .int, literal: "5"),
          value: 5
        )
      ),
      (
        input: "let y = true;",
        ident: "y",
        node: Ast.ExpressionNode.boolean(
          token: Token(tokenType: .true, literal: "true"),
          value: true
        )
      ),
      (
        input: "let x = false;",
        ident: "x",
        node: Ast.ExpressionNode.boolean(
          token: Token(tokenType: .false, literal: "false"),
          value: false
        )
      ),
      (
        input: "let foobar = y;",
        ident: "foobar",
        node: Ast.ExpressionNode.identifier(
          token: Token(tokenType: .ident, literal: "y"),
          value: "y"
        )
      ),
    ]

    for t in tests {
      let lexer = Lexer(input: t.input)
      let parser = Parser(lexer: lexer)

      try testLetStatement(parsed: parser.next(), ident: t.ident, node: t.node)
    }
  }

  func testReturnStatements() throws {
    [
      (
        input: "return 5;",
        returnValue: Ast.ExpressionNode.integer(
          token: Token(tokenType: .int, literal: "5"),
          value: 5
        )
      ),
      (
        input: "return 10;",
        returnValue: Ast.ExpressionNode.integer(
          token: Token(tokenType: .int, literal: "10"),
          value: 10
        )
      ),
      (
        input: "return 993322;",
        returnValue: Ast.ExpressionNode.integer(
          token: Token(tokenType: .int, literal: "993322"),
          value: 993322
        )
      ),
    ].forEach { test in
      let lexer = Lexer(input: test.input)
      let parser = Parser(lexer: lexer)

      let returnToken = Token(tokenType: .return, literal: "return")

      XCTAssertEqual(
        parser.next(),
        Ast.StatementNode.returnStatement(
          token: returnToken,
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
        parser.next(),
        Ast.StatementNode.expressionStatement(
          token: Token(tokenType: .ident, literal: "foobar"),
          expression: Ast.ExpressionNode.identifier(
            token: Token(tokenType: .ident, literal: "foobar"),
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
        parser.next(),
        Ast.StatementNode.expressionStatement(
          token: Token(tokenType: .int, literal: "5"),
          expression: Ast.ExpressionNode.integer(
            token: Token(tokenType: .int, literal: "5"),
            value: 5
          )
        )
      )
    }
  }
}
