enum Token: Equatable {

  /// invalid token
  case illegal
  /// End of File
  case eof

  /// Identifier
  case ident(literal: String)
  /// Integer
  case int(value: Int64)

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
  case string(string: String)

  var literal: String {
    switch self {

    case let .ident(literal: literal): return literal
    case let .int(value: value): return String(value)

    case .assign: return "="
    case .plus: return "+"
    case .minus: return "-"
    case .bang: return "!"
    case .asterisk: return "*"
    case .slash: return "/"

    case .gt: return ">"
    case .lt: return "<"

    case .eq: return "=="
    case .notEq: return "!="

    case .let: return "let"
    default:
      fatalError("unimplemented for \(self)")
    }
  }

  public static func hasSameType(lhs: Token, rhs: Token) -> Bool {
    switch lhs {
    case .ident(_):
      if case .ident(_) = rhs {
        return true
      } else {
        return false
      }
    case .int(_):
      if case .int(_) = rhs {
        return true
      } else {
        return false
      }
    default:
      return (lhs == rhs)
    }
  }
}
