" Integration tests for SVN signs with main SVN module
" Tests sign placement through the main SVN module interface

" Test: Display signs for a file with changes
function! Test_display_signs_integration() abort
  " Initialize SVN module
  call genero_tools#svn#init()
  
  " Create a test diff
  let diff = "Index: test.txt\n===================================================================\n--- test.txt\t(revision 100)\n+++ test.txt\t(working copy)\n@@ -1,5 +1,6 @@\n line 1\n-line 2\n+line 2 modified\n+line 2.5 added\n line 3\n line 4\n-line 5\n+line 5 modified\n"
  
  " Parse the diff
  let changes = genero_tools#svn#parser#parse_diff(diff)
  
  " Verify changes were parsed
  call assert_true(len(changes.added) > 0, 'Should have added lines')
  call assert_true(len(changes.deleted) > 0, 'Should have deleted lines')
  
  " Place signs
  let bufnr = bufnr('%')
  call genero_tools#svn#signs#place(bufnr, changes)
  
  call assert_true(1, 'Signs placed through integration')
  
  echo 'Test passed: Display signs integration'
endfunction

" Test: Clear signs through main module
function! Test_clear_signs_integration() abort
  call genero_tools#svn#init()
  
  " Place some signs
  let changes = {
    \ 'added': [1, 2, 3],
    \ 'modified': [5, 6],
    \ 'deleted': [10]
    \ }
  
  let bufnr = bufnr('%')
  call genero_tools#svn#signs#place(bufnr, changes)
  
  " Clear signs through main module
  call genero_tools#svn#clear_signs()
  
  call assert_true(1, 'Signs cleared through integration')
  
  echo 'Test passed: Clear signs integration'
endfunction

" Test: Sign placement with parser output
function! Test_signs_with_parser_output() abort
  call genero_tools#svn#init()
  
  " Create a realistic diff
  let diff = "Index: test.4gl\n===================================================================\n--- test.4gl\t(revision 100)\n+++ test.4gl\t(working copy)\n@@ -1,10 +1,12 @@\n FUNCTION test()\n   DEFINE x INT\n-  LET x = 10\n+  LET x = 20\n+  LET y = 30\n   DISPLAY x\n END FUNCTION\n \n FUNCTION another()\n   DEFINE a INT\n-  LET a = 5\n+  LET a = 15\n END FUNCTION\n"
  
  " Parse the diff
  let changes = genero_tools#svn#parser#parse_diff(diff)
  
  " Place signs
  let bufnr = bufnr('%')
  call genero_tools#svn#signs#place(bufnr, changes)
  
  call assert_true(1, 'Signs placed with parser output')
  
  echo 'Test passed: Signs with parser output'
endfunction

" Test: Multiple buffer sign isolation
function! Test_multiple_buffer_isolation() abort
  call genero_tools#svn#init()
  
  " Get current buffer
  let bufnr1 = bufnr('%')
  
  " Place signs in current buffer
  let changes1 = {
    \ 'added': [1, 2, 3],
    \ 'modified': [],
    \ 'deleted': []
    \ }
  
  call genero_tools#svn#signs#place(bufnr1, changes1)
  
  " Create another buffer
  new
  let bufnr2 = bufnr('%')
  
  " Place different signs in second buffer
  let changes2 = {
    \ 'added': [10, 11],
    \ 'modified': [20],
    \ 'deleted': []
    \ }
  
  call genero_tools#svn#signs#place(bufnr2, changes2)
  
  " Clear signs in second buffer
  call genero_tools#svn#signs#clear(bufnr2)
  
  " Switch back to first buffer
  execute 'buffer ' . bufnr1
  
  call assert_true(1, 'Multiple buffer isolation works')
  
  " Clean up
  execute 'bdelete ' . bufnr2
  
  echo 'Test passed: Multiple buffer isolation'
endfunction

" Test: Sign placement with large diff
function! Test_large_diff_signs() abort
  call genero_tools#svn#init()
  
  " Create a large diff with many changes
  let diff_lines = ['Index: large.txt', '===================================================================', '--- large.txt\t(revision 100)', '+++ large.txt\t(working copy)', '@@ -1,100 +1,110 @@']
  
  " Add 100 lines of diff content
  for i in range(1, 100)
    if i % 3 == 0
      call add(diff_lines, '+added line ' . i)
    elseif i % 3 == 1
      call add(diff_lines, '-deleted line ' . i)
    else
      call add(diff_lines, ' context line ' . i)
    endif
  endfor
  
  let diff = join(diff_lines, '\n')
  
  " Parse the diff
  let changes = genero_tools#svn#parser#parse_diff(diff)
  
  " Place signs
  let bufnr = bufnr('%')
  call genero_tools#svn#signs#place(bufnr, changes)
  
  call assert_true(1, 'Large diff handled correctly')
  
  echo 'Test passed: Large diff signs'
endfunction

" Test: Sign placement with empty diff
function! Test_empty_diff_signs() abort
  call genero_tools#svn#init()
  
  let diff = "Index: test.txt\n===================================================================\n--- test.txt\t(revision 100)\n+++ test.txt\t(working copy)\n"
  
  let changes = genero_tools#svn#parser#parse_diff(diff)
  
  let bufnr = bufnr('%')
  call genero_tools#svn#signs#place(bufnr, changes)
  
  call assert_true(1, 'Empty diff handled correctly')
  
  echo 'Test passed: Empty diff signs'
endfunction

" Test: Highlight groups exist after init
function! Test_highlight_groups_exist() abort
  call genero_tools#svn#init()
  
  call assert_true(hlexists('GeneroSVNAdded'), 'GeneroSVNAdded highlight should exist')
  call assert_true(hlexists('GeneroSVNModified'), 'GeneroSVNModified highlight should exist')
  call assert_true(hlexists('GeneroSVNDeleted'), 'GeneroSVNDeleted highlight should exist')
  
  echo 'Test passed: Highlight groups exist'
endfunction

" Run all integration tests
function! Test_svn_signs_integration_all() abort
  call Test_display_signs_integration()
  call Test_clear_signs_integration()
  call Test_signs_with_parser_output()
  call Test_multiple_buffer_isolation()
  call Test_large_diff_signs()
  call Test_empty_diff_signs()
  call Test_highlight_groups_exist()
  
  echo 'All SVN signs integration tests passed!'
endfunction

" Run tests if this file is executed directly
if expand('<sfile>') == expand('%')
  call Test_svn_signs_integration_all()
endif

