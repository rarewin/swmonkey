import XCTest

@testable import swmonkey

final class swmonkeyTests: XCTestCase {

  func testNextToken() throws {
    let input = """
      =+(){},; let five = 5;
      let ten = 10;

      let add = fn(x, y) {
        x + y;
      };

      let result = add(five, ten);
      !-/*5;
      5 < 10 > 5;

      if (5 < 10) {
        return true;
      } else {
        return false;
      }

      10 == 10;
      10 != 9;

      "foobar"
      "foo bar"

      [1, 2];

      {"foo": "bar"}
      """

    let expects: [(Token.TokenType, String)] = [
      (Token.TokenType.assign, "="),
      (Token.TokenType.plus, "+"),
      (Token.TokenType.leftParen, "("),
      (Token.TokenType.rightParen, ")"),
      (Token.TokenType.leftBrace, "{"),
      (Token.TokenType.rightBrace, "}"),
      (Token.TokenType.comma, ","),
      (Token.TokenType.semicolon, ";"),
      (Token.TokenType.let, "let"),
      (Token.TokenType.ident, "five"),
      (Token.TokenType.assign, "="),
      (Token.TokenType.int, "5"),
      (Token.TokenType.semicolon, ";"),

      (Token.TokenType.let, "let"),
      (Token.TokenType.ident, "ten"),
      (Token.TokenType.assign, "="),
      (Token.TokenType.int, "10"),
      (Token.TokenType.semicolon, ";"),

      (Token.TokenType.let, "let"),
      (Token.TokenType.ident, "add"),
      (Token.TokenType.assign, "="),
      (Token.TokenType.function, "fn"),
      (Token.TokenType.leftParen, "("),
      (Token.TokenType.ident, "x"),
      (Token.TokenType.comma, ","),
      (Token.TokenType.ident, "y"),
      (Token.TokenType.rightParen, ")"),
      (Token.TokenType.leftBrace, "{"),
      (Token.TokenType.ident, "x"),
      (Token.TokenType.plus, "+"),
      (Token.TokenType.ident, "y"),
      (Token.TokenType.semicolon, ";"),
      (Token.TokenType.rightBrace, "}"),
      (Token.TokenType.semicolon, ";"),
    ]
    let lexer = Lexer(input: input)

    for e in expects {
      XCTAssertEqual(lexer.next(), Token(tokenType: e.0, literal: e.1))
    }
  }
}
