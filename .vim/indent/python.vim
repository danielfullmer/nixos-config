" Vim indent file
" Language:             Python
" Maintainer:           David Moore <david@linuxsoftware.co.nz>
" Original Author:      David Bustos <bustos@caltech.edu>
" Last Change:          2010 Mar 3

" Only load this indent file when no other was loaded.
if exists("b:did_indent")
  finish
endif
let b:did_indent = 1

" Some preliminary settings
setlocal nolisp         " Make sure lisp indenting doesn't supersede us
setlocal autoindent     " indentexpr isn't much help otherwise

setlocal indentexpr=GetPythonIndent(v:lnum)
setlocal indentkeys=!^F,o,O,<:>,0),0],0},=elif,=except

" Only define the function once.
if exists("*GetPythonIndent")
  finish
endif

" Come here when loading the script the first time.

let s:maxoff = 50       " maximum number of lines to look backwards for ()

function! s:StatementStart(lnum)
  let lnum = a:lnum
  while lnum > 0
    if getline(lnum - 1) =~ '\\$'
      let lnum = lnum - 1
    else
      call cursor(lnum, 1)
      let maybe_lnum = searchpair('(\|{\|\[', '', ')\|}\|\]', 'bW',
	                   \ "line('.') < " . (lnum - s:maxoff) . " ? dummy :"
                 	  \ . " synIDattr(synID(line('.'), col('.'), 1), 'name')"
                 	  \ . " =~ '\\(Comment\\|String\\)$'")
      if maybe_lnum < 1
        if lnum == a:lnum
          return -1
        else
          return lnum
        endif
      else
        let lnum = maybe_lnum
      endif
    endif
  endwhile
endfunction

function! GetPythonIndent(lnum)
  " Search backwards for the previous non-empty line.
  let plnum = prevnonblank(a:lnum - 1)

  if plnum == 0
    " This is the first non-empty line, use zero indent.
    return 0
  endif

  " If this line is explicitly joined: If the previous line was also joined,
  " line it up with that one, otherwise try to find an indentation that looks
  " good. 
  if getline(a:lnum - 1) =~ '\\$'
    if a:lnum > 1 && getline(a:lnum - 2) =~ '\\$'
      return indent(a:lnum - 1)
    endif
    let compound_statement = '^\s*\(if\|while\|for\s.*\sin\|except\)\s*'
    let maybe_indent = matchend(getline(a:lnum - 1), compound_statement)
    if maybe_indent != -1
      return maybe_indent
    else
      return indent(a:lnum - 1) + (exists("g:pyindent_continue") ? eval(g:pyindent_continue) : (&sw * 2))
    endif
  endif

  " If the start of the line is in a string don't change the indent.
  if has('syntax_items')
        \ && synIDattr(synID(a:lnum, 1, 1), "name") =~ "String$"
    return -1
  endif

  " When inside parenthesis: line up with the opening parenthesis
  call cursor(a:lnum, 1)
  let p = searchpair('(\|{\|\[', '', ')\|}\|\]', 'bW',
	  \ "line('.') < " . (a:lnum - s:maxoff) . " ? dummy :"
	  \ . " synIDattr(synID(line('.'), col('.'), 1), 'name')"
	  \ . " =~ '\\(Comment\\|String\\)$'")
  if p > 0
    let parcol = col('.')
    if match(getline(a:lnum), '^\s*[])}]') != -1
      return parcol - 1
    else
      return parcol
    endif
  endif

  " If the previous line is inside parenthesis, use the indent of the starting
  " line.
  " Trick: use the non-existing "dummy" variable to break out of the loop when
  " going too far back.
  let parlnum = s:StatementStart(plnum)
  if parlnum > 0
    let plindent = indent(parlnum)
    let plnumstart = parlnum
  else
    let plindent = indent(plnum)
    let plnumstart = plnum
  endif

  " Get the line and remove a trailing comment.
  " Use syntax highlighting attributes when possible.
  let pline = getline(plnum)
  let pline_len = strlen(pline)
  if has('syntax_items')
    " If the last character in the line is a comment, do a binary search for
    " the start of the comment.  synID() is slow, a linear search would take
    " too long on a long line.
    if synIDattr(synID(plnum, pline_len, 1), "name") =~ "Comment$"
      let min = 1
      let max = pline_len
      while min < max
        let col = (min + max) / 2
        if synIDattr(synID(plnum, col, 1), "name") =~ "Comment$"
          let max = col
        else
          let min = col + 1
        endif
      endwhile
      let pline = strpart(pline, 0, min - 1)
    endif
  else
    let col = 0
    while col < pline_len
      if pline[col] == '#'
        let pline = strpart(pline, 0, col)
        break
      endif
      let col = col + 1
    endwhile
  endif

  " If the previous line ended with a colon, indent this line
  if pline =~ ':\s*$'
    return plindent + &sw
  endif

  " If the previous line was a stop-execution statement...
  if getline(plnum) =~ '^\s*\(break\|continue\|raise\|return\|pass\)\>'
    " See if the user has already dedented
    if indent(a:lnum) > indent(plnum) - &sw
      " If not, recommend one dedent
      return indent(plnum) - &sw
    endif
    " Otherwise, trust the user
    return -1
  endif

  " If the current line begins with a keyword that lines up with "try"
  if getline(a:lnum) =~ '^\s*\(except\|finally\)\>'
    let lnum = a:lnum - 1
    while lnum >= 1
      if getline(lnum) =~ '^\s*\(try\|except\)\>'
        let ind = indent(lnum)
        if ind >= indent(a:lnum)
          return -1     " indent is already less than this
        endif
        return ind      " line up with previous try or except
      endif
      let lnum = lnum - 1
    endwhile
    return -1           " no matching "try"!
  endif

  " If the current line begins with a header keyword, dedent
  if getline(a:lnum) =~ '^\s*\(elif\|else\)\>'

    " Unless the previous line was a one-liner
    if getline(plnumstart) =~ '^\s*\(for\|if\|try\)\>'
      return plindent
    endif

    " Or the user has already dedented
    if indent(a:lnum) <= plindent - &sw
      return -1
    endif

    return plindent - &sw
  endif

  " If the current line starts a new function or class
  if getline(a:lnum) =~ '^\s*\(def\|class\)\>'
    return -1           " have to trust the user
  endif

  " When after a () construct we probably want to go back to the start line.
  " a = (b
  "       + c)
  " here
  if parlnum > 0
    return plindent
  endif

  return -1

endfunction

" Indent Python in the Google way.

setlocal indentexpr=GetGooglePythonIndent(v:lnum)

let s:maxoff = 50 " maximum number of lines to look backwards.

function GetGooglePythonIndent(lnum)
  " Indent inside parens.
  " Align with the open paren unless it is at the end of the line.
  " E.g.
  "   open_paren_not_at_EOL(100,
  "                         (200,
  "                          300),
  "                         400)
  "   open_paren_at_EOL(
  "       100, 200, 300, 400)
  call cursor(a:lnum, 1)
  let [par_line, par_col] = searchpairpos('(\|{\|\[', '', ')\|}\|\]', 'bW',
        \ "line('.') < " . (a:lnum - s:maxoff) . " ? dummy :"
        \ . " synIDattr(synID(line('.'), col('.'), 1), 'name')"
        \ . " =~ '\\(Comment\\|String\\)$'")
  echo par_line par_col
  if par_line > 0
    call cursor(par_line, 1)
    if par_col != col("$") - 1
      return par_col
    else
      return indent(par_line) + &sw " FIXED HERE. FIXED BY ADDING THIS LINE
    endif
  endif

  " Delegate the rest to the original function.
  return GetPythonIndent(a:lnum)
endfunction

let pyindent_nested_paren="&sw*2"
let pyindent_open_paren="&sw*2"

" vim:sw=2
