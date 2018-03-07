%token<int> Interger
%token<float> Floating
%token<bool> Boolean
%token<string> String
%token<string> Symbol
%token<string> TypeVar
%token Let Infixr Infixl In
%token Case Of End
%token Fn
%token As
%token LParen RParen
%token Eq Arrow Star VBar Periodo Comma
%token EOF

%start program
%type<'a list> program

%%

program:
| EOF
	{ [] }
