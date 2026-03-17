" Tests for SVN Detection Module
" Tests SVN availability checking and working copy detection

" Test: SVN availability check
function! Test_svn_is_available() abort
  " This test checks if SVN is available on the system
  " It will pass if SVN is installed, fail if not
  let is_available = genero_tools#svn#detection#is_available()
  
  " Result should be a boolean
  call assert_true(type(is_available) == type(0), 'is_available should return a number')
  
  " If SVN is available, it should be 1, otherwise 0
  call assert_true(is_available == 0 || is_available == 1, 'is_available should return 0 or 1')
  
  echo 'Test passed: SVN availability check'
endfunction

" Test: SVN availability caching
function! Test_svn_availability_caching() abort
  " Clear cache first
  call genero_tools#svn#detection#cache_clear()
  
  " First call should check system
  let result1 = genero_tools#svn#detection#is_available()
  
  " Second call should use cache
  let result2 = genero_tools#svn#detection#is_available()
  
  " Results should be identical
  call assert_equal(result1, result2, 'Cached result should match original')
  
  echo 'Test passed: SVN availability caching'
endfunction

" Test: Find SVN directory in current directory
function! Test_find_svn_dir_current() abort
  " Create a temporary directory with .svn subdirectory
  let temp_dir = tempname()
  call mkdir(temp_dir, 'p')
  call mkdir(temp_dir . '/.svn', 'p')
  
  try
    let svn_dir = genero_tools#svn#detection#find_svn_dir(temp_dir)
    call assert_equal(temp_dir . '/.svn', svn_dir, 'Should find .svn in current directory')
  finally
    call delete(temp_dir, 'rf')
  endtry
  
  echo 'Test passed: Find SVN directory in current directory'
endfunction

" Test: Find SVN directory in parent directory
function! Test_find_svn_dir_parent() abort
  " Create a temporary directory structure
  let temp_dir = tempname()
  let parent_dir = temp_dir . '/parent'
  let child_dir = parent_dir . '/child'
  
  call mkdir(child_dir, 'p')
  call mkdir(parent_dir . '/.svn', 'p')
  
  try
    let svn_dir = genero_tools#svn#detection#find_svn_dir(child_dir)
    call assert_equal(parent_dir . '/.svn', svn_dir, 'Should find .svn in parent directory')
  finally
    call delete(temp_dir, 'rf')
  endtry
  
  echo 'Test passed: Find SVN directory in parent directory'
endfunction

" Test: Find SVN directory not found
function! Test_find_svn_dir_not_found() abort
  " Create a temporary directory without .svn
  let temp_dir = tempname()
  call mkdir(temp_dir, 'p')
  
  try
    let svn_dir = genero_tools#svn#detection#find_svn_dir(temp_dir)
    call assert_equal('', svn_dir, 'Should return empty string when .svn not found')
  finally
    call delete(temp_dir, 'rf')
  endtry
  
  echo 'Test passed: Find SVN directory not found'
endfunction

" Test: Get working copy root
function! Test_get_working_copy_root() abort
  " Create a temporary directory structure
  let temp_dir = tempname()
  let child_dir = temp_dir . '/child'
  
  call mkdir(child_dir, 'p')
  call mkdir(temp_dir . '/.svn', 'p')
  
  try
    let root = genero_tools#svn#detection#get_working_copy_root(child_dir . '/test.txt')
    call assert_equal(temp_dir, root, 'Should return working copy root')
  finally
    call delete(temp_dir, 'rf')
  endtry
  
  echo 'Test passed: Get working copy root'
endfunction

" Test: Get working copy root not found
function! Test_get_working_copy_root_not_found() abort
  " Create a temporary directory without .svn
  let temp_dir = tempname()
  call mkdir(temp_dir, 'p')
  
  try
    let root = genero_tools#svn#detection#get_working_copy_root(temp_dir . '/test.txt')
    call assert_equal('', root, 'Should return empty string when not in working copy')
  finally
    call delete(temp_dir, 'rf')
  endtry
  
  echo 'Test passed: Get working copy root not found'
endfunction

" Test: Is in working copy
function! Test_is_in_working_copy() abort
  " Create a temporary directory structure
  let temp_dir = tempname()
  let child_dir = temp_dir . '/child'
  
  call mkdir(child_dir, 'p')
  call mkdir(temp_dir . '/.svn', 'p')
  
  try
    let in_wc = genero_tools#svn#detection#is_in_working_copy(child_dir . '/test.txt')
    call assert_equal(1, in_wc, 'Should detect file is in working copy')
  finally
    call delete(temp_dir, 'rf')
  endtry
  
  echo 'Test passed: Is in working copy'
endfunction

" Test: Is not in working copy
function! Test_is_not_in_working_copy() abort
  " Create a temporary directory without .svn
  let temp_dir = tempname()
  call mkdir(temp_dir, 'p')
  
  try
    let in_wc = genero_tools#svn#detection#is_in_working_copy(temp_dir . '/test.txt')
    call assert_equal(0, in_wc, 'Should detect file is not in working copy')
  finally
    call delete(temp_dir, 'rf')
  endtry
  
  echo 'Test passed: Is not in working copy'
endfunction

" Run all tests
function! Test_svn_detection_all() abort
  call Test_svn_is_available()
  call Test_svn_availability_caching()
  call Test_find_svn_dir_current()
  call Test_find_svn_dir_parent()
  call Test_find_svn_dir_not_found()
  call Test_get_working_copy_root()
  call Test_get_working_copy_root_not_found()
  call Test_is_in_working_copy()
  call Test_is_not_in_working_copy()
  
  echo 'All SVN detection tests passed!'
endfunction

" Run tests if this file is executed directly
if expand('<sfile>') == expand('%')
  call Test_svn_detection_all()
endif
