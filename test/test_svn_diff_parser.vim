" Tests for SVN Diff Parser Module
" Tests unified diff format parsing and line change extraction

" Test: Parse basic diff
function! Test_parse_basic_diff() abort
  let diff = "Index: test.txt\n===================================================================\n--- test.txt\t(revision 100)\n+++ test.txt\t(working copy)\n@@ -1,5 +1,6 @@\n line 1\n-line 2\n+line 2 modified\n+line 2.5 added\n line 3\n line 4\n-line 5\n+line 5 modified\n"
  
  let result = genero_tools#svn#parser#parse_diff(diff)
  
  " Check result structure
  call assert_true(has_key(result, 'added'), 'Result should have added key')
  call assert_true(has_key(result, 'deleted'), 'Result should have deleted key')
  call assert_true(has_key(result, 'modified'), 'Result should have modified key')
  
  " Check that results are lists
  call assert_true(type(result.added) == type([]), 'added should be a list')
  call assert_true(type(result.deleted) == type([]), 'deleted should be a list')
  call assert_true(type(result.modified) == type([]), 'modified should be a list')
  
  echo 'Test passed: Parse basic diff'
endfunction

" Test: Get added lines
function! Test_get_added_lines() abort
  let diff = "Index: test.txt\n===================================================================\n--- test.txt\t(revision 100)\n+++ test.txt\t(working copy)\n@@ -1,5 +1,6 @@\n line 1\n-line 2\n+line 2 modified\n+line 2.5 added\n line 3\n line 4\n-line 5\n+line 5 modified\n"
  
  let added = genero_tools#svn#parser#get_added_lines(diff)
  
  " Should be a list
  call assert_true(type(added) == type([]), 'Should return a list')
  
  " Should contain line numbers
  call assert_true(len(added) > 0, 'Should have added lines')
  
  echo 'Test passed: Get added lines'
endfunction

" Test: Get deleted lines
function! Test_get_deleted_lines() abort
  let diff = "Index: test.txt\n===================================================================\n--- test.txt\t(revision 100)\n+++ test.txt\t(working copy)\n@@ -1,5 +1,6 @@\n line 1\n-line 2\n+line 2 modified\n+line 2.5 added\n line 3\n line 4\n-line 5\n+line 5 modified\n"
  
  let deleted = genero_tools#svn#parser#get_deleted_lines(diff)
  
  " Should be a list
  call assert_true(type(deleted) == type([]), 'Should return a list')
  
  " Should contain line numbers
  call assert_true(len(deleted) > 0, 'Should have deleted lines')
  
  echo 'Test passed: Get deleted lines'
endfunction

" Test: Parse multi-hunk diff
function! Test_parse_multi_hunk_diff() abort
  let diff = "Index: test.txt\n===================================================================\n--- test.txt\t(revision 100)\n+++ test.txt\t(working copy)\n@@ -1,3 +1,4 @@\n line 1\n+added line 2\n line 2\n line 3\n@@ -10,3 +11,4 @@\n line 10\n line 11\n-deleted line 12\n+modified line 12\n"
  
  let result = genero_tools#svn#parser#parse_diff(diff)
  
  " Check result structure
  call assert_true(has_key(result, 'added'), 'Result should have added key')
  call assert_true(has_key(result, 'deleted'), 'Result should have deleted key')
  
  echo 'Test passed: Parse multi-hunk diff'
endfunction

" Test: Empty diff
function! Test_empty_diff() abort
  let diff = "Index: test.txt\n===================================================================\n--- test.txt\t(revision 100)\n+++ test.txt\t(working copy)\n"
  
  let result = genero_tools#svn#parser#parse_diff(diff)
  
  " Should have empty lists
  call assert_equal([], result.added, 'Added should be empty')
  call assert_equal([], result.deleted, 'Deleted should be empty')
  
  echo 'Test passed: Empty diff'
endfunction

" Test: Is empty diff
function! Test_is_empty_diff() abort
  let empty_diff = "Index: test.txt\n===================================================================\n--- test.txt\t(revision 100)\n+++ test.txt\t(working copy)\n"
  let non_empty_diff = "Index: test.txt\n===================================================================\n--- test.txt\t(revision 100)\n+++ test.txt\t(working copy)\n@@ -1,5 +1,6 @@\n line 1\n-line 2\n+line 2 modified\n"
  
  let is_empty = genero_tools#svn#parser#is_empty(empty_diff)
  call assert_equal(1, is_empty, 'Should detect empty diff')
  
  let is_not_empty = genero_tools#svn#parser#is_empty(non_empty_diff)
  call assert_equal(0, is_not_empty, 'Should detect non-empty diff')
  
  echo 'Test passed: Is empty diff'
endfunction

" Test: Get summary
function! Test_get_summary() abort
  let diff = "Index: test.txt\n===================================================================\n--- test.txt\t(revision 100)\n+++ test.txt\t(working copy)\n@@ -1,5 +1,6 @@\n line 1\n-line 2\n+line 2 modified\n+line 2.5 added\n line 3\n line 4\n-line 5\n+line 5 modified\n"
  
  let summary = genero_tools#svn#parser#get_summary(diff)
  
  " Check summary structure
  call assert_true(has_key(summary, 'added_count'), 'Summary should have added_count')
  call assert_true(has_key(summary, 'deleted_count'), 'Summary should have deleted_count')
  call assert_true(has_key(summary, 'modified_count'), 'Summary should have modified_count')
  call assert_true(has_key(summary, 'total_changes'), 'Summary should have total_changes')
  
  " Check that counts are numbers
  call assert_true(type(summary.added_count) == type(0), 'added_count should be a number')
  call assert_true(type(summary.deleted_count) == type(0), 'deleted_count should be a number')
  call assert_true(type(summary.modified_count) == type(0), 'modified_count should be a number')
  call assert_true(type(summary.total_changes) == type(0), 'total_changes should be a number')
  
  echo 'Test passed: Get summary'
endfunction

" Test: Get all changes
function! Test_get_all_changes() abort
  let diff = "Index: test.txt\n===================================================================\n--- test.txt\t(revision 100)\n+++ test.txt\t(working copy)\n@@ -1,5 +1,6 @@\n line 1\n-line 2\n+line 2 modified\n"
  
  let changes = genero_tools#svn#parser#get_all_changes(diff)
  
  " Check structure
  call assert_true(has_key(changes, 'added'), 'Should have added key')
  call assert_true(has_key(changes, 'deleted'), 'Should have deleted key')
  call assert_true(has_key(changes, 'modified'), 'Should have modified key')
  
  echo 'Test passed: Get all changes'
endfunction

" Test: Detect modified lines
function! Test_detect_modified_lines() abort
  let added = [2, 3, 5]
  let deleted = [2, 5]
  
  let modified = genero_tools#svn#parser#detect_modified_lines(added, deleted)
  
  " Should be a list
  call assert_true(type(modified) == type([]), 'Should return a list')
  
  echo 'Test passed: Detect modified lines'
endfunction

" Test: Parse diff with no newline at end
function! Test_parse_diff_no_newline() abort
  let diff = "Index: test.txt\n===================================================================\n--- test.txt\t(revision 100)\n+++ test.txt\t(working copy)\n@@ -1,3 +1,3 @@\n line 1\n line 2\n-line 3\n\\ No newline at end of file\n+line 3 modified\n\\ No newline at end of file\n"
  
  let result = genero_tools#svn#parser#parse_diff(diff)
  
  " Should parse without errors
  call assert_true(type(result) == type({}), 'Should return a dict')
  
  echo 'Test passed: Parse diff with no newline at end'
endfunction

" Test: Parse diff with special characters
function! Test_parse_diff_special_chars() abort
  let diff = "Index: test.txt\n===================================================================\n--- test.txt\t(revision 100)\n+++ test.txt\t(working copy)\n@@ -1,3 +1,3 @@\n line 1\n-line with special chars: @#$%^&*()\n+line with special chars: @#$%^&*() modified\n line 3\n"
  
  let result = genero_tools#svn#parser#parse_diff(diff)
  
  " Should parse without errors
  call assert_true(type(result) == type({}), 'Should return a dict')
  
  echo 'Test passed: Parse diff with special characters'
endfunction

" Test: Parse diff with empty lines
function! Test_parse_diff_empty_lines() abort
  let diff = "Index: test.txt\n===================================================================\n--- test.txt\t(revision 100)\n+++ test.txt\t(working copy)\n@@ -1,5 +1,5 @@\n line 1\n \n-line 3\n+line 3 modified\n \n line 5\n"
  
  let result = genero_tools#svn#parser#parse_diff(diff)
  
  " Should parse without errors
  call assert_true(type(result) == type({}), 'Should return a dict')
  
  echo 'Test passed: Parse diff with empty lines'
endfunction

" Run all tests
function! Test_svn_diff_parser_all() abort
  call Test_parse_basic_diff()
  call Test_get_added_lines()
  call Test_get_deleted_lines()
  call Test_parse_multi_hunk_diff()
  call Test_empty_diff()
  call Test_is_empty_diff()
  call Test_get_summary()
  call Test_get_all_changes()
  call Test_detect_modified_lines()
  call Test_parse_diff_no_newline()
  call Test_parse_diff_special_chars()
  call Test_parse_diff_empty_lines()
  
  echo 'All SVN diff parser tests passed!'
endfunction

" Run tests if this file is executed directly
if expand('<sfile>') == expand('%')
  call Test_svn_diff_parser_all()
endif
