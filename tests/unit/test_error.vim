" Genero-Tools Plugin - Error Module Tests
" Tests for autoload/genero_tools/error.vim

function! Test_Error_Format_Creates_Correct_Format() abort
  " Given: Module name and message
  let l:module = 'config'
  let l:message = 'test error'
  
  " When: Formatting error
  let l:formatted = genero_tools#error#format(l:module, l:message)
  
  " Then: Format is [MODULE] message
  call assert_equal(l:formatted, '[config] test error')
endfunction

function! Test_Error_Format_With_Different_Modules() abort
  " Given: Different module names
  let l:config_error = genero_tools#error#format('config', 'invalid value')
  let l:cache_error = genero_tools#error#format('cache', 'eviction failed')
  let l:command_error = genero_tools#error#format('command', 'timeout')
  
  " When: Formatting errors
  " Then: Each has correct module prefix
  call assert_equal(l:config_error, '[config] invalid value')
  call assert_equal(l:cache_error, '[cache] eviction failed')
  call assert_equal(l:command_error, '[command] timeout')
endfunction

function! Test_Error_Result_Creates_Error_Result() abort
  " Given: Module name and message
  let l:module = 'cache'
  let l:message = 'not found'
  
  " When: Creating error result
  let l:result = genero_tools#error#result(l:module, l:message)
  
  " Then: Result has correct structure
  call assert_equal(l:result.success, v:false)
  call assert_equal(l:result.error, '[cache] not found')
  call assert_equal(empty(l:result.data), v:true)
  call assert_true(l:result.timestamp > 0)
endfunction

function! Test_Error_Result_Has_All_Required_Fields() abort
  " Given: Error result created
  let l:result = genero_tools#error#result('test', 'error message')
  
  " When: Checking result structure
  " Then: All required fields are present
  call assert_true(has_key(l:result, 'success'))
  call assert_true(has_key(l:result, 'data'))
  call assert_true(has_key(l:result, 'error'))
  call assert_true(has_key(l:result, 'timestamp'))
endfunction

function! Test_Error_Format_With_Special_Characters() abort
  " Given: Message with special characters
  let l:message = 'Invalid value: "test" (expected: number)'
  
  " When: Formatting error
  let l:formatted = genero_tools#error#format('config', l:message)
  
  " Then: Special characters are preserved
  call assert_equal(l:formatted, '[config] Invalid value: "test" (expected: number)')
endfunction

function! Test_Error_Format_With_Long_Message() abort
  " Given: Long error message
  let l:message = 'This is a very long error message that describes a complex issue in detail'
  
  " When: Formatting error
  let l:formatted = genero_tools#error#format('command', l:message)
  
  " Then: Full message is preserved
  call assert_equal(l:formatted, '[command] This is a very long error message that describes a complex issue in detail')
endfunction

function! Test_Error_Result_With_Multiple_Errors() abort
  " Given: Multiple error results
  let l:error1 = genero_tools#error#result('config', 'timeout invalid')
  let l:error2 = genero_tools#error#result('cache', 'size exceeded')
  let l:error3 = genero_tools#error#result('command', 'execution failed')
  
  " When: Creating multiple error results
  " Then: Each has correct error message
  call assert_equal(l:error1.error, '[config] timeout invalid')
  call assert_equal(l:error2.error, '[cache] size exceeded')
  call assert_equal(l:error3.error, '[command] execution failed')
  
  " And: All are marked as failures
  call assert_equal(l:error1.success, v:false)
  call assert_equal(l:error2.success, v:false)
  call assert_equal(l:error3.success, v:false)
endfunction

function! Test_Error_Format_Consistency() abort
  " Given: Same error formatted multiple times
  let l:error1 = genero_tools#error#format('test', 'message')
  let l:error2 = genero_tools#error#format('test', 'message')
  let l:error3 = genero_tools#error#format('test', 'message')
  
  " When: Formatting same error multiple times
  " Then: Results are identical
  call assert_equal(l:error1, l:error2)
  call assert_equal(l:error2, l:error3)
endfunction
