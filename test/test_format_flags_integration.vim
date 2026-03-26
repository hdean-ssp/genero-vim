" Test Format Flags Integration
" Verifies that format flags are used correctly for each feature

" Test 1: Verify hover format flag is used
function! Test_hover_format_flag() abort
  " Mock the command execution to capture the arguments
  let g:test_command_args = []
  
  " Override execute_shell to capture arguments
  function! genero_tools#command#execute_shell(command, args) abort
    let g:test_command_args = a:args
    return {'success': 1, 'data': 'test_function(param: INTEGER) -> DECIMAL\nFile: test.4gl:42\nComplexity: 5, LOC: 23'}
  endfunction
  
  " Call hover function
  call genero_tools#get_function_hover('test_function')
  
  " Verify format flag is in arguments
  call assert_true(index(g:test_command_args, '--format=vim-hover') >= 0, 'Hover format flag not found')
  
  " Restore original function
  delfunction genero_tools#command#execute_shell
endfunction

" Test 2: Verify concise format flag is used
function! Test_concise_format_flag() abort
  " Mock the command execution to capture the arguments
  let g:test_command_args = []
  
  " Override execute_shell to capture arguments
  function! genero_tools#command#execute_shell(command, args) abort
    let g:test_command_args = a:args
    return {'success': 1, 'data': 'test_function(param: INTEGER) -> DECIMAL'}
  endfunction
  
  " Call concise function
  call genero_tools#get_function_concise('test_function')
  
  " Verify format flag is in arguments
  call assert_true(index(g:test_command_args, '--format=vim') >= 0, 'Concise format flag not found')
  
  " Restore original function
  delfunction genero_tools#command#execute_shell
endfunction

" Test 3: Verify completion format flag is used
function! Test_completion_format_flag() abort
  " Mock the command execution to capture the arguments
  let g:test_command_args = []
  
  " Override execute_shell to capture arguments
  function! genero_tools#command#execute_shell(command, args) abort
    let g:test_command_args = a:args
    return {'success': 1, 'data': 'test_func\tfunction(param: INTEGER) -> DECIMAL\ttest.4gl:42 | Complexity: 5, LOC: 23'}
  endfunction
  
  " Call external completions function
  let completions = genero_tools#complete#get_external_completions('test')
  
  " Verify format flag is in arguments
  call assert_true(index(g:test_command_args, '--format=vim-completion') >= 0, 'Completion format flag not found')
  
  " Restore original function
  delfunction genero_tools#command#execute_shell
endfunction

" Test 4: Verify hover format output parsing
function! Test_hover_format_parsing() abort
  " Mock the command execution
  function! genero_tools#command#execute_shell(command, args) abort
    return {'success': 1, 'data': 'test_function(param: INTEGER) -> DECIMAL\nFile: test.4gl:42\nComplexity: 5, LOC: 23'}
  endfunction
  
  " Call hover function
  let result = genero_tools#get_function_hover('test_function')
  
  " Verify result contains the formatted output
  call assert_true(result.success, 'Hover query failed')
  call assert_true(type(result.data) == type(''), 'Hover output should be string')
  call assert_true(result.data =~# 'test_function', 'Function name not in output')
  call assert_true(result.data =~# 'File:', 'File location not in output')
  call assert_true(result.data =~# 'Complexity:', 'Complexity not in output')
  
  " Restore original function
  delfunction genero_tools#command#execute_shell
endfunction

" Test 5: Verify completion format output parsing
function! Test_completion_format_parsing() abort
  " Mock the command execution
  function! genero_tools#command#execute_shell(command, args) abort
    return {'success': 1, 'data': "get_account\tfunction(id: INTEGER) -> RECORD\tsrc/queries.4gl:128 | Complexity: 3, LOC: 15\nget_balance\tfunction(account_id: INTEGER) -> DECIMAL\tsrc/queries.4gl:156 | Complexity: 2, LOC: 8"}
  endfunction
  
  " Call external completions function
  let completions = genero_tools#complete#get_external_completions('get')
  
  " Verify completions are parsed correctly
  call assert_true(len(completions) > 0, 'No completions returned')
  call assert_true(completions[0].word == 'get_account', 'First completion word incorrect')
  call assert_true(completions[0].menu =~# 'function', 'Menu text incorrect')
  call assert_true(completions[0].info =~# 'Complexity', 'Info text incorrect')
  
  " Restore original function
  delfunction genero_tools#command#execute_shell
endfunction

" Test 6: Verify format flag helper functions
function! Test_format_flag_helpers() abort
  " Test hover format getter
  let hover_format = genero_tools#format#get_hover_format()
  call assert_equal(hover_format, 'vim-hover', 'Hover format incorrect')
  
  " Test concise format getter
  let concise_format = genero_tools#format#get_concise_format()
  call assert_equal(concise_format, 'vim', 'Concise format incorrect')
  
  " Test completion format getter
  let completion_format = genero_tools#format#get_completion_format()
  call assert_equal(completion_format, 'vim-completion', 'Completion format incorrect')
endfunction

" Test 7: Verify add_flag function
function! Test_add_flag_function() abort
  " Test adding format flag
  let args = ['test_function']
  let result = genero_tools#format#add_flag(args, 'vim-hover')
  
  call assert_equal(len(result), 2, 'Flag not added')
  call assert_equal(result[0], 'test_function', 'Original arg modified')
  call assert_equal(result[1], '--format=vim-hover', 'Flag not added correctly')
endfunction

" Test 8: Verify execute_with_format function
function! Test_execute_with_format_function() abort
  " Mock the command execution
  let g:test_command_args = []
  function! genero_tools#command#execute_shell(command, args) abort
    let g:test_command_args = a:args
    return {'success': 1, 'data': 'test output'}
  endfunction
  
  " Call execute_with_format
  let result = genero_tools#format#execute_with_format('find-function', ['test_function'], 'vim-hover')
  
  " Verify format flag was added
  call assert_true(index(g:test_command_args, '--format=vim-hover') >= 0, 'Format flag not added')
  call assert_true(result.success, 'Query failed')
  
  " Restore original function
  delfunction genero_tools#command#execute_shell
endfunction

" Run all tests
function! Run_format_flags_tests() abort
  try
    call Test_hover_format_flag()
    echo 'Test 1 (hover format flag): PASSED'
  catch
    echo 'Test 1 (hover format flag): FAILED - ' . v:exception
  endtry
  
  try
    call Test_concise_format_flag()
    echo 'Test 2 (concise format flag): PASSED'
  catch
    echo 'Test 2 (concise format flag): FAILED - ' . v:exception
  endtry
  
  try
    call Test_completion_format_flag()
    echo 'Test 3 (completion format flag): PASSED'
  catch
    echo 'Test 3 (completion format flag): FAILED - ' . v:exception
  endtry
  
  try
    call Test_hover_format_parsing()
    echo 'Test 4 (hover format parsing): PASSED'
  catch
    echo 'Test 4 (hover format parsing): FAILED - ' . v:exception
  endtry
  
  try
    call Test_completion_format_parsing()
    echo 'Test 5 (completion format parsing): PASSED'
  catch
    echo 'Test 5 (completion format parsing): FAILED - ' . v:exception
  endtry
  
  try
    call Test_format_flag_helpers()
    echo 'Test 6 (format flag helpers): PASSED'
  catch
    echo 'Test 6 (format flag helpers): FAILED - ' . v:exception
  endtry
  
  try
    call Test_add_flag_function()
    echo 'Test 7 (add_flag function): PASSED'
  catch
    echo 'Test 7 (add_flag function): FAILED - ' . v:exception
  endtry
  
  try
    call Test_execute_with_format_function()
    echo 'Test 8 (execute_with_format function): PASSED'
  catch
    echo 'Test 8 (execute_with_format function): FAILED - ' . v:exception
  endtry
endfunction

" Run tests if this file is sourced directly
if expand('<sfile>:t') == 'test_format_flags_integration.vim'
  call Run_format_flags_tests()
endif
