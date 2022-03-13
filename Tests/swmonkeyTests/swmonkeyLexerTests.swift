import XCTest

@testable import swmonkey

final class swmonkeyLexerTests: XCTestCase {

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

      (Token.TokenType.let, "let"),
      (Token.TokenType.ident, "result"),
      (Token.TokenType.assign, "="),
      (Token.TokenType.ident, "add"),
      (Token.TokenType.leftParen, "("),
      (Token.TokenType.ident, "five"),
      (Token.TokenType.comma, ","),
      (Token.TokenType.ident, "ten"),
      (Token.TokenType.rightParen, ")"),
      (Token.TokenType.semicolon, ";"),

      (Token.TokenType.bang, "!"),
      (Token.TokenType.minus, "-"),
      (Token.TokenType.slash, "/"),
      (Token.TokenType.asterisk, "*"),
      (Token.TokenType.int, "5"),
      (Token.TokenType.semicolon, ";"),

      (Token.TokenType.int, "5"),
      (Token.TokenType.lt, "<"),
      (Token.TokenType.int, "10"),
      (Token.TokenType.gt, ">"),
      (Token.TokenType.int, "5"),
      (Token.TokenType.semicolon, ";"),

      (Token.TokenType.if, "if"),
      (Token.TokenType.leftParen, "("),
      (Token.TokenType.int, "5"),
      (Token.TokenType.lt, "<"),
      (Token.TokenType.int, "10"),
      (Token.TokenType.rightParen, ")"),
      (Token.TokenType.leftBrace, "{"),
      (Token.TokenType.return, "return"),
      (Token.TokenType.true, "true"),
      (Token.TokenType.semicolon, ";"),
      (Token.TokenType.rightBrace, "}"),
      (Token.TokenType.else, "else"),
      (Token.TokenType.leftBrace, "{"),
      (Token.TokenType.return, "return"),
      (Token.TokenType.false, "false"),
      (Token.TokenType.semicolon, ";"),
      (Token.TokenType.rightBrace, "}"),

      (Token.TokenType.int, "10"),
      (Token.TokenType.eq, "=="),
      (Token.TokenType.int, "10"),
      (Token.TokenType.semicolon, ";"),

      (Token.TokenType.int, "10"),
      (Token.TokenType.notEq, "!="),
      (Token.TokenType.int, "9"),
      (Token.TokenType.semicolon, ";"),

      (Token.TokenType.string, "foobar"),
      (Token.TokenType.string, "foo bar"),

      (Token.TokenType.leftBracket, "["),
      (Token.TokenType.int, "1"),
      (Token.TokenType.comma, ","),
      (Token.TokenType.int, "2"),
      (Token.TokenType.rightBracket, "]"),
      (Token.TokenType.semicolon, ";"),

      (Token.TokenType.leftBrace, "{"),
      (Token.TokenType.string, "foo"),
      (Token.TokenType.colon, ":"),
      (Token.TokenType.string, "bar"),
      (Token.TokenType.rightBrace, "}"),
    ]

    let lexer = Lexer(input: input)

    for e in expects {
      XCTAssertEqual(lexer.next(), Token(tokenType: e.0, literal: e.1))
    }
  }
}
