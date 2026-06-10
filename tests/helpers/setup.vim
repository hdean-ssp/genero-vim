" tests/helpers/setup.vim — common setup/teardown for vader tests

function! TestSetup() abort
  unlet! g:genero_tools_config
  unlet! g:genero_tools_compiler_config
  call genero_tools#config#init()
  call genero_tools#cache#clear()
  silent! %bdelete!
  let $MOCK_FGLCOMP_OUTPUT = ''
  let $MOCK_FGLCOMP_EXIT   = '0'
  let $MOCK_FGLFORM_OUTPUT = ''
  let $MOCK_FGLFORM_EXIT   = '0'
  let $MOCK_SVN_OUTPUT     = ''
  let $MOCK_SVN_EXIT       = '0'
  let $MOCK_QUERY_OUTPUT   = '[]'
  let $MOCK_QUERY_EXIT     = '0'
endfunction

function! TestTeardown() abort
  silent! %bdelete!
  call genero_tools#cache#clear()
  unlet! g:genero_tools_config
  unlet! g:genero_tools_compiler_config
endfunction

function! TestCreateTempFile(content, extension) abort
  let tmpfile = tempname() . '.' . a:extension
  call writefile(split(a:content, "\n"), tmpfile)
  return tmpfile
endfunction

function! TestDeleteTempFile(path) abort
  if filereadable(a:path)
    call delete(a:path)
  endif
endfunction

function! TestOpenSampleFile(relative_path) abort
  execute 'edit ' . a:relative_path
endfunction
