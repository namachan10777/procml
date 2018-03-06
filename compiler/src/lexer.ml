type lexbuf = {
	stream: Sedlexing.lexbuf;
	mutable pos: Lexing.position;
}

let create_lexbuf file stream =
	let pos = {
		Lexing.pos_fname = file;
		pos_lnum = 1;
		pos_bol  = 0;
		pos_cnum = 0;
	} in {pos; stream}

let new_line lexbuf =
	let open Lexing in
	let lcp = lexbuf.pos in
	lexbuf.pos <-
		{
			lcp with
			pos_lnum = lcp.pos_lnum + 1;
			pos_bol  = lcp.pos_cnum;
		}

let update lexbuf =
	let new_pos = Sedlexing.lexeme_end lexbuf.stream in
	let p = lexbuf.pos in
	lexbuf.pos <- {p with Lexing.pos_cnum = new_pos }

let lexeme {stream} = Sedlexing.Utf8.lexeme stream

exception ParseError of (string * int * int * string * string)

let raise_ParseError lexbuf msg =
	let {pos} = lexbuf in
	let line = pos.pos_bol in
	let col = pos.pos_cnum - pos.pos_bol in
	let tok = lexeme lexbuf in
	raise (ParseError (pos.pos_fname, line, col, tok, msg))

let num = [%sedlex.regexp? '0'..'9']
let interger = [%sedlex.regexp? Plus num]
let floating = [%sedlex.regexp? Plus num, '.', Plus num]
let string = [%sedlex.regexp? '"', (Sub (any, '"') | '\\', '"'), '"']
let forbidden = [%sedlex.regexp? '"' | '\'' | '(' | ')' | '[' | ']' | '{' | '}' | '.' | ',' | ';' | ':']
let symbol = [%sedlex.regexp? Sub (any, (num | forbidden))]
let typevar = [%sedlex.regexp? '\'', symbol]

let rec lex lexbuf =
	let buf = lexbuf.stream in
	match%sedlex buf with
	| '\n' ->
		update lexbuf; new_line lexbuf;
		lex lexbuf
	| white_space ->
		update lexbuf;
		lex lexbuf
	| interger ->
		update lexbuf;
		Parser.Interger (lexbuf |> lexeme |> int_of_string)
	| floating ->
		update lexbuf;
		Parser.Floating (lexbuf |> lexeme |> float_of_string)
	| "true" ->
		update lexbuf;
		Parser.Boolean true
	| "false" ->
		update lexbuf;
		Parser.Boolean false
	| string ->
		update lexbuf;
		let value =
			lexbuf
			|> lexeme
			|> fun s -> Core.String.drop_prefix s 1
			|> fun s -> Core.String.drop_suffix s 1
		in Parser.String value
	| symbol ->
		update lexbuf;
		Parser.Symbol (lexbuf |> lexeme)
	| typevar ->
		update lexbuf;
		Parser.Symbol (lexbuf |> lexeme)
	| "let" ->
		update lexbuf;
		Parser.Let
	| "infixr" ->
		update lexbuf;
		Parser.Infixr
	| "infixl" ->
		update lexbuf;
		Parser.Infixl
	| "in" ->
		update lexbuf;
		Parser.In
	| "case" ->
		update lexbuf;
		Parser.Case
	| "of" ->
		update lexbuf;
		Parser.Of
	| "end" ->
		update lexbuf;
		Parser.End
	| "Fn" ->
		update lexbuf;
		Parser.Fn
	| "As" ->
		update lexbuf;
		Parser.As
	| "(" ->
		update lexbuf;
		Parser.LParen
	| ")" ->
		update lexbuf;
		Parser.RParen;
	| "=" ->
		update lexbuf;
		Parser.Eq
	| "->" ->
		update lexbuf;
		Parser.Arrow
	| "*" ->
		update lexbuf;
		Parser.Star
	| "|" ->
		update lexbuf;
		Parser.VBar
	| "." ->
		update lexbuf;
		Parser.Periodo
	| "(*" ->
		update lexbuf;
		comment lexbuf;
		lex lexbuf
	| eof ->
		update lexbuf;
		Parser.EOF
	| _ ->
		update lexbuf;
		raise_ParseError lexbuf "unexpected charcter"
and comment lexbuf =
	let buf = lexbuf.stream in
	match%sedlex buf with
	| "(*" ->
		update lexbuf;
		comment lexbuf;
		comment lexbuf;
	| "*)" ->
		update lexbuf;
		()
	| eof ->
		raise_ParseError lexbuf "unterminated comment"
	| any ->
		update lexbuf;
		comment lexbuf
	| _ ->
		raise_ParseError lexbuf "no way!"
