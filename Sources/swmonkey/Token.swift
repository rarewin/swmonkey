class Token {

  enum TokenType {
    /// invalid token
    case illegal
    /// End of File
    case eof

    /// Identifier
    case ident
    /// Integer
    case int

    /// `='
    case assign
    /// `+'
    case plus
    /// `-'
    case minus
    /// `!'
    case bang
    /// `*'
    case asterisk
    /// `/'
    case slash

    /// `<'
    case lt
    /// `>'
    case gt

    /// `=='
    case eq
    /// `!='
    case notEq

    /// `,'
    case comma
    /// `;'
    case semicolon
    /// `:'
    case colon

    /// `('
    case leftParen
    /// `)'
    case rightParen
    /// `{'
    case leftBrace
    /// `}'
    case rightBrace
    /// `['
    case leftBracket
    /// `]'
    case rightBracket

    /// function `fn`
    case function
    /// let
    case `let`
    /// true
    case `true`
    /// false
    case `false`
    /// if
    case `if`
    /// else
    case `else`
    /// return
    case `return`

    /// string
    case string
  }

  let tokenType: TokenType
  let literal: String

  init(tokenType: TokenType, literal: String) {
    self.tokenType = tokenType
    self.literal = literal
  }
}

extension Token: Equatable {
  public static func == (lhs: Token, rhs: Token) -> Bool {
    return (lhs.tokenType == rhs.tokenType) && (lhs.literal == rhs.literal)
  }
}

extension Token: TextOutputStreamable {
  func write<Target: TextOutputStream>(to target: inout Target) {
    print("Token{type: \(tokenType), literal: \(literal)}", terminator: "", to: &target)
  }
}
