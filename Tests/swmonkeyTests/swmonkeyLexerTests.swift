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

    let expects = [
      Token.assign,
      Token.plus,
      Token.leftParen,
      Token.rightParen,
      Token.leftBrace,
      Token.rightBrace,
      Token.comma,
      Token.semicolon,
      Token.let,
      Token.ident(literal: "five"),
      Token.assign,
      Token.int(value: 5),
      Token.semicolon,

      Token.let,
      Token.ident(literal: "ten"),
      Token.assign,
      Token.int(value: 10),
      Token.semicolon,

      Token.let,
      Token.ident(literal: "add"),
      Token.assign,
      Token.function,
      Token.leftParen,
      Token.ident(literal: "x"),
      Token.comma,
      Token.ident(literal: "y"),
      Token.rightParen,
      Token.leftBrace,
      Token.ident(literal: "x"),
      Token.plus,
      Token.ident(literal: "y"),
      Token.semicolon,
      Token.rightBrace,
      Token.semicolon,

      Token.let,
      Token.ident(literal: "result"),
      Token.assign,
      Token.ident(literal: "add"),
      Token.leftParen,
      Token.ident(literal: "five"),
      Token.comma,
      Token.ident(literal: "ten"),
      Token.rightParen,
      Token.semicolon,

      Token.bang,
      Token.minus,
      Token.slash,
      Token.asterisk,
      Token.int(value: 5),
      Token.semicolon,

      Token.int(value: 5),
      Token.lt,
      Token.int(value: 10),
      Token.gt,
      Token.int(value: 5),
      Token.semicolon,

      Token.if,
      Token.leftParen,
      Token.int(value: 5),
      Token.lt,
      Token.int(value: 10),
      Token.rightParen,
      Token.leftBrace,
      Token.return,
      Token.true,
      Token.semicolon,
      Token.rightBrace,
      Token.else,
      Token.leftBrace,
      Token.return,
      Token.false,
      Token.semicolon,
      Token.rightBrace,

      Token.int(value: 10),
      Token.eq,
      Token.int(value: 10),
      Token.semicolon,

      Token.int(value: 10),
      Token.notEq,
      Token.int(value: 9),
      Token.semicolon,

      Token.string(string: "foobar"),
      Token.string(string: "foo bar"),

      Token.leftBracket,
      Token.int(value: 1),
      Token.comma,
      Token.int(value: 2),
      Token.rightBracket,
      Token.semicolon,

      Token.leftBrace,
      Token.string(string: "foo"),
      Token.colon,
      Token.string(string: "bar"),
      Token.rightBrace,
    ]

    let lexer = Lexer(input: input)

    expects.forEach { expectedToken in
      XCTAssertEqual(expectedToken, lexer.next())
    }
  }
}
