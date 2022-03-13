import XCTest

@testable import swmonkey

final class swmonkeyParserTests: XCTestCase {
  func testLetStatements() throws {
    let lexer = Lexer(input: "let x = 5;")
    let parser = Parser(lexer: lexer)

    // XCTAssertEqual(
    //   parser.next(),
    //   Ast.StatementNode.letStatement(
    //     name: Token(tokenType: Token.TokenType.let, literal: "let"),
    //     value: Ast.ExpressionNode)()
    // )

    XCTAssertEqual(
      Ast.ExpressionNode.identifier(token: Token(tokenType: Token.TokenType.assign, literal: "=")),
      Ast.ExpressionNode.identifier(token: Token(tokenType: Token.TokenType.assign, literal: "="))
    )

    XCTAssertNotEqual(
      Ast.ExpressionNode.identifier(token: Token(tokenType: Token.TokenType.assign, literal: "=")),
      Ast.ExpressionNode.identifier(token: Token(tokenType: Token.TokenType.eq, literal: "=="))
    )
  }
}
