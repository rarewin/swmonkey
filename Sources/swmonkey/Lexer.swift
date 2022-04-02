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
  func next() -> Token? {

    guard self.input.first != nil else {
      return nil
    }

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
    case "0"..."9":
      while self.input.first.isDigit() {
        ch = self.input.removeFirst()
        str.append(ch.description)
      }
    case "=":
      if self.input.first == "=" {
        ch = self.input.removeFirst()
        str.append(ch.description)
      }
    case "!":
      if self.input.first == "=" {
        ch = self.input.removeFirst()
        str.append(ch.description)
      }
    case "\"":
      while self.input.first != "\"" {
        ch = self.input.removeFirst()
        str.append(ch.description)
      }
      ch = self.input.removeFirst()
      str.append(ch.description)
    default: break
    }

    return Token(str: str)
  }
}

extension Token {
  init(str: String) {
    switch str {
    case "=": self = .assign
    case "+": self = .plus
    case "-": self = .minus
    case "!": self = .bang
    case "*": self = .asterisk
    case "/": self = .slash

    case "<": self = .lt
    case ">": self = .gt

    case "==": self = .eq
    case "!=": self = .notEq

    case ",": self = .comma
    case ";": self = .semicolon
    case ":": self = .colon

    case "(": self = .leftParen
    case ")": self = .rightParen
    case "{": self = .leftBrace
    case "}": self = .rightBrace
    case "[": self = .leftBracket
    case "]": self = .rightBracket

    case "fn": self = .function
    case "let": self = .let
    case "true": self = .true
    case "false": self = .false
    case "if": self = .if
    case "else": self = .else
    case "return": self = .return

    default:
      if str.allSatisfy({ $0.isNumber }) {
        self = .int(value: Int64(str) ?? 0)
      } else if str.first == "\"" && str.last == "\"" {
        var tmp = str
        tmp.removeFirst()
        tmp.removeLast()
        self = .string(string: tmp)
      } else if str.allSatisfy({ $0.isLetter || $0 == "_" }) {
        self = .ident(literal: str)
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
    return ("0"..."9" ~= ch)
  }
}
