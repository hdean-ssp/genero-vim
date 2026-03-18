" Test SVN modified line detection
" This test verifies that modified lines are correctly detected and marked
" with a single yellow sign instead of separate +/- signs

function! AssertEqual(expected, actual, message) abort
  if a:expected != a:actual
    echohl ErrorMsg
    echo "FAIL: " . a:message
    echo "  Expected: " . string(a:expected)
    echo "  Actual:   " . string(a:actual)
    echohl None
    return 0
  endif
  return 1
endfunction

function! Test_SVN_Modified_Detection() abort
  " Sample SVN diff output with a modified line
  let diff_output = [
    \ 'Index: test.txt',
    \ '===================================================================',
    \ '--- test.txt	(revision 1)',
    \ '+++ test.txt	(revision 2)',
    \ '@@ -1,5 +1,5 @@',
    \ ' line 1',
    \ ' line 2',
    \ '-line 3 old version',
    \ '+line 3 new version',
    \ ' line 4',
    \ ' line 5'
    \ ]
  
  let diff_str = join(diff_output, "\n")
  
  " Parse the diff
  let changes = genero_tools#svn#parser#parse_diff(diff_str)
  
  " Verify results
  echo "Test 1: Single modification"
  echo "  Added lines: " . string(changes.added)
  echo "  Modified lines: " . string(changes.modified)
  echo "  Deleted lines: " . string(changes.deleted)
  
  " Expected: line 3 should be marked as modified (not added)
  " Expected: line 3 should be marked as deleted
  let passed = 1
  let passed = passed && AssertEqual([3], changes.modified, "Line 3 should be detected as modified")
  let passed = passed && AssertEqual([3], changes.deleted, "Line 3 should be detected as deleted")
  let passed = passed && AssertEqual([], changes.added, "No lines should be detected as added")
  
  if passed
    echo "✓ Test 1 passed!"
  endif
  
  return passed
endfunction

function! Test_SVN_Multiple_Modifications() abort
  " Sample SVN diff with multiple modifications
  let diff_output = [
    \ 'Index: test.txt',
    \ '===================================================================',
    \ '--- test.txt	(revision 1)',
    \ '+++ test.txt	(revision 2)',
    \ '@@ -1,10 +1,10 @@',
    \ ' line 1',
    \ '-line 2 old',
    \ '+line 2 new',
    \ ' line 3',
    \ '-line 4 old',
    \ '+line 4 new',
    \ ' line 5',
    \ '+line 6 added',
    \ ' line 7'
    \ ]
  
  let diff_str = join(diff_output, "\n")
  
  " Parse the diff
  let changes = genero_tools#svn#parser#parse_diff(diff_str)
  
  echo "Test 2: Multiple modifications with addition"
  echo "  Added lines: " . string(changes.added)
  echo "  Modified lines: " . string(changes.modified)
  echo "  Deleted lines: " . string(changes.deleted)
  
  " Expected: lines 2 and 4 should be modified
  " Expected: line 6 should be added
  let passed = 1
  let passed = passed && AssertEqual([6], changes.added, "Line 6 should be detected as added")
  let passed = passed && AssertEqual([2, 4], changes.modified, "Lines 2 and 4 should be detected as modified")
  let passed = passed && AssertEqual([2, 4], changes.deleted, "Lines 2 and 4 should be detected as deleted")
  
  if passed
    echo "✓ Test 2 passed!"
  endif
  
  return passed
endfunction

" Run tests
let test1_passed = Test_SVN_Modified_Detection()
echo ""
let test2_passed = Test_SVN_Multiple_Modifications()
echo ""

if test1_passed && test2_passed
  echo "✓ All tests passed!"
else
  echo "✗ Some tests failed"
endif
