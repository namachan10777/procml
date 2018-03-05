# EBNF syntax definition
## Word definitin
```
      num ::= '0'|'1'|'2'|'3'|'4'|'5'|'6'|'7'|'8'|'9'
 interger ::= num+
 floating ::= num+, '.', num+
  boolean ::= 'true' | 'false'
   string ::= '"', ({ all charcters - '"' } | '\"')*, '"'

forbidden ::= '"' | ''' | '(' | ')' | '[' | ']' | '{' | '}' | '.' | ',' | ';' | ':'
   symbol ::= {all charcters - (num | forbidden}, {all charcters - forbidden}*

  typevar ::= ''', symbol
```
White space cannot get between element and element.

## Syntax definition
```
       variable ::= symbol ('.' symbol)*
          tuple ::= '(', exp, (',', exp)+, ')'
         binapp ::= exp, variable, exp
           term ::= variable | '(', exp, ')' | tuple
         funapp ::= exp, term 
        let_exp ::= let', symbol, '=', exp, 'in', exp
	              | ('infixr' | 'infixl'), num, symbol, '=', exp, 'in', exp
             fn ::= 'fn', symbol+, '->', exp
     match_pair ::= pattern, '->', exp
           case ::= 'case', exp, 'of', match_pair, ('|', match_pair)+, 'end'
            exp ::= variable | tuple | binapp | funapp | let_exp | fn | case | '(, exp, ')'

     as_pattern ::= variable, 'as', variable
  tuple_pattern ::= '(', pattern, (',', pattern)+, ')'
variant_pattern ::= variable, pattern
        pattern ::= variable | as_pattern | tuple_pattern | variant_pattern  | '(', pattern, ')'

       let_stmt ::= 'let', symbol, '=', exp, '.'
	              | ('infixr' | 'infixl'), num, symbol, '=', exp, '.'
      type_stmt ::= 'type', symbol, typevar?, '=', type, '.'

    tuple_type ::= type, ('*', type)+
  variant_pair ::= symbol, 'of', type
  variant_type ::= variant_pair, ('|', variant_pair)*
       funtype ::= type, '->', type
          type ::= variable | tuple_type | variant_type | funtype | '(', type, ')'

       program ::= (let_stmt | type_stmt)*
```
