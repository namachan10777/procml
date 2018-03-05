let () =
	let lexbuf = stdin |> Sedlexing.Utf8.from_channel |> Lexer.create_lexbuf "" in
	let lexer () =
		let ante_position = lexbuf.pos in
		let token = Lexer.lex lexbuf in
		let post_position = lexbuf.pos in
		(token, ante_position, post_position) in
	let result = (MenhirLib.Convert.Simplified.traditional2revised Parser.program) lexer in
	result |> ignore
