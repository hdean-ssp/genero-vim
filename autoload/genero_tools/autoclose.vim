" Genero-Tools Plugin - Auto-close Blocks
" Automatically inserts END statements when pressing Enter after block openers
" e.g. typing IF ... THEN<Enter> inserts END IF

" Block patterns: regex to match opener → closing text to insert
let s:block_closers = [
  \ ['\c^\s*IF\>.*\<THEN\>\s*$',                'END IF'],
  \ ['\c^\s*FOR\>',                              'END FOR'],
  \ ['\c^\s*WHILE\>',                            'END WHILE'],
  \ ['\c^\s*CASE\>',                             'END CASE'],
  \ ['\c^\s*FUNCTION\>',                         'END FUNCTION'],
  \ ['\c^\s*MAIN\>',                             'END MAIN'],
  \ ['\c^\s*REPORT\>',                           'END REPORT'],
  \ ['\c^\s*MENU\>',                             'END MENU'],
  \ ['\c^\s*INPUT\>.*\<WITHOUT\s\+DEFAULTS\>',   'END INPUT'],
  \ ['\c^\s*DIALOG\>',                           'END DIALOG'],
  \ ['\c^\s*CONSTRUCT\>',                        'END CONSTRUCT'],
  \ ['\c^\s*FOREACH\>',                          'END FOREACH'],
  \ ]

function! genero_tools#autoclose#init() abort
  augroup GeneroAutoClose
    autocmd!
    autocmd FileType 4gl,fgl call genero_tools#autoclose#setup_buffer()
    autocmd BufEnter *.4gl,*.m3,*.m4,*.per call genero_tools#autoclose#setup_buffer()
  augroup END
endfunction

" Set up the Enter key mapping for the current buffer
function! genero_tools#autoclose#setup_buffer() abort
  if !genero_tools#config#get('autoclose_blocks')
    return
  endif

  " Use a different approach for Neovim to avoid noice popup
  if has('nvim')
    " Use Lua callback to avoid expression register display
    inoremap <buffer> <silent> <CR> <Cmd>call genero_tools#autoclose#on_enter_nvim()<CR>
  else
    " Vim uses expression register (no noice to interfere)
    inoremap <buffer> <silent> <CR> <C-R>=genero_tools#autoclose#on_enter()<CR>
  endif
endfunction

" Neovim version: directly inserts text instead of returning it
function! genero_tools#autoclose#on_enter_nvim() abort
  let line = getline('.')
  let matched = 0

  for [pattern, closer] in s:block_closers
    if line =~# pattern
      " Get the indentation of the current line
      let indent = matchstr(line, '^\s*')
      let inner_indent = indent . "\t"

      " Check if the closer already exists nearby (don't double-close)
      if s:closer_exists_below(closer)
        " Just insert a normal newline
        call feedkeys("\<CR>", 'n')
        return
      endif

      " Insert: newline, indented cursor line, newline, closer at same indent
      let current_line = line('.')
      let current_col = col('.')
      
      " Insert newline and the closer block
      call append(current_line, [inner_indent, indent . closer])
      
      " Move cursor to the indented line
      call cursor(current_line + 1, len(inner_indent) + 1)
      
      let matched = 1
      break
    endif
  endfor

  if !matched
    " No match — just a normal Enter
    call feedkeys("\<CR>", 'n')
  endif
endfunction

" Called when Enter is pressed in insert mode
" Returns the text to insert (via <C-R>=)
function! genero_tools#autoclose#on_enter() abort
  let line = getline('.')

  for [pattern, closer] in s:block_closers
    if line =~# pattern
      " Get the indentation of the current line
      let indent = matchstr(line, '^\s*')
      let inner_indent = indent . "\t"

      " Check if the closer already exists nearby (don't double-close)
      if s:closer_exists_below(closer)
        return "\<CR>"
      endif

      " Insert: newline, indented cursor line, newline, closer at same indent
      return "\<CR>" . inner_indent . "\<CR>" . indent . closer . "\<Up>\<End>"
    endif
  endfor

  " No match — just a normal Enter
  return "\<CR>"
endfunction

" Check if a closer already exists within the next few lines
function! s:closer_exists_below(closer) abort
  let current = line('.')
  let check_end = min([current + 5, line('$')])
  let pattern = '\c^\s*' . escape(a:closer, '\') . '\s*$'

  let i = current + 1
  while i <= check_end
    if getline(i) =~# pattern
      return 1
    endif
    let i += 1
  endwhile

  return 0
endfunction
