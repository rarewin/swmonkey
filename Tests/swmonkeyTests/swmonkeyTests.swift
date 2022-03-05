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
      let lexer = Lexer(input: input)

      XCTAssertEqual(lexer.next(), Token(tokenType: Token.TokenType.eq, literal: "="))
      XCTAssertEqual(lexer.next(), Token(tokenType: Token.TokenType.plus, literal: "+"))
    }
}
