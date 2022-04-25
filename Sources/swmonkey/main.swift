let monkeyFace = #"""
              __,__
     .--.  .-"     "-.  .--.
    / .. \/  .-. .-.  \/ .. \
   | |  '|  /   Y   \  |'  | |
   | \   \  \ 0 | 0 /  /   / |
    \ '- ,\.-"""""""-./, -' /
     ''-' /_   ^ ^   _\ '-''
         |  \._   _./  |
         \   \ '~' /   /
          '._ '-=-' _.'
             '-----'
  """#

let prompt = ">> "

print(prompt, terminator: "")

while let input = readLine() {
  let lexer = Lexer(input: input)
  let parser = Parser(lexer: lexer)

  do {
    while let statement = try parser.next() {
      print(statement)
    }
  } catch let (Parser.ParseError.unexpectedToken(token: token, msg: msg)) {
    print(monkeyFace)
    print("\(token) \(msg)")
  }

  print(prompt, terminator: "")
}
