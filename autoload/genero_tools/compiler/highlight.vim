" Genero-Tools Plugin - Compiler Syntax Highlighting

" Highlight groups for errors and warnings
let s:error_group = 'GeneroCompilerError'
let s:warning_group = 'GeneroCompilerWarning'
let s:unused_var_group = 'GeneroUnusedVariable'

" Initialize highlighting
function! genero_tools#compiler#highlight#init() abort
  " Define error highlight group - subtle red background, full line
  execute 'highlight ' . s:error_group . ' ctermbg=52 ctermfg=NONE guibg=#5f0000 guifg=NONE'
  
  " Define warning highlight group - subtle yellow background, column range only
  execute 'highlight ' . s:warning_group . ' ctermbg=58 ctermfg=NONE guibg=#5f5f00 guifg=NONE'
  
  " Define unused variable highlight group - subtle orange background
  execute 'highlight ' . s:unused_var_group . ' ctermbg=94 ctermfg=NONE guibg=#5f5f00 guifg=NONE'
endfunction

" Apply syntax error highlighting
function! genero_tools#compiler#highlight#apply(errors, warnings) abort
  call genero_tools#compiler#highlight#init()
  
  " Clear previous highlights
  call genero_tools#compiler#highlight#clear()
  
  " Debug: log if we have errors to highlight
  if len(a:errors) > 0
    echom 'Highlighting ' . len(a:errors) . ' errors'
  endif
  
  " Highlight errors - entire line to draw attention
  for error in a:errors
    if has_key(error, 'file') && has_key(error, 'line')
      try
        " Use matchaddpos for full-line highlighting
        " matchaddpos takes [line, col, length] where length=0 means to end of line
        " Use a very large length to ensure full line coverage
        call matchaddpos(s:error_group, [[error.line, 1, 9999]], 20)
      catch
        " Log error for debugging
        echom 'Error highlighting failed: ' . v:exception
      endtry
    endif
  endfor
  
  " Highlight warnings - only the column range
  for warning in a:warnings
    if has_key(warning, 'file') && has_key(warning, 'line') && has_key(warning, 'col') && has_key(warning, 'end_col')
      try
        " Use matchaddpos for column range highlighting
        let col_count = warning.end_col - warning.col
        if col_count > 0
          call matchaddpos(s:warning_group, [[warning.line, warning.col, col_count]], 15)
        else
          " If no column range, highlight from col to end of line
          call matchaddpos(s:warning_group, [[warning.line, warning.col, 0]], 15)
        endif
      catch
        " Silently ignore if match fails
      endtry
    endif
  endfor
  
  return {
    \ 'success': v:true,
    \ 'error': ''
    \ }
endfunction

" Highlight unused variables from warnings
function! genero_tools#compiler#highlight#unused_vars(warnings) abort
  call genero_tools#compiler#highlight#init()
  
  " Filter warnings for unused variable messages (code -6615)
  let unused_warnings = filter(copy(a:warnings), 
    \ "v:val.message =~? 'unused' && v:val.code == '(-6615)'")
  
  " Extract variable names and highlight them
  for warning in unused_warnings
    if has_key(warning, 'message')
      " Extract variable name from message: "The symbol 'l_description' is unused."
      let var_match = matchstr(warning.message, "symbol '\\zs[^']*\\ze'")
      
      if !empty(var_match)
        try
          " Highlight all occurrences of this variable in the current buffer
          let pattern = '\<' . var_match . '\>'
          call matchadd(s:unused_var_group, pattern, 11)
        catch
          " Silently ignore if match fails
        endtry
      endif
    endif
  endfor
  
  return {
    \ 'success': v:true,
    \ 'error': ''
    \ }
endfunction

" Clear all compiler highlighting
function! genero_tools#compiler#highlight#clear() abort
  try
    " Clear all matches in the current window
    " Use a more robust approach that works in timer callbacks
    let match_list = getmatches()
    for match in match_list
      if match.group == s:error_group || match.group == s:warning_group || match.group == s:unused_var_group
        call matchdelete(match.id)
      endif
    endfor
    return {
      \ 'success': v:true,
      \ 'error': ''
      \ }
  catch
    return {
      \ 'success': v:false,
      \ 'error': 'Failed to clear highlights: ' . v:exception
      \ }
  endtry
endfunction
