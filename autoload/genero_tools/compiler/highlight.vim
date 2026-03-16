" Genero-Tools Plugin - Compiler Syntax Highlighting

" Highlight group for unused variables
let s:unused_var_group = 'GeneroUnusedVariable'

" Initialize highlighting
function! genero_tools#compiler#highlight#init() abort
  if !hlexists(s:unused_var_group)
    " Define highlight group for unused variables (yellow/orange background)
    execute 'highlight ' . s:unused_var_group . ' ctermbg=226 ctermfg=0 guibg=#ffff00 guifg=#000000'
  endif
endfunction

" Apply syntax error highlighting
function! genero_tools#compiler#highlight#apply(errors, warnings) abort
  call genero_tools#compiler#highlight#init()
  
  " Clear previous highlights
  call genero_tools#compiler#highlight#clear()
  
  " Highlight errors and warnings
  for item in a:errors + a:warnings
    if has_key(item, 'file') && has_key(item, 'line') && has_key(item, 'col')
      try
        " Create match for the error/warning location
        let pattern = '\%' . item.line . 'l\%' . item.col . 'c'
        call matchadd('ErrorMsg', pattern, 10)
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
    call clearmatches()
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
