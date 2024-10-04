# Simple 3 - a useless programming language implemented in Javascript
## for testing code generation tools.

This is the ideal programming langauge for people who know that programming is overrated.

Long ago and far away, I wrote an [article](https://www.codeproject.com/Articles/129965/The-Whole-Shebang-Building-your-own-general-purpos) about making a langauge using Devin Cook's Gold Parser Builder in C#.
This is an attempt to recreate the same language with an in-browser REPL using coder tools 'aider-chat' and Various LLMs, including:
* Gemini 1.5 Flash
* Github Copilot Pro
* Claude 3.5 Sonnet

## Demo
There is a demo of this REPL working in [Github Pages](https://dolan.github.io/simple3-repl-js/index.html)

## The Grammar
The original grammar in it's full Gold Parser EBNF notation is available in the prompt (and right here below, for fun)
```
"Name"    = 'Simple'
"Author"  = 'Devin Cook (dave dolan added stuff)'
"Version" = '3.0' 
"About"   = 'This is a very simple grammar designed for use in examples'

"Case Sensitive" = False 
"Start Symbol"   = <Statements>

{String Ch 1} = {Printable} - ['']
{String Ch 2} = {Printable} - ["]

Id            = {Letter}{AlphaNumeric}*

! String allows either single or double quotes

StringLiteral = ''   {String Ch 1}* ''
              | '"'  {String Ch 2}* '"'


NumberLiteral = {Digit}+('.'{Digit}+)?


<Statements> ::= <StatementOrBlock> <Statements>
               | <StatementOrBlock> 

<StatementOrBlock> ::= <Statement>
                       | begin <Statements> end 

<Statement>  ::= print <Expression> 
               | print <Expression> read ID  
               | ID '=' <Expression> 
               | loop <Statements> while <Expression> 
               | for '(' <Statement> ';' <Expression> ';' <Statement> ')' do <Statements> end
               | while <Expression> do <Statements> end
               | if <Expression> then <Statements> end
               | if <Expression> then <Statements> else <Statements> end
               | function ID '(' <OptionalParamList> ')' begin <Statements> end
               | return <Expression>              

<OptionalParamList> ::= <ParamList>
                      |

<ParamList> ::= ID ',' <ParamList>
              | ID


<Expression>   ::= <Expression> '>'  <Add Exp> 
                 | <Expression> '<'  <Add Exp> 
                 | <Expression> '<=' <Add Exp> 
                 | <Expression> '>=' <Add Exp>
                 | <Expression> '==' <Add Exp>
                 | <Expression> '<>' <Add Exp>
                 | <Add Exp> 

<Add Exp>      ::= <Add Exp> '+' <Mult Exp>
                 | <Add Exp> '-' <Mult Exp>
                 | <Add Exp> '&' <Mult Exp>
                 | <Mult Exp> 

<Mult Exp>    ::= <Mult Exp> '*' <Negate Exp> 
                | <Mult Exp> '/' <Negate Exp> 
                | <Negate Exp> 

<Negate Exp>  ::= '-' <Value> 
                | <Value> 

<Value>       ::= ID           
                | StringLiteral
                | NumberLiteral                
                | ID '(' <OptionalArgumentList> ')'
                | '(' <Expression> ')'
               
<OptionalArgumentList> ::= <ArgumentList>
                         |

<ArgumentList> ::= <Expression> ',' <ArgumentList>
                 | <Expression>
```
This tool is attempting to implement this project in Jison

A Jison Lesson and cheat sheet for the grammar (by Google Gemini Flash)
----------

Let's break down how the grammar works, using an example from `grammar.jison`.

**Understanding the Grammar**

The grammar defines the structure of the language. It's like a blueprint for how valid programs are constructed. Here's a breakdown of the key concepts:

* **Terminals:** These are the basic building blocks of the language. They are the actual words, symbols, and literals that appear in the code. In our grammar, terminals include:
    * Keywords: `print`, `read`, `loop`, `while`, `for`, `do`, `end`, `if`, `then`, `else`, `function`, `return`, `begin`
    * Operators: `=`, `>`, `<`, `<=`, `>=`, `==`, `<>`, `+`, `-`, `&`, `*`, `/`, `(`, `)`, `;`, `,`
    * Identifiers: `ID` (representing variable names)
    * Literals: `NUMBER`, `STRING` (representing numbers and strings)
    * Special Symbols: `EOF` (end of file)

* **Non-terminals:** These represent abstract grammatical constructs. They are defined by rules that specify how they can be composed from other non-terminals and terminals. In our grammar, non-terminals include:
    * `program`: Represents the entire program.
    * `statements`: Represents a sequence of statements.
    * `statementOrBlock`: Represents either a single statement or a block of statements.
    * `statement`: Represents a single statement.
    * `expression`: Represents an expression that evaluates to a value.
    * `addExp`: Represents an addition expression.
    * `multExp`: Represents a multiplication expression.
    * `negateExp`: Represents a negation expression.
    * `value`: Represents a basic value (like a variable, literal, or function call).
    * `optionalParamList`: Represents an optional list of parameters for a function.
    * `paramList`: Represents a list of parameters for a function.
    * `optionalArgumentList`: Represents an optional list of arguments for a function call.
    * `argumentList`: Represents a list of arguments for a function call.

**Example: `IF` Statement**

Let's look at the `IF` statement rule in `grammar.jison`:

```javascript
statement
    : IF expression THEN statements END
        { return $$ = { type: 'if', expression: $2, statements: $4 }; }
    | IF expression THEN statements ELSE statements END
        { return $$ = { type: 'if_else', expression: $2, thenStatements: $4, elseStatements: $6 }; }
    ;
```

**Breakdown:**

1. **Non-terminal:** The rule starts with `statement`, indicating that this rule defines a valid statement.
2. **Alternatives:** The rule has two alternatives, separated by `|`. This means an `IF` statement can take one of two forms:
    * **Simple `IF`:** `IF expression THEN statements END`
    * **`IF-ELSE`:** `IF expression THEN statements ELSE statements END`
3. **Terminals:** The rule uses the following terminals:
    * `IF`, `THEN`, `ELSE`, `END` (keywords)
    * `expression` (non-terminal)
    * `statements` (non-terminal)
4. **Semantic Actions:** The curly braces `{}` contain semantic actions, which are JavaScript code that is executed when the parser successfully matches the rule. These actions are used to build the abstract syntax tree (AST) representation of the program.

**Step-by-Step Example:**

Let's say we have the following code:

```
if x > 5 then
  print "Hello"
end
```

Here's how the parser would process this code using the `IF` statement rule:

1. **Match `IF`:** The parser encounters the `IF` keyword, matching the first terminal in the rule.
2. **Match `expression`:** The parser recursively calls the `expression` rule to parse the expression `x > 5`.
3. **Match `THEN`:** The parser encounters the `THEN` keyword, matching the next terminal.
4. **Match `statements`:** The parser recursively calls the `statements` rule to parse the statement `print "Hello"`.
5. **Match `END`:** The parser encounters the `END` keyword, matching the final terminal.
6. **Semantic Action:** The parser executes the semantic action associated with the `IF` rule, creating an AST node of type `'if'` with the parsed expression and statements as its children.

**Key Points:**

* The grammar defines the valid syntax of the language.
* Terminals are the basic building blocks of the language.
* Non-terminals represent abstract grammatical constructs.
* Semantic actions are used to build the AST representation of the program.

**Semantic Action Notation**

In Jison, semantic actions are JavaScript code enclosed within curly braces `{}` that are executed when the parser successfully matches a rule. These actions are used to:

* **Build the AST:**  The primary purpose of semantic actions is to construct the AST, which is a tree-like representation of the program's structure.
* **Perform other actions:**  Semantic actions can also be used for tasks like:
    * Generating code.
    * Performing type checking.
    * Reporting errors.

**Variables in Semantic Actions**

The variables used in semantic actions are numbered based on their position in the rule. For example, in the `IF` statement rule:

```javascript
statement
    : IF expression THEN statements END
        { return $$ = { type: 'if', expression: $2, statements: $4 }; }
    ;
```

* `$$`: Represents the result of the current rule. This is the value that will be returned by the rule.
* `$1`, `$2`, `$3`, etc.: Represent the results of the sub-rules or terminals matched in the current rule. The numbers correspond to their positions in the rule.

**Relating Variables to the Return Structure**

The semantic action uses these variables to build the AST node for the current rule. The `return` statement in the semantic action specifies the structure of the AST node.

**Example: `IF` Statement**

Let's break down the semantic action for the `IF` statement rule:

```javascript
{ return $$ = { type: 'if', expression: $2, statements: $4 }; }
```

1. **`$$`:** This variable will hold the AST node for the `IF` statement.
2. **`$2`:** This variable holds the result of the `expression` sub-rule, which is the condition of the `IF` statement.
3. **`$4`:** This variable holds the result of the `statements` sub-rule, which is the block of statements to be executed if the condition is true.

The semantic action creates an object with the following properties:

* **`type`:**  `'if'` indicates that this is an `IF` statement node.
* **`expression`:**  The parsed expression representing the condition.
* **`statements`:**  The parsed statements to be executed if the condition is true.

**In Summary:**

* Semantic actions are JavaScript code that executes when a rule is matched.
* Variables in semantic actions represent the results of sub-rules and terminals.
* The `return` statement in the semantic action defines the structure of the AST node.
