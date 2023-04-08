/*
Nom : Exercice 5.3 (à rendre)
Rôle : Créer un analyseur lexical qui reconnait seulement A et X
Auteur : Bozlak Fatih 1503001522G
Compilation : lex exo-5-3.l
*/

%{
#include "y.tab.h" /* Conteint les code des tokens A et X */
%}

%%
[\t ]+ ; /* On ignore les espaces blancs */
A { return A;}
X { return X;}
\n {return 0;} /* Fin de l'entrée */
. ; /* On ignore tous les autres caractères */
%%

/* Cette fonction est utilisé par yylex afin de savoir si nous avons atteint la fin du fichier d'entré.
Si 0 = non atteint 
sinon = oui atteint
*/
int yywrap(void) {
    return 1;
}

#ifdef TEST
int main() {
    while(!feof(stdin))
        yylex();
}
#endif