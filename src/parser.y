%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <math.h>
    int yylex();
    void yyerror(const char *s);

    // Needed to access yylineno from lexer.l
    extern int yylineno;

    double previous_result = 0;
%}

%locations

%union {
    double number;
}

%token <number> NUMBER
%token ADD SUBTRACT MULTIPLY DIVIDE POWER ANS FACTORIAL SIN COS TAN LOG PI E

%type <number> exp

%left ADD SUBTRACT
%left MULTIPLY DIVIDE // Has higher precedence than ADD and SUBTRACT
%right POWER // Has higher precedence than MULTIPLY and DIVIDE
%right SIN COS TAN LOG FACTORIAL

%define parse.error verbose

%%

input: /* empty string */
    | input exp '\n' { printf("%lf\n", $2); previous_result = $2;}
    | input exp { printf("%lf\n", $2); previous_result = $2;}
    ;

exp: NUMBER { $$ = $1; }
    | PI { $$ = M_PI; }
    | E { $$ = M_E; }
    | ANS { $$ = previous_result; }
    | SIN exp { $$ = sin($2); }
    | COS exp { $$ = cos($2); }
    | TAN exp { $$ = tan($2); }
    | LOG exp { $$ = log($2); }
    | LOG '(' exp ',' exp ')' { $$ = log($3) / log($5); }
    | exp ADD exp { $$ = $1 + $3; }
    | SUBTRACT exp { $$ = -$2; }
    | exp SUBTRACT exp { $$ = $1 - $3; }
    | exp POWER exp { $$ = pow($1, $3); }
    | exp MULTIPLY exp { $$ = $1 * $3; }
    | exp DIVIDE exp { if ($3 == 0.0) yyerror("divide by zero"); else $$ = $1 / $3; }
    | exp FACTORIAL { double result = 1; for (double i = 1; i <= $1; i++) result *= i; $$ = result; }
    | '(' exp ')' { $$ = $2; }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error [Line: %d]: %s\n", yylineno, s);
    exit(1);
}

int main() {
    yyparse();
    return 0;
}