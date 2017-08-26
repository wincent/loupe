" Copyright 2015-present Greg Hurrell. All rights reserved.
" Licensed under the terms of the BSD 2-clause license.

" Dynamically returns "/" or "/\v" depending on the location of the just-typed
" "/" within the command-line. Only "/" that looks to be at the start of a
" command gets replaced. The "slash" is itself configurable via the `slash`
" argument, meaning that this function can be used in conjunction with other
" pattern delimiters like "?" and "@" etc (ie. "?" -> "?\v", "@" -> "@\v").
"
" Doesn't handle the full list of possible range types (specified in `:h
" cmdline-ranges`), but catches the most common ones.
function! loupe#private#very_magic_slash(slash) abort
  if getcmdtype() != ':'
    return a:slash
  endif

  " For simplicity, only consider "/" typed at the end of the command-line.
  let l:pos=getcmdpos()
  let l:cmd=getcmdline()
  if len(l:cmd) + 1 != l:pos
    return a:slash
  endif

  " Skip over ranges
  while 1
    let l:stripped=s:strip_ranges(l:cmd)
    if l:stripped ==# l:cmd
      break
    else
      let l:cmd=l:stripped
    endif
  endwhile

  if index(['g', 's', 'v'], l:cmd) != -1
    return loupe#private#prepare_highlight(a:slash . '\v')
  endif

  return a:slash
endfunction

function! s:strip_ranges(cmdline)
  let l:cmdline=a:cmdline

  " All the range tokens may be followed (several times) by '+' or '-' and an
  " optional number.
  let l:modifier='\([+-]\d*\)*'

  " Range tokens as specified in `:h cmdline-ranges`.
  let l:cmdline=substitute(l:cmdline, '^\d\+' . l:modifier, '', '') " line number
  let l:cmdline=substitute(l:cmdline, '^\.' . l:modifier, '', '') " current line
  let l:cmdline=substitute(l:cmdline, '^$' . l:modifier, '', '') " last line in file
  let l:cmdline=substitute(l:cmdline, '^%' . l:modifier, '', '') " entire file
  let l:cmdline=substitute(l:cmdline, "^'[a-z]\\c" . l:modifier, '', '') " mark t (or T)
  let l:cmdline=substitute(l:cmdline, "^'[<>]" . l:modifier, '', '') " visual selection marks
  let l:cmdline=substitute(l:cmdline, '^/[^/]\+/' . l:modifier, '', '') " /{pattern}/
  let l:cmdline=substitute(l:cmdline, '^?[^?]\+?' . l:modifier, '', '') " ?{pattern}?
  let l:cmdline=substitute(l:cmdline, '^\\/' . l:modifier, '', '') " \/ (next match of previous pattern)
  let l:cmdline=substitute(l:cmdline, '^\\?' . l:modifier, '', '') " \? (last match of previous pattern)
  let l:cmdline=substitute(l:cmdline, '^\\&' . l:modifier, '', '') " \& (last match of previous substitution)

  " Separators (see: `:h :,` and `:h :;`).
  let l:cmdline=substitute(l:cmdline, '^,', '', '') " , (separator)
  let l:cmdline=substitute(l:cmdline, '^;', '', '') " ; (separator)

  return l:cmdline
endfunction

" Prepare to highlight the match as soon as the cursor moves to it.
function! loupe#private#prepare_highlight(result) abort
  if has('autocmd')
    augroup LoupeHightlightMatch
      autocmd!
      autocmd CursorMoved * :call loupe#hlmatch() | :call loupe#hlsearch()
    augroup END
  endif
  return a:result
endfunction

" Clear previously applied match highlighting.
function! loupe#private#clear_highlight() abort
  if exists('w:loupe_hlmatch')
    try
      call matchdelete(w:loupe_hlmatch)
    catch /\v<(E802|E803)>/
      " https://github.com/wincent/loupe/issues/1
    finally
      unlet w:loupe_hlmatch
    endtry
  endif
endfunction

" Deactivate hlsearch once the configured timeout has passed since the most
" recent search command.
function! loupe#private#clear_hlsearch(timer) abort
  " only process the most recent timer
  if a:timer == g:hlsearch_timer
    set nohlsearch
  endif
endfunction

" Called from WinEnter autocmd to clean up stray `matchadd()` vestiges.
" If we switch into a window and there is no 'hlsearch' in effect but we do have
" a `w:loupe_hlmatch` variable, it means that `:nohighight` was probably run
" from another window and we should clean up the straggling match and the
" window-local variable.
function! loupe#private#cleanup() abort
  if !exists('v:hlsearch') || !v:hlsearch
    call loupe#private#clear_highlight()
  endif
endfunction
