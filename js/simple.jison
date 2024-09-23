/* Lexical Grammar */
%lex

%%
\s+                   /* skip whitespace */
"print"               return 'PRINT'
"read"                return 'READ'
"loop"                return 'LOOP'
"while"               return 'WHILE'
"for"                 return 'FOR'
"do"                  return 'DO'
"if"                  return 'IF'
"then"                return 'THEN'
"else"                return 'ELSE'
"end"                 return 'END'
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

/* Operator Associations and Precedence */

%left '>' '<' '<=' '>=' '==' '<>'
%left '+' '-' '&'
%left '*' '/'
%right UMINUS

%start program

%% /* Language Grammar */

program
    : statements EOF
        { return $1; }
    ;

statements
    : statement
        { $$ = [$1]; }
    | statement statements
        { $$ = [$1].concat($2); }
    ;

statement
    : PRINT expression
        { $$ = { type: 'Print', expression: $2 }; }
    | PRINT expression READ ID
        { $$ = { type: 'PrintRead', expression: $2, variable: $4 }; }
    | ID '=' expression
        { $$ = { type: 'Assignment', variable: $1, expression: $3 }; }
    | LOOP statements WHILE expression
        { $$ = { type: 'LoopWhile', body: $2, condition: $4 }; }
    | FOR '(' statement ';' expression ';' statement ')' DO statements END
        { $$ = { type: 'For', init: $3, condition: $5, update: $7, body: $10 }; }
    | WHILE expression DO statements END
        { $$ = { type: 'While', condition: $2, body: $4 }; }
    | IF expression THEN statements END
        { $$ = { type: 'If', condition: $2, thenBody: $4 }; }
    | IF expression THEN statements ELSE statements END
        { $$ = { type: 'IfElse', condition: $2, thenBody: $4, elseBody: $6 }; }
    | FUNCTION ID '(' optionalParamList ')' BEGIN statements END
        { $$ = { type: 'FunctionDeclaration', name: $2, params: $4, body: $7 }; }
    | RETURN expression
        { $$ = { type: 'Return', expression: $2 }; }
    | BEGIN statements END
        { $$ = { type: 'Block', statements: $2 }; }
    ;

optionalParamList
    : paramList
        { $$ = $1; }
    |
        { $$ = []; }
    ;

paramList
    : ID
        { $$ = [$1]; }
    | ID ',' paramList
        { $$ = [$1].concat($3); }
    ;

expression
    : expression '>' addExp
        { $$ = { type: 'BinaryOp', operator: '>', left: $1, right: $3 }; }
    | expression '<' addExp
        { $$ = { type: 'BinaryOp', operator: '<', left: $1, right: $3 }; }
    | expression '<=' addExp
        { $$ = { type: 'BinaryOp', operator: '<=', left: $1, right: $3 }; }
    | expression '>=' addExp
        { $$ = { type: 'BinaryOp', operator: '>=', left: $1, right: $3 }; }
    | expression '==' addExp
        { $$ = { type: 'BinaryOp', operator: '==', left: $1, right: $3 }; }
    | expression '<>' addExp
        { $$ = { type: 'BinaryOp', operator: '<>', left: $1, right: $3 }; }
    | addExp
        { $$ = $1; }
    ;

addExp
    : addExp '+' multExp
        { $$ = { type: 'BinaryOp', operator: '+', left: $1, right: $3 }; }
    | addExp '-' multExp
        { $$ = { type: 'BinaryOp', operator: '-', left: $1, right: $3 }; }
    | addExp '&' multExp
        { $$ = { type: 'BinaryOp', operator: '&', left: $1, right: $3 }; }
    | multExp
        { $$ = $1; }
    ;

multExp
    : multExp '*' negateExp
        { $$ = { type: 'BinaryOp', operator: '*', left: $1, right: $3 }; }
    | multExp '/' negateExp
        { $$ = { type: 'BinaryOp', operator: '/', left: $1, right: $3 }; }
    | negateExp
        { $$ = $1; }
    ;

negateExp
    : '-' value %prec UMINUS
        { $$ = { type: 'UnaryOp', operator: '-', expression: $2 }; }
    | value
        { $$ = $1; }
    ;

value
    : ID
        { $$ = { type: 'Identifier', name: $1 }; }
    | STRING
        { $$ = { type: 'StringLiteral', value: $1.slice(1, -1) }; }
    | NUMBER
        { $$ = { type: 'NumberLiteral', value: Number($1) }; }
    | ID '(' optionalArgumentList ')'
        { $$ = { type: 'FunctionCall', name: $1, arguments: $3 }; }
    | '(' expression ')'
        { $$ = $2; }
    ;

optionalArgumentList
    : argumentList
        { $$ = $1; }
    |
        { $$ = []; }
    ;

argumentList
    : expression
        { $$ = [$1]; }
    | expression ',' argumentList
        { $$ = [$1].concat($3); }
    ;
