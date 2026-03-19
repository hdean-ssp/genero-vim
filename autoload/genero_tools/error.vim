" Genero-Tools Plugin - Error Handling Module
" Provides standardized error message formatting and display
" Error message format: [MODULE] Error description

" Error message format: [MODULE] Error description
function! genero_tools#error#format(module, message) abort
  return '[' . a:module . '] ' . a:message
endfunction

" Echo error message
function! genero_tools#error#echo(module, message) abort
  let l:formatted = genero_tools#error#format(a:module, a:message)
  call genero_tools#display#echo(l:formatted)
endfunction

" Display warning message
function! genero_tools#error#warn(module, message) abort
  let l:formatted = genero_tools#error#format(a:module, a:message)
  echohl WarningMsg
  echo l:formatted
  echohl None
endfunction

" Display error message
function! genero_tools#error#error(module, message) abort
  let l:formatted = genero_tools#error#format(a:module, a:message)
  echohl ErrorMsg
  echo l:formatted
  echohl None
endfunction

" Log debug message (if debug mode enabled)
function! genero_tools#error#debug(module, message) abort
  if genero_tools#config#get('debug_mode')
    let l:formatted = genero_tools#error#format(a:module, a:message)
    call genero_tools#debug#log(l:formatted)
  endif
endfunction

" Create error result dictionary
function! genero_tools#error#result(module, message) abort
  return {
    \ 'success': v:false,
    \ 'data': {},
    \ 'error': genero_tools#error#format(a:module, a:message),
    \ 'timestamp': localtime()
    \ }
endfunction
