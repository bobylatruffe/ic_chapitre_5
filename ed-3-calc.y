/* 3-calc.y
 Une calculette elementaire avec Yacc
 Construction explicite de l'arbre syntaxique en memoire
 */
%{
# define YYDEBUG 1		/* Pour avoir du code de mise au point */

typedef struct Noeud Noeud;

Noeud * noeud(int, Noeud *, Noeud *);
Noeud * feuille(int, int);
void print(Noeud *);

int yylex(void);
int yyerror(char *);
%}

%union {
  int i;
  Noeud * n;
};

%token <i> NBRE			/* Les symbole renvoyes par yylex */
%type <n> expr			/* Type de valeur attache au noeuds expr */

%left <i> ADD			/* Precedence et associativite */
%left <i> MUL
%left '^'
%left UMOINS

%start exprs			/* le symbole de depart */

%%
exprs : /* rien */
	{ printf("? "); }
      | exprs expr '\n'
		{ print($2);
		  printf("? "); }
      ;

expr : NBRE
		{ $$ = feuille(NBRE, $1); }
     | expr ADD expr
		{ $$ = noeud($2, $1, $3); }
     | expr '^' expr
		{ $$ = noeud('^', $1, $3); }
     | expr MUL  expr
		{ $$ = noeud($2, $1, $3); }
     | ADD expr        %prec UMOINS
                { if ($1 == '-')
		    $$ = noeud(UMOINS, $2, 0);
                  else if ($1 == '+')
		    $$ = $2;
                  else
		    fprintf(stderr, "Impossible\n"); }
     | '(' expr ')'
		{ $$ = $2; }
     ;
%%
# include <stdio.h>
# include <assert.h>

static int ligne = 1;		/* numero de ligne courante */

int yydebug = 0;		/* different de 0 pour la mise au point */

int
main(){
  yyparse();
  puts("Bye");
  return 0;
}

/* yyerror  --  appeler par yyparse en cas d'erreur */
int
yyerror(char * s){
  fprintf(stderr, "%d: %s\n", ligne, s);
  return 0;
}

/* yylex  --  appele par yyparse, lit un mot, pose sa valeur dans yylval
   et renvoie son type */
int
yylex(){
  int c;
  int r;

 re:
  switch(c = getchar()){
  default:
    fprintf(stderr, "'%c' : caractere pas prevu\n", c);
    goto re;		

  case ' ': case '\t':
    goto re;

  case EOF:
    return 0;
    
  case '0': case '1': case '2': case '3': case '4':
  case '5': case '6': case '7': case '8': case '9':
    ungetc(c, stdin);
    assert(scanf("%d", &r) == 1);
    yylval.i = r;
    return NBRE;
    
  case '\n':
    ligne += 1;
    return c;

  case '+': case '-':
    yylval.i = c;
    return ADD;

  case '*': case '/':
    yylval.i = c;
    return MUL;

  case '(': case ')': case '^':
    return c;
  }
}

/*
 Representation d'un noeud de l'arbre qui represente l'expression
*/
struct Noeud {
  int type;

  int val;			/* valeur pour les feuilles */
  Noeud * gauche, * droit;	/* enfants pour les autres */
};  
  
/* nouvo  --  alloue un nouveau noeud */
static Noeud *
nouvo(void){
  Noeud * n;
  void * malloc();

  n = malloc(sizeof n[0]);
  if (n == 0){
    fprintf(stderr, "Plus de memoire\n");
    exit(1);
  }
  return n;
}
/* feuille  --  fabrique une feuille de l'arbre */
Noeud *
feuille(int t, int v){
  Noeud * n;

  n = nouvo();
  n->type = t;
  n->val = v;
  return n;
}

/* noeud  --  fabrique un noeud interne de l'abre */
Noeud *
noeud(int t, Noeud * g, Noeud * d){
  Noeud * n;

  n = nouvo();
  n->type = t;
  n->gauche = g;
  n->droit = d;
  return n;
}

/* puissance  --  calcule (mal) n a la puissance p */
static int
puissance(int n, int p){
  int r, i;

  r = 1;
  for(i = 0; i < p; i++)
    r *= n;
  return r;
}

/* eval  --  renvoie la valeur attachee a un noeud */
static int
eval(Noeud * n){
  switch(n->type){
  default:
    fprintf(stderr, "eval : noeud de type %d inconnu\n", n->type);
    exit(1);
  case NBRE:
    return n->val;
  case UMOINS:
    return - eval(n->gauche);
  case '+':
    return eval(n->gauche) + eval(n->droit);
  case '-':
    return eval(n->gauche) - eval(n->droit);
  case '*':
    return eval(n->gauche) * eval(n->droit);
  case '/':
    return  eval(n->gauche) / eval(n->droit);
  case '^':
    return puissance(eval(n->gauche), eval(n->droit));
  }
}

/* parenthese  --  ecrit une expression completement parenthesee */
static void
parenthese(Noeud * n){
  switch(n->type){
  default:
    fprintf(stderr, "eval : noeud de type %d inconnu\n", n->type);
    exit(1);

  case NBRE:
    printf("%d", n->val);
    break;

  case UMOINS:
    printf("-(");
    parenthese(n->gauche);
    putchar(')');
    break;

  case '+':  case '-':  case '*':  case '/':  case '^':
    putchar('(');
    parenthese(n->gauche);
    putchar(n->type);
    parenthese(n->droit);
    putchar(')');
  }
}

/* freenoeuds  --  libere la memoire attachee a un noeud et ses enfants */
static void
freenoeuds(Noeud * n){
  switch(n->type){
  default:
    fprintf(stderr, "freenoeuds : noeud de type %d inconnu\n", n->type);
    exit(1);

  case NBRE:
    break;

  case UMOINS:
    freenoeuds(n->gauche);
    break;

  case '+':  case '-':  case '*':  case '/':  case '^':
    freenoeuds(n->gauche);
    freenoeuds(n->droit);
  }
  free(n);
}  

/* print  --  imprime l'expression parenthesee et sa valeur */
void
print(Noeud * n){
  parenthese(n);		/* expression parenthesee */

  printf(" = %d\n", eval(n));	/* valeur */

  freenoeuds(n);
}
