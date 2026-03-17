" Comprehensive workflow test for sign column stability

set runtimepath+=.

" Test: Complete workflow from initialization to compilation
function! Test_complete_workflow() abort
  let g:genero_tools_config = {}
  let g:genero_tools_config.compiler_enabled = v:true
  let g:genero_tools_config.compiler_sign_column = v:true
  let g:genero_tools_config.compiler_sign_column_always_visible = v:true
  let g:genero_tools_config.compiler_autocompile = v:true
  
  enew
  
  " Step 1: Initialize signs
  call genero_tools#compiler#signs#init()
  let step1 = &signcolumn
  
  " Step 2: Simulate buffer enter
  call genero_tools#compiler#signs#set_persistent_column()
  let step2 = &signcolumn
  
  " Step 3: Place errors
  let errors = [{'file': expand('%'), 'line': 1, 'message': 'Error'}]
  call genero_tools#compiler#signs#place(errors, [], [])
  let step3 = &signcolumn
  
  " Step 4: Clear errors
  call genero_tools#compiler#signs#clear()
  let step4 = &signcolumn
  
  " Step 5: Place warnings
  let warnings = [{'file': expand('%'), 'line': 2, 'message': 'Warning'}]
  call genero_tools#compiler#signs#place([], warnings, [])
  let step5 = &signcolumn
  
  bdelete!
  
  " All steps should have signcolumn = 'yes'
  if step1 == 'yes' && step2 == 'yes' && step3 == 'yes' && step4 == 'yes' && step5 == 'yes'
    return 'PASS'
  else
    return 'FAIL: Workflow steps: ' . step1 . ', ' . step2 . ', ' . step3 . ', ' . step4 . ', ' . step5
  endif
endfunction

" Test: Configuration persistence across operations
function! Test_config_persistence() abort
  call genero_tools#config#init()
  
  let config1 = genero_tools#config#get('compiler_sign_column_always_visible')
  
  " Modify config
  let g:genero_tools_config.compiler_sign_column_always_visible = v:false
  let config2 = genero_tools#config#get('compiler_sign_column_always_visible')
  
  " Restore config
  let g:genero_tools_config.compiler_sign_column_always_visible = v:true
  let config3 = genero_tools#config#get('compiler_sign_column_always_visible')
  
  if config1 == v:true && config2 == v:false && config3 == v:true
    return 'PASS'
  else
    return 'FAIL: Config values: ' . config1 . ', ' . config2 . ', ' . config3
  endif
endfunction

" Test: Multiple buffers maintain independent sign columns
function! Test_multiple_buffers() abort
  let g:genero_tools_config = {}
  let g:genero_tools_config.compiler_sign_column_always_visible = v:true
  
  " Create first buffer
  enew
  call genero_tools#compiler#signs#init()
  let buf1_col = &signcolumn
  
  " Create second buffer
  enew
  call genero_tools#compiler#signs#set_persistent_column()
  let buf2_col = &signcolumn
  
  " Create third buffer
  enew
  call genero_tools#compiler#signs#set_persistent_column()
  let buf3_col = &signcolumn
  
  " Clean up
  bdelete!
  bdelete!
  bdelete!
  
  if buf1_col == 'yes' && buf2_col == 'yes' && buf3_col == 'yes'
    return 'PASS'
  else
    return 'FAIL: Buffer columns: ' . buf1_col . ', ' . buf2_col . ', ' . buf3_col
  endif
endfunction

" Test: Rapid error/clear cycles
function! Test_rapid_cycles() abort
  let g:genero_tools_config = {}
  let g:genero_tools_config.compiler_sign_column_always_visible = v:true
  
  enew
  
  call genero_tools#compiler#signs#init()
  
  let errors = [{'file': expand('%'), 'line': 1, 'message': 'Error'}]
  
  " Perform 10 rapid cycles
  for i in range(10)
    call genero_tools#compiler#signs#place(errors, [], [])
    if &signcolumn != 'yes'
      bdelete!
      return 'FAIL: Lost signcolumn at cycle ' . i
    endif
    
    call genero_tools#compiler#signs#clear()
    if &signcolumn != 'yes'
      bdelete!
      return 'FAIL: Lost signcolumn after clear at cycle ' . i
    endif
  endfor
  
  bdelete!
  return 'PASS'
endfunction

" Run tests
let output = []
call add(output, 'Sign Column Workflow Tests')
call add(output, '==========================')
call add(output, '')
call add(output, 'Test 1: Complete workflow - ' . Test_complete_workflow())
call add(output, 'Test 2: Configuration persistence - ' . Test_config_persistence())
call add(output, 'Test 3: Multiple buffers - ' . Test_multiple_buffers())
call add(output, 'Test 4: Rapid error/clear cycles - ' . Test_rapid_cycles())
call add(output, '')

call writefile(output, 'test/test_sign_column_workflow_results.txt')
quit
