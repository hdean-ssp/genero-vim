" Genero-Tools Plugin - Test Runner
" Runs all tests and reports results

" Initialize test environment
let s:test_count = 0
let s:passed_count = 0
let s:failed_count = 0
let s:test_results = []

" Assert equal
function! assert_equal(expected, actual, message) abort
  let s:test_count += 1
  if a:expected == a:actual
    let s:passed_count += 1
    call add(s:test_results, '✓ ' . a:message)
  else
    let s:failed_count += 1
    call add(s:test_results, '✗ ' . a:message)
    call add(s:test_results, '  Expected: ' . string(a:expected))
    call add(s:test_results, '  Actual: ' . string(a:actual))
  endif
endfunction

" Assert true
function! assert_true(value, message) abort
  call assert_equal(v:true, a:value, a:message)
endfunction

" Assert false
function! assert_false(value, message) abort
  call assert_equal(v:false, a:value, a:message)
endfunction

" Assert not empty
function! assert_not_empty(value, message) abort
  let s:test_count += 1
  if !empty(a:value)
    let s:passed_count += 1
    call add(s:test_results, '✓ ' . a:message)
  else
    let s:failed_count += 1
    call add(s:test_results, '✗ ' . a:message . ' (value is empty)')
  endif
endfunction

" Assert empty
function! assert_empty(value, message) abort
  let s:test_count += 1
  if empty(a:value)
    let s:passed_count += 1
    call add(s:test_results, '✓ ' . a:message)
  else
    let s:failed_count += 1
    call add(s:test_results, '✗ ' . a:message . ' (value is not empty)')
  endif
endfunction

" Run a test file
function! run_test_file(filepath) abort
  call add(s:test_results, '')
  call add(s:test_results, '=== ' . a:filepath . ' ===')
  
  try
    execute 'source ' . a:filepath
  catch
    call add(s:test_results, '✗ Error loading test file: ' . v:exception)
    let s:failed_count += 1
  endtry
endfunction

" Print test results
function! print_results() abort
  echo ''
  echo '=== Test Results ==='
  echo ''
  
  for line in s:test_results
    echo line
  endfor
  
  echo ''
  echo '=== Summary ==='
  echo 'Total: ' . s:test_count
  echo 'Passed: ' . s:passed_count
  echo 'Failed: ' . s:failed_count
  
  if s:failed_count == 0
    echo ''
    echo '✓ All tests passed!'
  else
    echo ''
    echo '✗ ' . s:failed_count . ' test(s) failed'
  endif
  
  echo ''
endfunction

" Main test runner
function! run_all_tests() abort
  " Initialize plugin
  call genero_tools#config#init()
  
  " Run unit tests
  call run_test_file('tests/unit/test_config.vim')
  call run_test_file('tests/unit/test_cache.vim')
  call run_test_file('tests/unit/test_command.vim')
  call run_test_file('tests/unit/test_display.vim')
  
  " Run integration tests
  call run_test_file('tests/integration/test_module_interactions.vim')
  
  " Run property-based tests
  call run_test_file('tests/properties/test_result_structure.vim')
  call run_test_file('tests/properties/test_cache_consistency.vim')
  call run_test_file('tests/properties/test_error_handling.vim')
  
  " Print results
  call print_results()
  
  " Return exit code
  return s:failed_count == 0 ? 0 : 1
endfunction

" Run tests if this file is executed directly
if !exists('g:test_runner_loaded')
  let g:test_runner_loaded = 1
  let exit_code = run_all_tests()
  quit
endif
