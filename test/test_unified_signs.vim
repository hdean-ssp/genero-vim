" Test unified sign column system
" Verifies that compiler diagnostics and SVN signs can be combined

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

function! Test_Combined_Sign_Generation() abort
  echo "Test 1: Combined sign generation"
  
  " Test single signs
  let compiler_only = genero_tools#signs#get_combined_sign('GeneroCompilerError', '')
  let svn_only = genero_tools#signs#get_combined_sign('', 'GeneroSVNModified')
  
  echo "  Compiler only: " . compiler_only
  echo "  SVN only: " . svn_only
  
  let passed = 1
  let passed = passed && AssertEqual('GeneroCompilerError', compiler_only, "Compiler-only sign should be returned as-is")
  let passed = passed && AssertEqual('GeneroSVNModified', svn_only, "SVN-only sign should be returned as-is")
  
  " Test combined signs
  let combined1 = genero_tools#signs#get_combined_sign('GeneroCompilerError', 'GeneroSVNModified')
  let combined2 = genero_tools#signs#get_combined_sign('GeneroCompilerWarning', 'GeneroSVNAdded')
  
  echo "  Combined (Error + Modified): " . combined1
  echo "  Combined (Warning + Added): " . combined2
  
  " Combined signs should have GeneroCombo prefix
  let passed = passed && AssertEqual(1, combined1 =~? '^GeneroCombo', "Combined sign should have GeneroCombo prefix")
  let passed = passed && AssertEqual(1, combined2 =~? '^GeneroCombo', "Combined sign should have GeneroCombo prefix")
  
  if passed
    echo "✓ Test 1 passed!"
  endif
  
  return passed
endfunction

function! Test_Sign_Text_Mapping() abort
  echo "Test 2: Sign text mapping"
  
  let error_text = genero_tools#signs#get_sign_text('GeneroCompilerError')
  let warning_text = genero_tools#signs#get_sign_text('GeneroCompilerWarning')
  let modified_text = genero_tools#signs#get_sign_text('GeneroSVNModified')
  let added_text = genero_tools#signs#get_sign_text('GeneroSVNAdded')
  
  echo "  Error text: " . error_text
  echo "  Warning text: " . warning_text
  echo "  Modified text: " . modified_text
  echo "  Added text: " . added_text
  
  let passed = 1
  let passed = passed && AssertEqual('✕', error_text, "Error should map to ✕")
  let passed = passed && AssertEqual('⚠', warning_text, "Warning should map to ⚠")
  let passed = passed && AssertEqual('~', modified_text, "Modified should map to ~")
  let passed = passed && AssertEqual('+', added_text, "Added should map to +")
  
  if passed
    echo "✓ Test 2 passed!"
  endif
  
  return passed
endfunction

function! Test_Sign_Highlight_Mapping() abort
  echo "Test 3: Sign highlight mapping"
  
  let error_hl = genero_tools#signs#get_sign_highlight('GeneroCompilerError')
  let modified_hl = genero_tools#signs#get_sign_highlight('GeneroSVNModified')
  let empty_hl = genero_tools#signs#get_sign_highlight('')
  
  echo "  Error highlight: " . error_hl
  echo "  Modified highlight: " . modified_hl
  echo "  Empty highlight: " . empty_hl
  
  let passed = 1
  let passed = passed && AssertEqual('ErrorMsg', error_hl, "Error should map to ErrorMsg")
  let passed = passed && AssertEqual('GeneroSVNModified', modified_hl, "Modified should map to GeneroSVNModified")
  let passed = passed && AssertEqual('', empty_hl, "Empty sign should return empty highlight")
  
  if passed
    echo "✓ Test 3 passed!"
  endif
  
  return passed
endfunction

function! Test_Combined_Sign_Caching() abort
  echo "Test 4: Combined sign caching"
  
  " Get same combination twice
  let combined1 = genero_tools#signs#get_combined_sign('GeneroCompilerError', 'GeneroSVNModified')
  let combined2 = genero_tools#signs#get_combined_sign('GeneroCompilerError', 'GeneroSVNModified')
  
  echo "  First call: " . combined1
  echo "  Second call: " . combined2
  
  let passed = 1
  let passed = passed && AssertEqual(combined1, combined2, "Same combination should return same sign name (cached)")
  
  if passed
    echo "✓ Test 4 passed!"
  endif
  
  return passed
endfunction

" Run all tests
echo "Running unified sign column tests..."
echo ""

let test1 = Test_Combined_Sign_Generation()
echo ""
let test2 = Test_Sign_Text_Mapping()
echo ""
let test3 = Test_Sign_Highlight_Mapping()
echo ""
let test4 = Test_Combined_Sign_Caching()
echo ""

if test1 && test2 && test3 && test4
  echo "✓ All unified sign tests passed!"
else
  echo "✗ Some tests failed"
endif
