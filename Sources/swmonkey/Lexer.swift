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
        let ch = self.input.removeFirst()

        switch ch {
            case "=":
                return Token(tokenType: Token.TokenType.eq, literal: ch.description)
            default:
                return Token(tokenType: Token.TokenType.illegal, literal: ch.description)
        }
    }
}

extension Token.TokenType {
    init(_: String) {
        self = .illegal
    }
}