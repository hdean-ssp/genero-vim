" Simple test for sign column stability

set runtimepath+=.

" Test 1: Config option exists and is true by default
function! Test_config_exists() abort
  call genero_tools#config#init()
  let value = genero_tools#config#get('compiler_sign_column_always_visible')
  return value == v:true ? 'PASS' : 'FAIL: ' . string(value)
endfunction

" Test 2: Init function sets signcolumn
function! Test_init_sets_signcolumn() abort
  let g:genero_tools_config = {}
  let g:genero_tools_config.compiler_sign_column_always_visible = v:true
  
  " Create a new buffer
  enew
  
  " Call init
  call genero_tools#compiler#signs#init()
  
  " Check signcolumn
  let result = &signcolumn == 'yes' ? 'PASS' : 'FAIL: ' . &signcolumn
  
  " Clean up
  bdelete!
  
  return result
endfunction

" Test 3: Persistent column function works
function! Test_persistent_column() abort
  let g:genero_tools_config = {}
  let g:genero_tools_config.compiler_sign_column_always_visible = v:true
  
  enew
  
  call genero_tools#compiler#signs#set_persistent_column()
  
  let result = &signcolumn == 'yes' ? 'PASS' : 'FAIL: ' . &signcolumn
  
  bdelete!
  
  return result
endfunction

" Test 4: Disabled config doesn't set signcolumn
function! Test_disabled_config() abort
  let g:genero_tools_config = {}
  let g:genero_tools_config.compiler_sign_column_always_visible = v:false
  
  enew
  
  " Reset signcolumn first
  setlocal signcolumn=auto
  
  call genero_tools#compiler#signs#set_persistent_column()
  
  " When disabled, signcolumn should remain as it was (auto)
  let result = &signcolumn == 'auto' ? 'PASS' : 'FAIL: ' . &signcolumn
  
  bdelete!
  
  return result
endfunction

" Run tests
let output = []
call add(output, 'Sign Column Simple Tests')
call add(output, '========================')
call add(output, '')
call add(output, 'Test 1: Config option exists - ' . Test_config_exists())
call add(output, 'Test 2: Init sets signcolumn - ' . Test_init_sets_signcolumn())
call add(output, 'Test 3: Persistent column function - ' . Test_persistent_column())
call add(output, 'Test 4: Disabled config - ' . Test_disabled_config())
call add(output, '')

call writefile(output, 'test/test_sign_column_simple_results.txt')
quit
