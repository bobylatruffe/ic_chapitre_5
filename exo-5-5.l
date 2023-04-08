/*
Nom : Exercice 5.5 (au choix)
Rôle : Création du lexer qui reconnait seulement le token X
Auteur : Bozlak Fatih 1503001522G
*/

%{
#include "y.tab.h"    
%}

%%
[\t ]+ ; /* On ignore les espaces blancs */
X { return X;}
, {return yytext[0];} 
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