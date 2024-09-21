// This is a simple REPL for the Simple 3 language.
// It uses Jison to parse the grammar and then executes the AST.

// Load the Jison grammar (using a script tag in index.html)
// This assumes grammar.jison is compiled to grammar.js
// using `jison grammar.jison`

// Global environment for variables
const env = {};

// Define the parser globally
let parser;

// Function to initialize the parser
function initializeParser() {
  if (typeof grammar === 'object' && typeof grammar.parser === 'object') {
    // If grammar.parser is an object (Jison 0.4.18+)
    parser = new grammar.Parser();
  } else if (typeof grammar === 'function') {
    // If grammar is a function (older Jison versions)
    parser = new grammar();
  } else {
    throw new Error('Unable to initialize parser. Check Jison output.');
  }
}

// Function to evaluate an expression
function evaluateExpression(expression, env) {
  switch (expression.type) {
    case 'id':
      return env[expression.value];
    case 'number':
      return parseFloat(expression.value);
    case 'string':
      return expression.value.slice(1, -1); // Remove quotes
    case '+':
      return evaluateExpression(expression.left, env) + evaluateExpression(expression.right, env);
    case '-':
      return evaluateExpression(expression.left, env) - evaluateExpression(expression.right, env);
    case '&':
      return evaluateExpression(expression.left, env) && evaluateExpression(expression.right, env);
    case '*':
      return evaluateExpression(expression.left, env) * evaluateExpression(expression.right, env);
    case '/':
      return evaluateExpression(expression.left, env) / evaluateExpression(expression.right, env);
    case '>':
      return evaluateExpression(expression.left, env) > evaluateExpression(expression.right, env);
    case '<':
      return evaluateExpression(expression.left, env) < evaluateExpression(expression.right, env);
    case '<=':
      return evaluateExpression(expression.left, env) <= evaluateExpression(expression.right, env);
    case '>=':
      return evaluateExpression(expression.left, env) >= evaluateExpression(expression.right, env);
    case '==':
      return evaluateExpression(expression.left, env) === evaluateExpression(expression.right, env);
    case '<>':
      return evaluateExpression(expression.left, env) !== evaluateExpression(expression.right, env);
    case '-': // Unary negation
      return -evaluateExpression(expression.value, env);
    case 'function_call':
      const args = expression.args.map(arg => evaluateExpression(arg, env));
      return env[expression.id](...args);
    default:
      throw new Error(`Unknown expression type: ${expression.type}`);
  }
}

// Function to execute a statement
function executeStatement(statement, env) {
  switch (statement.type) {
    case 'print':
      console.log(evaluateExpression(statement.expression, env));
      break;
    case 'print_read':
      const value = prompt(evaluateExpression(statement.expression, env));
      env[statement.id] = value;
      break;
    case 'assignment':
      env[statement.id] = evaluateExpression(statement.expression, env);
      break;
    case 'loop':
      while (evaluateExpression(statement.expression, env)) {
        statement.statements.forEach(s => executeStatement(s, env));
      }
      break;
    case 'for':
      executeStatement(statement.init, env);
      while (evaluateExpression(statement.condition, env)) {
        statement.statements.forEach(s => executeStatement(s, env));
        executeStatement(statement.update, env);
      }
      break;
    case 'while':
      while (evaluateExpression(statement.expression, env)) {
        statement.statements.forEach(s => executeStatement(s, env));
      }
      break;
    case 'if':
      if (evaluateExpression(statement.expression, env)) {
        statement.statements.forEach(s => executeStatement(s, env));
      }
      break;
    case 'if_else':
      if (evaluateExpression(statement.expression, env)) {
        statement.thenStatements.forEach(s => executeStatement(s, env));
      } else {
        statement.elseStatements.forEach(s => executeStatement(s, env));
      }
      break;
    case 'function':
      env[statement.id] = (...args) => {
        const localEnv = { ...env };
        statement.params.forEach((param, index) => {
          localEnv[param] = args[index];
        });
        statement.statements.forEach(s => executeStatement(s, localEnv));
      };
      break;
    case 'return':
      return evaluateExpression(statement.expression, env);
    default:
      throw new Error(`Unknown statement type: ${statement.type}`);
  }
}

// Main REPL loop
function repl() {
  const input = document.getElementById('input');
  const output = document.getElementById('output');

  const code = input.value;
  try {
    const ast = parser.parse(code);
    ast.statements.forEach(statement => {
      const result = executeStatement(statement, env);
      if (result !== undefined) {
        output.textContent += result + '\n';
      }
    });
  } catch (error) {
    output.textContent += error + '\n';
  }
  input.value = ''; // Clear the input field
}

// Start the REPL
document.addEventListener('DOMContentLoaded', () => {
  const runButton = document.getElementById('run-button');
  // Initialize the parser after the DOM is loaded
  try {
    initializeParser();
    console.log('Parser initialized successfully');
  } catch (error) {
    console.error('Error initializing parser:', error);
  }
  runButton.addEventListener('click', repl);
});
