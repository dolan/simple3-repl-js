// Wrap the entire content of interpreter.js in a function to avoid polluting the global scope
(function(window) {
    class Interpreter {
      constructor(outputCallback) {
        this.variables = {};
        this.functions = {};
        this.output = outputCallback || console.log;
      }
  
      interpret(ast) {
        if (Array.isArray(ast)) {
          return this.evaluateStatements(ast);
        } else {
          throw new Error('Expected an array of statements');
        }
      }
  
      evaluateStatements(statements) {
        let result;
        for (const statement of statements) {
          result = this.evaluateStatement(statement);
          if (result && result.type === 'return') {
            return result.value;
          }
        }
        return result;
      }
  
      evaluateStatement(statement) {
        switch (statement.type) {
          case 'Print':
            this.output(this.evaluateExpression(statement.expression));
            break;
          case 'PrintRead':
            this.output(this.evaluateExpression(statement.expression));
            this.variables[statement.variable] = prompt("Enter a value:");
            break;
          case 'Assignment':
            this.variables[statement.variable] = this.evaluateExpression(statement.expression);
            break;
          case 'LoopWhile':
            while (this.evaluateExpression(statement.condition)) {
              this.evaluateStatements(statement.body);
            }
            break;
          case 'For':
            this.evaluateStatement(statement.init);
            while (this.evaluateExpression(statement.condition)) {
              this.evaluateStatements(statement.body);
              this.evaluateStatement(statement.update);
            }
            break;
          case 'While':
            while (this.evaluateExpression(statement.condition)) {
              this.evaluateStatements(statement.body);
            }
            break;
          case 'If':
            if (this.evaluateExpression(statement.condition)) {
              return this.evaluateStatements(statement.thenBody);
            }
            break;
          case 'IfElse':
            if (this.evaluateExpression(statement.condition)) {
              return this.evaluateStatements(statement.thenBody);
            } else {
              return this.evaluateStatements(statement.elseBody);
            }
          case 'FunctionDeclaration':
            this.functions[statement.name] = statement;
            break;
          case 'Return':
            return { type: 'return', value: this.evaluateExpression(statement.expression) };
          case 'Block':
            return this.evaluateStatements(statement.statements);
        }
      }
  
      evaluateExpression(expression) {
        switch (expression.type) {
          case 'BinaryOp':
            return this.evaluateBinaryOp(expression);
          case 'UnaryOp':
            return this.evaluateUnaryOp(expression);
          case 'Identifier':
            return this.variables[expression.name];
          case 'StringLiteral':
            return expression.value;
          case 'NumberLiteral':
            return expression.value;
          case 'FunctionCall':
            return this.evaluateFunctionCall(expression);
        }
      }
  
      evaluateBinaryOp(expression) {
        const left = this.evaluateExpression(expression.left);
        const right = this.evaluateExpression(expression.right);
        switch (expression.operator) {
          case '+': return left + right;
          case '-': return left - right;
          case '*': return left * right;
          case '/': return left / right;
          case '&': return String(left) + String(right);
          case '>': return left > right;
          case '<': return left < right;
          case '>=': return left >= right;
          case '<=': return left <= right;
          case '==': return left === right;
          case '<>': return left !== right;
        }
      }
  
      evaluateUnaryOp(expression) {
        const value = this.evaluateExpression(expression.expression);
        switch (expression.operator) {
          case '-': return -value;
        }
      }
  
      evaluateFunctionCall(expression) {
        const func = this.functions[expression.name];
        if (!func) {
          throw new Error(`Function ${expression.name} is not defined`);
        }
        const localVariables = { ...this.variables };
        for (let i = 0; i < func.params.length; i++) {
          this.variables[func.params[i]] = this.evaluateExpression(expression.arguments[i]);
        }
        const result = this.evaluateStatements(func.body);
        this.variables = localVariables;
        return result;
      }
    }
  
    // Expose the Interpreter class to the window object
    if (typeof window !== 'undefined') {
      window.Interpreter = Interpreter;
    }
  })(typeof window !== 'undefined' ? window : this);