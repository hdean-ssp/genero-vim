" Genero-Tools Plugin - Format Flag Integration
" Handles adding format flags to queries for optimized output

" Add format flag to query arguments
" Returns modified arguments array with format flag appended
function! genero_tools#format#add_flag(args, format) abort
  if empty(a:format)
    return a:args
  endif
  
  let args = copy(a:args)
  call add(args, '--format=' . a:format)
  return args
endfunction

" Execute query with format flag
" Wrapper around execute_shell that adds format flag
function! genero_tools#format#execute_with_format(command, args, format) abort
  let args_with_format = genero_tools#format#add_flag(a:args, a:format)
  return genero_tools#command#execute_shell(a:command, args_with_format)
endfunction

" Get format for hover display
function! genero_tools#format#get_hover_format() abort
  return 'vim-hover'
endfunction

" Get format for autocomplete
function! genero_tools#format#get_completion_format() abort
  return 'vim-completion'
endfunction

" Get format for concise display (hints, status bar)
function! genero_tools#format#get_concise_format() abort
  return 'vim'
endfunction

