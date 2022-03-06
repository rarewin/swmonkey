class Lexer {
  /// 入力文字列
  var input: String.UnicodeScalarView

  /// イニシャライザ
  ///
  /// - Parameters:
  ///    - input: 入力文字列
  init(input: String) {
    self.input = input.unicodeScalars
  }

  /// 次のトークンを取得する
  func next() -> Token {
    var ch = self.input.removeFirst()

    while ch.properties.isWhitespace {
      ch = self.input.removeFirst()
    }

    var str = ch.description

    switch ch {
    case "a"..."z", "A"..."Z", "_":
      while (self.input.first?.properties.isAlphabetic ?? false) || self.input.first == "_" {
        ch = self.input.removeFirst()
        str.append(ch.description)
      }
      break
    case "0"..."9":
      while self.input.first.isDigit() {
        ch = self.input.removeFirst()
        str.append(ch.description)
      }
    default: break
    }

    return Token(tokenType: Token.TokenType(str: str), literal: str)
  }
}

extension Token.TokenType {
  init(str: String) {
    switch str {
    case "=": self = .assign
    case "+": self = .plus

    case ",": self = .comma
    case ";": self = .semicolon

    case "(": self = .leftParen
    case ")": self = .rightParen
    case "{": self = .leftBrace
    case "}": self = .rightBrace

    case "let": self = .let

    default:
      if str.allSatisfy({ $0.isLetter || $0 == "_" }) {
        self = .ident
      } else if str.allSatisfy({ $0.isNumber }) {
        self = .int
      } else {
        self = .illegal
      }
    }
  }
}

extension Optional where Wrapped == Unicode.Scalar {
  func isDigit() -> Bool {
    guard let ch = self else {
      return false
    }
    switch ch {
    case "0"..."9": return true
    default: return false
    }
  }
}
