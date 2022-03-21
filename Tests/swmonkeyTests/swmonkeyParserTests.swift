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
          token: Token(tokenType: Token.TokenType.true, literal: "true"),
          value: true
        )
      ),
    ]

    for t in tests {
      let lexer = Lexer(input: t.input)
      let parser = Parser(lexer: lexer)

      try testLetStatement(parsed: parser.next(), ident: t.ident, node: t.node)
    }

  }
}
