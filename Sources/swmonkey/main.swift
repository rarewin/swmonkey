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

  while let statement = parser.next() {
    print(statement)
  }

  print(prompt, terminator: "")
}
