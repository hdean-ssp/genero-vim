" Unit tests for autocomplete enhancements (Task 3)
" Tests for signature formatting, extended sources, and enhanced signatures

" Test setup
let s:test_results = []
let s:test_count = 0
let s:test_passed = 0
let s:test_failed = 0

function! s:assert_equal(actual, expected, test_name)
  let s:test_count += 1
  if a:actual == a:expected
    let s:test_passed += 1
    call add(s:test_results, '✓ ' . a:test_name)
  else
    let s:test_failed += 1
    call add(s:test_results, '✗ ' . a:test_name)
    call add(s:test_results, '  Expected: ' . string(a:expected))
    call add(s:test_results, '  Actual: ' . string(a:actual))
  endif
endfunction

function! s:assert_true(value, test_name)
  call s:assert_equal(a:value, 1, a:test_name)
endfunction

function! s:assert_false(value, test_name)
  call s:assert_equal(a:value, 0, a:test_name)
endfunction

function! s:assert_contains(haystack, needle, test_name)
  let s:test_count += 1
  if stridx(a:haystack, a:needle) >= 0
    let s:test_passed += 1
    call add(s:test_results, '✓ ' . a:test_name)
  else
    let s:test_failed += 1
    call add(s:test_results, '✗ ' . a:test_name)
    call add(s:test_results, '  Expected to contain: ' . a:needle)
    call add(s:test_results, '  Actual: ' . a:haystack)
  endif
endfunction

" ============================================================================
" Test Suite 1: Signature Formatting
" ============================================================================

function! Test_signature_abbreviate_type()
  call s:assert_equal(genero_tools#signature#abbreviate_type('STRING'), 'STR', 'Abbreviate STRING to STR')
  call s:assert_equal(genero_tools#signature#abbreviate_type('INTEGER'), 'INT', 'Abbreviate INTEGER to INT')
  call s:assert_equal(genero_tools#signature#abbreviate_type('DECIMAL'), 'DEC', 'Abbreviate DECIMAL to DEC')
  call s:assert_equal(genero_tools#signature#abbreviate_type('BOOLEAN'), 'BOOL', 'Abbreviate BOOLEAN to BOOL')
  call s:assert_equal(genero_tools#signature#abbreviate_type('DATETIME'), 'DT', 'Abbreviate DATETIME to DT')
endfunction

function! Test_signature_get_full_type()
  call s:assert_equal(genero_tools#signature#get_full_type('STR'), 'STRING', 'Expand STR to STRING')
  call s:assert_equal(genero_tools#signature#get_full_type('INT'), 'INTEGER', 'Expand INT to INTEGER')
  call s:assert_equal(genero_tools#signature#get_full_type('DEC'), 'DECIMAL', 'Expand DEC to DECIMAL')
  call s:assert_equal(genero_tools#signature#get_full_type('BOOL'), 'BOOLEAN', 'Expand BOOL to BOOLEAN')
  call s:assert_equal(genero_tools#signature#get_full_type('ARR'), 'DYNAMIC ARRAY', 'Expand ARR to DYNAMIC ARRAY')
  call s:assert_equal(genero_tools#signature#get_full_type('REC'), 'RECORD', 'Expand REC to RECORD')
endfunction

function! Test_signature_truncate()
  let short_sig = 'myFunc(param1:STR, param2:INT) -> BOOL'
  let truncated = genero_tools#signature#truncate(short_sig, 100)
  call s:assert_equal(truncated, short_sig, 'Short signature not truncated')
  
  let long_sig = 'myFunc(param1:STRING, param2:INTEGER, param3:DECIMAL, param4:BOOLEAN, param5:DATETIME) -> BOOLEAN'
  let truncated = genero_tools#signature#truncate(long_sig, 40)
  call s:assert_true(len(truncated) <= 40, 'Truncated signature fits in limit')
  call s:assert_contains(truncated, '...', 'Truncated signature has ellipsis')
endfunction

function! Test_signature_format_for_menu()
  let func = {
    \ 'name': 'myFunc',
    \ 'parameters': [
    \   {'name': 'param1', 'type': 'STRING'},
    \   {'name': 'param2', 'type': 'INTEGER'}
    \ ],
    \ 'returns': [{'name': 'result', 'type': 'BOOLEAN'}]
  \ }
  
  let menu_sig = genero_tools#signature#format_for_menu(func)
  call s:assert_contains(menu_sig, 'myFunc', 'Menu signature contains function name')
  call s:assert_true(len(menu_sig) <= 60, 'Menu signature fits in 60 chars')
endfunction

function! Test_signature_format_for_info()
  let func = {
    \ 'name': 'myFunc',
    \ 'parameters': [
    \   {'name': 'param1', 'type': 'STRING'},
    \   {'name': 'param2', 'type': 'INTEGER'}
    \ ],
    \ 'returns': [{'name': 'result', 'type': 'BOOLEAN'}]
  \ }
  
  let info_sig = genero_tools#signature#format_for_info(func)
  call s:assert_contains(info_sig, 'myFunc', 'Info signature contains function name')
  call s:assert_true(len(info_sig) <= 100, 'Info signature fits in 100 chars')
endfunction

" ============================================================================
" Test Suite 2: Parameter Counting
" ============================================================================

function! Test_signature_param_count()
  let func_no_params = {'name': 'noParams', 'parameters': []}
  call s:assert_equal(genero_tools#signature#param_count(func_no_params), 0, 'Count 0 parameters')
  
  let func_one_param = {
    \ 'name': 'oneParam',
    \ 'parameters': [{'name': 'param1', 'type': 'STRING'}]
  \ }
  call s:assert_equal(genero_tools#signature#param_count(func_one_param), 1, 'Count 1 parameter')
  
  let func_many_params = {
    \ 'name': 'manyParams',
    \ 'parameters': [
    \   {'name': 'p1', 'type': 'STRING'},
    \   {'name': 'p2', 'type': 'INTEGER'},
    \   {'name': 'p3', 'type': 'DECIMAL'},
    \   {'name': 'p4', 'type': 'BOOLEAN'}
    \ ]
  \ }
  call s:assert_equal(genero_tools#signature#param_count(func_many_params), 4, 'Count 4 parameters')
endfunction

function! Test_signature_return_count()
  let func_no_returns = {'name': 'noReturns', 'returns': []}
  call s:assert_equal(genero_tools#signature#return_count(func_no_returns), 0, 'Count 0 returns')
  
  let func_one_return = {
    \ 'name': 'oneReturn',
    \ 'returns': [{'name': 'result', 'type': 'STRING'}]
  \ }
  call s:assert_equal(genero_tools#signature#return_count(func_one_return), 1, 'Count 1 return')
  
  let func_multi_return = {
    \ 'name': 'multiReturn',
    \ 'returns': [
    \   {'name': 'result1', 'type': 'STRING'},
    \   {'name': 'result2', 'type': 'INTEGER'},
    \   {'name': 'result3', 'type': 'BOOLEAN'}
    \ ]
  \ }
  call s:assert_equal(genero_tools#signature#return_count(func_multi_return), 3, 'Count 3 returns')
endfunction

" ============================================================================
" Test Suite 3: Parameter Formatting
" ============================================================================

function! Test_signature_format_parameters()
  let func = {
    \ 'name': 'myFunc',
    \ 'parameters': [
    \   {'name': 'param1', 'type': 'STRING'},
    \   {'name': 'param2', 'type': 'INTEGER'}
    \ ]
  \ }
  
  let params = genero_tools#signature#format_parameters(func)
  call s:assert_equal(len(params), 2, 'Format 2 parameters')
  call s:assert_contains(params[0], 'param1', 'First parameter contains name')
  call s:assert_contains(params[0], 'STRING', 'First parameter contains full type')
  call s:assert_contains(params[1], 'param2', 'Second parameter contains name')
  call s:assert_contains(params[1], 'INTEGER', 'Second parameter contains full type')
endfunction

function! Test_signature_format_returns()
  let func = {
    \ 'name': 'myFunc',
    \ 'returns': [
    \   {'name': 'result', 'type': 'BOOLEAN'},
    \   {'name': 'status', 'type': 'STRING'}
    \ ]
  \ }
  
  let returns = genero_tools#signature#format_returns(func)
  call s:assert_equal(len(returns), 2, 'Format 2 returns')
  call s:assert_contains(returns[0], 'result', 'First return contains name')
  call s:assert_contains(returns[0], 'BOOLEAN', 'First return contains full type')
  call s:assert_contains(returns[1], 'status', 'Second return contains name')
  call s:assert_contains(returns[1], 'STRING', 'Second return contains full type')
endfunction

function! Test_signature_format_calls()
  let func_no_calls = {'name': 'noCallsFunc', 'calls': []}
  let calls = genero_tools#signature#format_calls(func_no_calls)
  call s:assert_equal(len(calls), 1, 'No calls returns 1 line')
  call s:assert_contains(calls[0], 'no function calls', 'No calls message shown')
  
  let func_with_calls = {
    \ 'name': 'myFunc',
    \ 'calls': [
    \   {'name': 'validate_input', 'line': 45},
    \   {'name': 'log_message', 'line': 48},
    \   {'name': 'save_data', 'line': 52}
    \ ]
  \ }
  let calls = genero_tools#signature#format_calls(func_with_calls)
  call s:assert_equal(len(calls), 1, 'Calls formatted as single line')
  call s:assert_contains(calls[0], 'validate_input', 'First call shown')
  call s:assert_contains(calls[0], 'log_message', 'Second call shown')
  call s:assert_contains(calls[0], 'save_data', 'Third call shown')
  call s:assert_contains(calls[0], '3 functions', 'Call count shown')
endfunction

" ============================================================================
" Test Suite 4: Complete Info Formatting
" ============================================================================

function! Test_signature_format_complete_info()
  let func = {
    \ 'name': 'processOrder',
    \ 'file': '/src/orders.4gl',
    \ 'line_start': 125,
    \ 'line_end': 180,
    \ 'parameters': [
    \   {'name': 'order', 'type': 'RECORD'},
    \   {'name': 'customer', 'type': 'RECORD'},
    \   {'name': 'items', 'type': 'DYNAMIC ARRAY'}
    \ ],
    \ 'returns': [{'name': 'success', 'type': 'BOOLEAN'}],
    \ 'calls': [
    \   {'name': 'validate_order', 'line': 130},
    \   {'name': 'calculate_total', 'line': 140}
    \ ]
  \ }
  
  let info = genero_tools#signature#format_complete_info(func)
  
  " Check header
  call s:assert_contains(info, 'processOrder', 'Info contains function name')
  call s:assert_contains(info, '3 params', 'Info shows parameter count')
  call s:assert_contains(info, '1 return', 'Info shows return count')
  call s:assert_contains(info, '/src/orders.4gl:125-180', 'Info shows file and line range')
  
  " Check parameters section
  call s:assert_contains(info, 'Parameters:', 'Info has parameters section')
  call s:assert_contains(info, 'order: RECORD', 'Info shows first parameter')
  call s:assert_contains(info, 'customer: RECORD', 'Info shows second parameter')
  call s:assert_contains(info, 'items: DYNAMIC ARRAY', 'Info shows third parameter')
  
  " Check returns section
  call s:assert_contains(info, 'Returns:', 'Info has returns section')
  call s:assert_contains(info, 'success: BOOLEAN', 'Info shows return type')
  
  " Check calls section
  call s:assert_contains(info, 'Calls:', 'Info has calls section')
  call s:assert_contains(info, 'validate_order', 'Info shows first call')
  call s:assert_contains(info, 'calculate_total', 'Info shows second call')
  call s:assert_contains(info, '2 functions', 'Info shows call count')
endfunction

" ============================================================================
" Test Suite 5: Edge Cases
" ============================================================================

function! Test_signature_empty_function()
  let empty_func = {}
  
  call s:assert_equal(genero_tools#signature#param_count(empty_func), 0, 'Empty function has 0 params')
  call s:assert_equal(genero_tools#signature#return_count(empty_func), 0, 'Empty function has 0 returns')
  
  let params = genero_tools#signature#format_parameters(empty_func)
  call s:assert_equal(len(params), 0, 'Empty function has no formatted params')
  
  let returns = genero_tools#signature#format_returns(empty_func)
  call s:assert_equal(len(returns), 0, 'Empty function has no formatted returns')
endfunction

function! Test_signature_function_no_calls()
  let func = {
    \ 'name': 'simpleFunc',
    \ 'parameters': [{'name': 'id', 'type': 'INTEGER'}],
    \ 'returns': [{'name': 'result', 'type': 'STRING'}],
    \ 'calls': []
  \ }
  
  let info = genero_tools#signature#format_complete_info(func)
  call s:assert_contains(info, 'no function calls', 'Info shows no calls message')
endfunction

function! Test_signature_function_no_returns()
  let func = {
    \ 'name': 'voidFunc',
    \ 'parameters': [{'name': 'data', 'type': 'STRING'}],
    \ 'returns': [],
    \ 'calls': [{'name': 'process_data', 'line': 50}]
  \ }
  
  let info = genero_tools#signature#format_complete_info(func)
  call s:assert_contains(info, '0 returns', 'Info shows 0 returns')
endfunction

" ============================================================================
" Run all tests
" ============================================================================

function! RunAllTests()
  call add(s:test_results, '=== Autocomplete Enhancements Unit Tests ===')
  call add(s:test_results, '')
  
  " Run test suites
  call add(s:test_results, 'Test Suite 1: Signature Formatting')
  call Test_signature_abbreviate_type()
  call Test_signature_get_full_type()
  call Test_signature_truncate()
  call Test_signature_format_for_menu()
  call Test_signature_format_for_info()
  call add(s:test_results, '')
  
  call add(s:test_results, 'Test Suite 2: Parameter Counting')
  call Test_signature_param_count()
  call Test_signature_return_count()
  call add(s:test_results, '')
  
  call add(s:test_results, 'Test Suite 3: Parameter Formatting')
  call Test_signature_format_parameters()
  call Test_signature_format_returns()
  call Test_signature_format_calls()
  call add(s:test_results, '')
  
  call add(s:test_results, 'Test Suite 4: Complete Info Formatting')
  call Test_signature_format_complete_info()
  call add(s:test_results, '')
  
  call add(s:test_results, 'Test Suite 5: Edge Cases')
  call Test_signature_empty_function()
  call Test_signature_function_no_calls()
  call Test_signature_function_no_returns()
  call add(s:test_results, '')
  
  " Print summary
  call add(s:test_results, '=== Test Summary ===')
  call add(s:test_results, 'Total: ' . s:test_count)
  call add(s:test_results, 'Passed: ' . s:test_passed)
  call add(s:test_results, 'Failed: ' . s:test_failed)
  
  if s:test_failed == 0
    call add(s:test_results, 'Status: ✓ ALL TESTS PASSED')
  else
    call add(s:test_results, 'Status: ✗ SOME TESTS FAILED')
  endif
  
  " Print results
  for line in s:test_results
    echo line
  endfor
  
  " Write to file
  call writefile(s:test_results, 'test/TEST_AUTOCOMPLETE_ENHANCEMENTS.txt')
endfunction

" Run tests if this file is sourced directly
if !exists('g:test_autocomplete_enhancements_loaded')
  let g:test_autocomplete_enhancements_loaded = 1
  call RunAllTests()
endif
