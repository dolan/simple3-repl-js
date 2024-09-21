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
        { return $$ = { type: 'program', statements: $1 }; }
    ;

statements
    : statementOrBlock statements
        { return $$ = $1.concat($2); }
    | statementOrBlock
        { return $$ = [$1]; }
    ;

statementOrBlock
    : statement
        { return $$ = [$1]; }
    | BEGIN statements END
        { return $$ = $2; }
    ;

statement
    : PRINT expression
        { return $$ = { type: 'print', expression: $2 }; }
    | PRINT expression READ ID
        { return $$ = { type: 'print_read', expression: $2, id: $4 }; }
    | ID '=' expression
        { return $$ = { type: 'assignment', id: $1, expression: $3 }; }
    | LOOP statements WHILE expression
        { return $$ = { type: 'loop', statements: $2, expression: $4 }; }
    | FOR '(' statement ';' expression ';' statement ')' DO statements END
        { return $$ = { type: 'for', init: $3, condition: $5, update: $7, statements: $10 }; }
    | WHILE expression DO statements END
        { return $$ = { type: 'while', expression: $2, statements: $4 }; }
    | IF expression THEN statements END
        { return $$ = { type: 'if', expression: $2, statements: $4 }; }
    | IF expression THEN statements ELSE statements END
        { return $$ = { type: 'if_else', expression: $2, thenStatements: $4, elseStatements: $6 }; }
    | FUNCTION ID '(' optionalParamList ')' BEGIN statements END
        { return $$ = { type: 'function', id: $2, params: $4, statements: $7 }; }
    | RETURN expression
        { return $$ = { type: 'return', expression: $2 }; }
    ;

optionalParamList
    : paramList
        { return $$ = $1; }
    |
        { return $$ = []; }
    ;

paramList
    : ID ',' paramList
        { return $$ = [$1].concat($3); }
    | ID
        { return $$ = [$1]; }
    ;

expression
    : expression '>' addExp
        { return $$ = { type: '>', left: $1, right: $3 }; }
    | expression '<' addExp
        { return $$ = { type: '<', left: $1, right: $3 }; }
    | expression '<=' addExp
        { return $$ = { type: '<=', left: $1, right: $3 }; }
    | expression '>=' addExp
        { return $$ = { type: '>=', left: $1, right: $3 }; }
    | expression '==' addExp
        { return $$ = { type: '==', left: $1, right: $3 }; }
    | expression '<>' addExp
        { return $$ = { type: '<>', left: $1, right: $3 }; }
    | addExp
        { return $$ = $1; }
    ;

addExp
    : addExp '+' multExp
        { return $$ = { type: '+', left: $1, right: $3 }; }
    | addExp '-' multExp
        { return $$ = { type: '-', left: $1, right: $3 }; }
    | addExp '&' multExp
        { return $$ = { type: '&', left: $1, right: $3 }; }
    | multExp
        { return $$ = $1; }
    ;

multExp
    : multExp '*' negateExp
        { return $$ = { type: '*', left: $1, right: $3 }; }
    | multExp '/' negateExp
        { return $$ = { type: '/', left: $1, right: $3 }; }
    | negateExp
        { return $$ = $1; }
    ;

negateExp
    : '-' value
        { return $$ = { type: '-', value: $2 }; }
    | value
        { return $$ = $1; }
    ;

value
    : ID
        { return $$ = { type: 'id', value: $1 }; }
    | STRING
        { return $$ = { type: 'string', value: $1 }; }
    | NUMBER
        { return $$ = { type: 'number', value: $1 }; }
    | ID '(' optionalArgumentList ')'
        { return $$ = { type: 'function_call', id: $1, args: $3 }; }
    | '(' expression ')'
        { return $$ = $2; }
    ;

optionalArgumentList
    : argumentList
        { return $$ = $1; }
    |
        { return $$ = []; }
    ;

argumentList
    : expression ',' argumentList
        { return $$ = [$1].concat($3); }
    | expression
        { return $$ = [$1]; }
    ;
