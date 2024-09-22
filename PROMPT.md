We are going to construct an in-browser REPL for a custom language interpreter that we are going to build in Javascript.

We are going to use an LALR(1) grammar written in Devin Cook's EBNF Notation from Gold Parser Builder as a source template for generating the grammar and filling in as much of the semantic actions as we can do automatically. We will translate that grammar into a Jison lexer and parser for the same langauge (Simple 3, as per the grammar).

Grammar: (As specified in the [article](https://www.codeproject.com/Articles/129965/The-Whole-Shebang-Building-your-own-general-purpos) dave wrote in 2010)
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

The operator precedence should be implemented as shown in the expressions section of the grammar, taking PEMDAS type situations into account automatically.

Here is a rough attempt at creating the grammar in Jison format:
```JS
/* Lexer rules */
%lex

%%
\s+                   /* skip whitespace */
"print"               return 'PRINT'
"read"                return 'READ'
"loop"                return 'LOOP'
"while"               return 'WHILE'
"for"                 return 'FOR'
"do"                  return 'DO'
"end"                 return 'END'
"if"                  return 'IF'
"then"                return 'THEN'
"else"                return 'ELSE'
"function"            return 'FUNCTION'
"return"              return 'RETURN'
"begin"               return 'BEGIN'
[a-zA-Z][a-zA-Z0-9]*  return 'ID'
[0-9]+("."[0-9]+)?    return 'NUMBER'
"'"[^']*"'"           return 'STRING'
'"'[^"]*'"'           return 'STRING'
"="                   return '='
">"                   return '>'
"<"                   return '<'
"<="                  return '<='
">="                  return '>='
"=="                  return '=='
"<>"                  return '<>'
"+"                   return '+'
"-"                   return '-'
"&"                   return '&'
"*"                   return '*'
"/"                   return '/'
"("                   return '('
")"                   return ')'
";"                   return ';'
","                   return ','
<<EOF>>               return 'EOF'

/lex

/* Parser rules */
%start program

%%

program
    : statements EOF
    ;

statements
    : statementOrBlock statements
    | statementOrBlock
    ;

statementOrBlock
    : statement
    | BEGIN statements END
    ;

statement
    : PRINT expression
    | PRINT expression READ ID
    | ID '=' expression
    | LOOP statements WHILE expression
    | FOR '(' statement ';' expression ';' statement ')' DO statements END
    | WHILE expression DO statements END
    | IF expression THEN statements END
    | IF expression THEN statements ELSE statements END
    | FUNCTION ID '(' optionalParamList ')' BEGIN statements END
    | RETURN expression
    ;

optionalParamList
    : paramList
    |
    ;

paramList
    : ID ',' paramList
    | ID
    ;

expression
    : expression '>' addExp
    | expression '<' addExp
    | expression '<=' addExp
    | expression '>=' addExp
    | expression '==' addExp
    | expression '<>' addExp
    | addExp
    ;

addExp
    : addExp '+' multExp
    | addExp '-' multExp
    | addExp '&' multExp
    | multExp
    ;

multExp
    : multExp '*' negateExp
    | multExp '/' negateExp
    | negateExp
    ;

negateExp
    : '-' value
    | value
    ;

value
    : ID
    | STRING
    | NUMBER
    | ID '(' optionalArgumentList ')'
    | '(' expression ')'
    ;

optionalArgumentList
    : argumentList
    |
    ;

argumentList
    : expression ',' argumentList
    | expression
    ;
```
