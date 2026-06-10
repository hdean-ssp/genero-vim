" tests/helpers/mock_config.vim — config override helpers for vader tests

function! MockConfigSet(key, value) abort
  if !exists('g:genero_tools_config')
    call genero_tools#config#init()
  endif
  let g:genero_tools_config[a:key] = a:value
endfunction

function! MockConfigReset() abort
  unlet! g:genero_tools_config
  call genero_tools#config#init()
endfunction

function! MockConfigGetAll() abort
  if !exists('g:genero_tools_config')
    call genero_tools#config#init()
  endif
  return copy(g:genero_tools_config)
endfunction
