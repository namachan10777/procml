%{
	let exp_dummy = Syntax.EId (("This is dummy", "This is dummy") :: [])
	let pat_dummy = Syntax.PId (("This is dummy", "This is dummy") :: [])
	let type_dummy = Syntax.TId (("This is dummy", "This is dummy") :: [])
	let stmt_dummy = Syntax.SLet (("This is dummy", "This is dummy"), exp_dummy)
%}

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
%type<Syntax.t> program

%%

program:
| EOF
	{ stmt_dummy }
