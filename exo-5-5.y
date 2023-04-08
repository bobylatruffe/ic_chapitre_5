/*
Nom : Exercice 5.5 (au choix)
Rôle : Création de différents grammaire concernant des listes de X
Auteur : Bozlak Fatih 1503001522G
*/

%{
#define YYDEBUG 1
int yydebug = 0;

extern int yylex();
void yyerror(const char *);
%}

%token X

%%
liste   : listeVide {printf("Liste valide\n");}
listeVide    : /* rien */
             | listeNonVide
             ;
listeNonVide : X 
             | listeNonVide ',' X
             ;
%%

void yyerror(const char *msg) {
    printf("%s\n", msg);
}

int main() {
        yyparse();
}