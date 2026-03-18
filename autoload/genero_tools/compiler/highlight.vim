" Genero-Tools Plugin - Compiler Syntax Highlighting

" Highlight groups for errors and warnings
let s:error_group = 'GeneroError'
let s:warning_group = 'GeneroWarning'
let s:info_group = 'GeneroInfo'
let s:unused_var_group = 'GeneroUnusedVariable'

" Namespace for tracking highlights (Neovim)
let s:highlight_namespace = -1

" Initialize highlighting groups
function! genero_tools#compiler#highlight#init() abort
  " Define error highlight group - red background for full line
  execute 'highlight ' . s:error_group . ' ctermbg=52 ctermfg=NONE guibg=#5f0000 guifg=NONE'
  
  " Define warning highlight group - yellow background for text range
  execute 'highlight ' . s:warning_group . ' ctermbg=58 ctermfg=NONE guibg=#5f5f00 guifg=NONE'
  
  " Define info highlight group - blue background for text range
  execute 'highlight ' . s:info_group . ' ctermbg=17 ctermfg=NONE guibg=#00005f guifg=NONE'
  
  " Define unused variable highlight group - orange background
  execute 'highlight ' . s:unused_var_group . ' ctermbg=94 ctermfg=NONE guibg=#5f5f00 guifg=NONE'
  
  " Initialize Neovim namespace if needed
  if has('nvim') && s:highlight_namespace == -1
    let s:highlight_namespace = nvim_create_namespace('genero_compiler_highlights')
  endif
endfunction

" Apply line and text highlighting for errors and warnings
function! genero_tools#compiler#highlight#apply(errors, warnings) abort
  call genero_tools#compiler#highlight#init()
  
  " Clear previous highlights
  call genero_tools#compiler#highlight#clear()
  
  " Get current buffer number
  let bufnr = bufnr('%')
  
  " Highlight errors - entire line to draw attention
  for error in a:errors
    if has_key(error, 'line')
      try
        if has('nvim')
          " Neovim: highlight entire line (0-indexed)
          call nvim_buf_add_highlight(bufnr, s:highlight_namespace, s:error_group, error.line - 1, 0, -1)
        else
          " Vim: use matchaddpos for full-line highlighting
          " matchaddpos takes [line, col, length] where length=0 means to end of line
          call matchaddpos(s:error_group, [[error.line, 1, 0]], 20)
        endif
      catch
        " Silently ignore if highlight fails
      endtry
    endif
  endfor
  
  " Highlight warnings - text range highlighting
  for warning in a:warnings
    if has_key(warning, 'line')
      try
        if has('nvim')
          " Neovim: highlight text range (0-indexed)
          let col_start = get(warning, 'col', 1) - 1
          let col_end = get(warning, 'end_col', col_start + 1)
          if col_end <= col_start
            let col_end = -1  " Highlight to end of line
          endif
          call nvim_buf_add_highlight(bufnr, s:highlight_namespace, s:warning_group, warning.line - 1, col_start, col_end)
        else
          " Vim: use matchaddpos for column range highlighting
          let col_start = get(warning, 'col', 1)
          let col_end = get(warning, 'end_col', col_start + 1)
          let col_count = col_end - col_start
          if col_count > 0
            call matchaddpos(s:warning_group, [[warning.line, col_start, col_count]], 15)
          else
            " If no column range, highlight from col to end of line
            call matchaddpos(s:warning_group, [[warning.line, col_start, 0]], 15)
          endif
        endif
      catch
        " Silently ignore if highlight fails
      endtry
    endif
  endfor
  
  return {
    \ 'success': 1,
    \ 'error': ''
    \ }
endfunction

" Highlight unused variables from warnings
function! genero_tools#compiler#highlight#unused_vars(warnings) abort
  call genero_tools#compiler#highlight#init()
  
  " Filter warnings for unused variable messages (code -6615)
  let unused_warnings = filter(copy(a:warnings), 
    \ "v:val.message =~? 'unused' && v:val.code == '(-6615)'")
  
  " Get current buffer number
  let bufnr = bufnr('%')
  
  " Highlight unused variables at their specific locations only
  for warning in unused_warnings
    if has_key(warning, 'line')
      try
        if has('nvim')
          " Neovim: highlight text range (0-indexed)
          let col_start = get(warning, 'col', 1) - 1
          let col_end = get(warning, 'end_col', col_start + 1)
          if col_end <= col_start
            let col_end = -1  " Highlight to end of line
          endif
          call nvim_buf_add_highlight(bufnr, s:highlight_namespace, s:unused_var_group, warning.line - 1, col_start, col_end)
        else
          " Vim: use matchaddpos for column range highlighting
          let col_start = get(warning, 'col', 1)
          let col_end = get(warning, 'end_col', col_start + 1)
          let col_count = col_end - col_start
          if col_count > 0
            call matchaddpos(s:unused_var_group, [[warning.line, col_start, col_count]], 11)
          else
            " If no column range, highlight from col to end of line
            call matchaddpos(s:unused_var_group, [[warning.line, col_start, 0]], 11)
          endif
        endif
      catch
        " Silently ignore if highlight fails
      endtry
    endif
  endfor
  
  return {
    \ 'success': 1,
    \ 'error': ''
    \ }
endfunction

" Clear all compiler highlighting
function! genero_tools#compiler#highlight#clear() abort
  try
    if has('nvim')
      " Neovim: clear namespace highlights
      if s:highlight_namespace != -1
        call nvim_buf_clear_namespace(bufnr('%'), s:highlight_namespace, 0, -1)
      endif
    else
      " Vim: clear all matches
      let match_list = getmatches()
      for match in match_list
        if match.group == s:error_group || match.group == s:warning_group || 
           \ match.group == s:info_group || match.group == s:unused_var_group
          call matchdelete(match.id)
        endif
      endfor
    endif
    return {
      \ 'success': 1,
      \ 'error': ''
      \ }
  catch
    return {
      \ 'success': 0,
      \ 'error': 'Failed to clear highlights: ' . v:exception
      \ }
  endtry
endfunction
