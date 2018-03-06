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

exception ParseError of (string * int * int * string)

let raise_ParseError lexbuf =
	let {pos} = lexbuf in
	let line = pos.pos_bol in
	let col = pos.pos_cnum - pos.pos_bol in
	let tok = lexeme lexbuf in
	raise (ParseError (pos.pos_fname, line, col, tok))

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
	| _ ->
		update lexbuf;
		raise_ParseError lexbuf

