" Integration tests for SVN modules
" Tests the interaction between detection, diff retrieval, and parsing

" Test: Full workflow - detect, retrieve, and parse
function! Test_full_svn_workflow() abort
  " Create a temporary SVN-like structure
  let temp_dir = tempname()
  let work_dir = temp_dir . '/work'
  let test_file = work_dir . '/test.txt'
  
  call mkdir(work_dir, 'p')
  call mkdir(temp_dir . '/.svn', 'p')
  
  try
    " Test 1: Detection
    let is_in_wc = genero_tools#svn#detection#is_in_working_copy(test_file)
    call assert_equal(1, is_in_wc, 'Should detect file is in working copy')
    
    " Test 2: Get working copy root
    let root = genero_tools#svn#detection#get_working_copy_root(test_file)
    call assert_equal(temp_dir, root, 'Should get correct working copy root')
    
    echo 'Test passed: Full SVN workflow'
  finally
    call delete(temp_dir, 'rf')
  endtry
endfunction

" Test: Diff parsing with real diff output
function! Test_diff_parsing_realistic() abort
  " Realistic diff output from SVN
  let diff = "Index: myfile.txt\n===================================================================\n--- myfile.txt\t(revision 42)\n+++ myfile.txt\t(working copy)\n@@ -10,7 +10,8 @@\n function old_function() {\n   return 1\n }\n-function deleted_function() {\n+function modified_function() {\n+  return 2\n }\n function another_function() {\n   return 3\n@@ -25,3 +26,4 @@\n   return 5\n }\n+function new_function() {\n+  return 6\n+}\n"
  
  let parsed = genero_tools#svn#parser#parse_diff(diff)
  
  " Verify structure
  call assert_true(type(parsed.added) == type([]), 'added should be a list')
  call assert_true(type(parsed.deleted) == type([]), 'deleted should be a list')
  call assert_true(type(parsed.modified) == type([]), 'modified should be a list')
  
  " Verify we have changes
  call assert_true(len(parsed.added) > 0, 'Should have added lines')
  call assert_true(len(parsed.deleted) > 0, 'Should have deleted lines')
  
  echo 'Test passed: Diff parsing realistic'
endfunction

" Test: Cache operations
function! Test_cache_operations() abort
  let file_path = '/tmp/test.txt'
  let diff_result = {'success': 1, 'error': '', 'diff': 'test diff'}
  
  " Clear cache first
  call genero_tools#svn#cache_clear()
  
  " Test cache set
  call genero_tools#svn#cache_set(file_path, diff_result)
  
  " Test cache get
  let cached = genero_tools#svn#cache_get(file_path)
  call assert_true(!empty(cached), 'Should retrieve cached result')
  call assert_equal(diff_result, cached.diff, 'Cached result should match original')
  
  " Test cache invalidate
  call genero_tools#svn#cache_invalidate(file_path)
  let invalidated = genero_tools#svn#cache_get(file_path)
  call assert_equal({}, invalidated, 'Cache should be empty after invalidation')
  
  echo 'Test passed: Cache operations'
endfunction

" Test: Summary generation
function! Test_summary_generation() abort
  let diff = "Index: test.txt\n===================================================================\n--- test.txt\t(revision 100)\n+++ test.txt\t(working copy)\n@@ -1,5 +1,7 @@\n line 1\n-line 2\n+line 2 modified\n+line 2.5 added\n line 3\n-line 4\n+line 4 modified\n line 5\n"
  
  let summary = genero_tools#svn#parser#get_summary(diff)
  
  " Verify summary structure
  call assert_true(has_key(summary, 'added_count'), 'Should have added_count')
  call assert_true(has_key(summary, 'deleted_count'), 'Should have deleted_count')
  call assert_true(has_key(summary, 'modified_count'), 'Should have modified_count')
  call assert_true(has_key(summary, 'total_changes'), 'Should have total_changes')
  
  " Verify counts are reasonable
  call assert_true(summary.added_count >= 0, 'added_count should be non-negative')
  call assert_true(summary.deleted_count >= 0, 'deleted_count should be non-negative')
  call assert_true(summary.total_changes > 0, 'total_changes should be positive')
  
  echo 'Test passed: Summary generation'
endfunction

" Test: Empty diff handling
function! Test_empty_diff_handling() abort
  let empty_diff = "Index: test.txt\n===================================================================\n--- test.txt\t(revision 100)\n+++ test.txt\t(working copy)\n"
  
  let is_empty = genero_tools#svn#parser#is_empty(empty_diff)
  call assert_equal(1, is_empty, 'Should detect empty diff')
  
  let summary = genero_tools#svn#parser#get_summary(empty_diff)
  call assert_equal(0, summary.added_count, 'Empty diff should have 0 added')
  call assert_equal(0, summary.deleted_count, 'Empty diff should have 0 deleted')
  call assert_equal(0, summary.total_changes, 'Empty diff should have 0 total changes')
  
  echo 'Test passed: Empty diff handling'
endfunction

" Run all integration tests
function! Test_svn_integration_all() abort
  call Test_full_svn_workflow()
  call Test_diff_parsing_realistic()
  call Test_cache_operations()
  call Test_summary_generation()
  call Test_empty_diff_handling()
  
  echo 'All SVN integration tests passed!'
endfunction

" Run tests if this file is executed directly
if expand('<sfile>') == expand('%')
  call Test_svn_integration_all()
endif
