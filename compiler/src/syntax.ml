type var_t = Id.t list

type t =
	| SLet of Id.t * exp_t
	| SType of Id.t * Id.t option * type_t
and exp_t =
	| EVal of Lit.t
	| EId of var_t
	| EPro of exp_t list
	| ELine of exp_t list
	| EFun of Id.t list * exp_t
	| ELet of Id.t * exp_t * exp_t
	| EInfixr of int * Id.t * exp_t * exp_t
	| EInfixl of int * Id.t * exp_t * exp_t
	| ECase of exp_t * (pattern_t * exp_t) * (pattern_t * exp_t) list
and type_t =
	| TId of var_t
	| TPro of type_t list
	| TSum of (Id.t * type_t) list
	| TFun of type_t * type_t
	| TApp of type_t * type_t
and pattern_t =
	| PId of var_t
	| PAs
	| PLine of pattern_t list
