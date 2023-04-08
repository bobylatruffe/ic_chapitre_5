/*
Nom : Exercice 5.3 (à rendre)
Rôle : Tester comment Yacc réagit face à une grammaire ambigüe
Auteur : Bozlak Fatih 1503001522G
Compilation : yacc exo-5-3.y && gcc -g -Wall y.tab.c
Usage : ./a.out
*/

%{
#define YYDEBUG 1
int yydebug = 0;

extern int yylex();
void yyerror(const char *);
%}

%token A
%token X

%%
p   : A
    | p X p {printf("Valide\n");}
%%

void yyerror(const char *msg) {
    printf("%s\n", msg);
}

int main() {
        yyparse();
}

