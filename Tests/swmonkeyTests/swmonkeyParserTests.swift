import XCTest

@testable import swmonkey

final class swmonkeyParserTests: XCTestCase {
  func testLetStatements() throws {
    let lexer = Lexer(input: "let x = 5;")
    let parser = Parser(lexer: lexer)

    XCTAssertEqual(
      parser.next(),
      Ast.StatementNode.letStatement(
        token: Token(tokenType: Token.TokenType.let, literal: "let"),
        name: Ast.Identifier(
          token: Token(tokenType: Token.TokenType.ident, literal: "x"),
          value: "x"
        ),
        value: Ast.ExpressionNode.integer(
          token: Token(tokenType: Token.TokenType.int, literal: "5"),
          value: 5
        )
      )
    )

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
  }
}
