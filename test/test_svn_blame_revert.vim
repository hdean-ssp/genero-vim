" Test SVN Blame and Revert functionality
" Run with: vim -u NONE -S test/test_svn_blame_revert.vim

" Setup test environment
set nocompatible
filetype off

" Add plugin to runtimepath
let &runtimepath = expand('<sfile>:p:h:h') . ',' . &runtimepath

" Source the plugin
runtime! plugin/genero_tools.vim

" Test counter
let s:test_count = 0
let s:test_passed = 0
let s:test_failed = 0

" Test helper functions
function! s:assert_equal(expected, actual, message) abort
  let s:test_count += 1
  if a:expected == a:actual
    let s:test_passed += 1
    echo "✓ PASS: " . a:message
  else
    let s:test_failed += 1
    echo "✗ FAIL: " . a:message
    echo "  Expected: " . string(a:expected)
    echo "  Actual:   " . string(a:actual)
  endif
endfunction

function! s:assert_true(condition, message) abort
  call s:assert_equal(1, a:condition ? 1 : 0, a:message)
endfunction

function! s:assert_false(condition, message) abort
  call s:assert_equal(0, a:condition ? 1 : 0, a:message)
endfunction

" Test SVN Blame XML Parsing
function! Test_SVN_Blame_Parse_XML() abort
  echo "\n=== Test: SVN Blame XML Parsing ==="
  
  let xml_output = join([
    \ '<?xml version="1.0" encoding="UTF-8"?>',
    \ '<blame>',
    \ '<target path="test.4gl">',
    \ '<entry line-number="1">',
    \ '<commit revision="1234">',
    \ '<author>john.doe</author>',
    \ '<date>2024-01-15T10:30:45.123456Z</date>',
    \ '</commit>',
    \ '</entry>',
    \ '<entry line-number="2">',
    \ '<commit revision="1256">',
    \ '<author>jane.smith</author>',
    \ '<date>2024-01-20T14:45:30.654321Z</date>',
    \ '</commit>',
    \ '</entry>',
    \ '</target>',
    \ '</blame>'
    \ ], "\n")
  
  let result = genero_tools#svn#blame#parse_blame(xml_output)
  
  call s:assert_equal(2, len(result), 'Should parse 2 blame entries')
  
  if len(result) >= 2
    call s:assert_equal(1, result[0].line_num, 'First entry line number')
    call s:assert_equal('1234', result[0].revision, 'First entry revision')
    call s:assert_equal('john.doe', result[0].author, 'First entry author')
    call s:assert_equal('2024-01-15 10:30', result[0].date, 'First entry date')
    
    call s:assert_equal(2, result[1].line_num, 'Second entry line number')
    call s:assert_equal('1256', result[1].revision, 'Second entry revision')
    call s:assert_equal('jane.smith', result[1].author, 'Second entry author')
    call s:assert_equal('2024-01-20 14:45', result[1].date, 'Second entry date')
  endif
endfunction

" Test Date Formatting
function! Test_SVN_Blame_Format_Date() abort
  echo "\n=== Test: SVN Blame Date Formatting ==="
  
  let iso_date = '2024-01-15T10:30:45.123456Z'
  let formatted = genero_tools#svn#blame#format_date(iso_date)
  
  call s:assert_equal('2024-01-15 10:30', formatted, 'Should format ISO date correctly')
  
  " Test with different format
  let iso_date2 = '2024-12-31T23:59:00.000000Z'
  let formatted2 = genero_tools#svn#blame#format_date(iso_date2)
  
  call s:assert_equal('2024-12-31 23:59', formatted2, 'Should format end of year date')
endfunction

" Test Blame Info Formatting
function! Test_SVN_Blame_Format_Info() abort
  echo "\n=== Test: SVN Blame Info Formatting ==="
  
  let blame_entry = {
    \ 'line_num': 42,
    \ 'revision': '1234',
    \ 'author': 'john.doe',
    \ 'date': '2024-01-15 10:30'
    \ }
  
  let formatted = genero_tools#svn#blame#format_blame_info(blame_entry)
  
  call s:assert_equal('r1234 | john.doe | 2024-01-15 10:30', formatted, 'Should format blame info')
  
  " Test empty entry
  let empty_formatted = genero_tools#svn#blame#format_blame_info({})
  call s:assert_equal('No blame information available', empty_formatted, 'Should handle empty entry')
endfunction

" Test Revert Line Numbers Sorting
function! Test_SVN_Revert_Line_Sorting() abort
  echo "\n=== Test: Revert Line Number Sorting ==="
  
  " Create a temporary buffer for testing
  new
  call setline(1, ['line 1', 'line 2', 'line 3', 'line 4', 'line 5'])
  
  " Test that lines are processed in descending order
  " (This is important to avoid line number shifts during deletion)
  let line_nums = [2, 4, 1, 5, 3]
  let sorted = sort(copy(line_nums), {a, b -> b - a})
  
  call s:assert_equal([5, 4, 3, 2, 1], sorted, 'Should sort in descending order')
  
  " Clean up
  bdelete!
endfunction

" Test Revert Preview
function! Test_SVN_Revert_Preview() abort
  echo "\n=== Test: Revert Preview Generation ==="
  
  " Create a temporary buffer
  new
  call setline(1, ['original line 1', 'modified line 2', 'original line 3'])
  
  " Mock base content (would normally come from SVN)
  " We can't easily test the full revert without a real SVN repo,
  " but we can test the preview generation logic
  
  let preview = genero_tools#svn#revert#preview_revert(1, 3)
  
  call s:assert_true(len(preview) > 0, 'Should generate preview')
  call s:assert_true(preview[0] =~# 'Revert Preview', 'Should have preview header')
  
  " Clean up
  bdelete!
endfunction

" Test Command Registration
function! Test_SVN_Commands_Registered() abort
  echo "\n=== Test: SVN Command Registration ==="
  
  " Check that blame commands are registered
  call s:assert_true(exists(':GeneroSVNBlame'), 'GeneroSVNBlame command exists')
  call s:assert_true(exists(':GeneroSVNBlameCurrentLine'), 'GeneroSVNBlameCurrentLine command exists')
  call s:assert_true(exists(':GeneroSVNBlameRange'), 'GeneroSVNBlameRange command exists')
  
  " Check that revert commands are registered
  call s:assert_true(exists(':GeneroSVNRevertLine'), 'GeneroSVNRevertLine command exists')
  call s:assert_true(exists(':GeneroSVNRevertRange'), 'GeneroSVNRevertRange command exists')
  call s:assert_true(exists(':GeneroSVNRevertRangeConfirm'), 'GeneroSVNRevertRangeConfirm command exists')
  call s:assert_true(exists(':GeneroSVNRevertAllChanges'), 'GeneroSVNRevertAllChanges command exists')
endfunction

" Test Error Handling
function! Test_SVN_Blame_Error_Handling() abort
  echo "\n=== Test: SVN Blame Error Handling ==="
  
  " Test with empty file path
  let result = genero_tools#svn#blame#get_blame('')
  call s:assert_false(result.success, 'Should fail with empty file path')
  call s:assert_true(!empty(result.error), 'Should have error message')
  
  " Test with non-existent file
  let result = genero_tools#svn#blame#get_blame('/nonexistent/file.4gl')
  call s:assert_false(result.success, 'Should fail with non-existent file')
endfunction

function! Test_SVN_Revert_Error_Handling() abort
  echo "\n=== Test: SVN Revert Error Handling ==="
  
  " Test with empty file path
  let result = genero_tools#svn#revert#get_base_content('')
  call s:assert_false(result.success, 'Should fail with empty file path')
  call s:assert_true(!empty(result.error), 'Should have error message')
  
  " Test with invalid line range
  let result = genero_tools#svn#revert#revert_range(-1, 10)
  call s:assert_false(result.success, 'Should fail with invalid line range')
  
  let result = genero_tools#svn#revert#revert_range(10, 5)
  call s:assert_false(result.success, 'Should fail with reversed range')
endfunction

" Run all tests
function! RunAllTests() abort
  echo "==================================="
  echo "SVN Blame and Revert Test Suite"
  echo "==================================="
  
  call Test_SVN_Blame_Parse_XML()
  call Test_SVN_Blame_Format_Date()
  call Test_SVN_Blame_Format_Info()
  call Test_SVN_Revert_Line_Sorting()
  call Test_SVN_Revert_Preview()
  call Test_SVN_Commands_Registered()
  call Test_SVN_Blame_Error_Handling()
  call Test_SVN_Revert_Error_Handling()
  
  echo "\n==================================="
  echo "Test Results"
  echo "==================================="
  echo "Total:  " . s:test_count
  echo "Passed: " . s:test_passed
  echo "Failed: " . s:test_failed
  echo "==================================="
  
  if s:test_failed == 0
    echo "✓ All tests passed!"
    quit
  else
    echo "✗ Some tests failed"
    cquit
  endif
endfunction

" Run tests
call RunAllTests()
