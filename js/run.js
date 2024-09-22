const Parser = require('./simple').Parser;
const Interpreter = require('./interpreter');

const parser = new Parser();
const interpreter = new Interpreter();

const input = `print "hello world!"`;

try {
  const ast = parser.parse(input);
  console.log('AST:', JSON.stringify(ast, null, 2));
  interpreter.interpret(ast);
} catch (error) {
  console.error('Error:', error.message);
}