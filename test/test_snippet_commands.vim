" Test snippet commands and discovery
" Tests for Task 6: Implement snippet commands and discovery

" Test 6.1: Snippet list command
function! Test_snippet_list_command() abort
  " Verify :GeneroSnippetList command exists
  try
    call genero_tools#snippets#list()
    echo "✓ GeneroSnippetList command works"
  catch
    echo "✗ GeneroSnippetList command failed: " . v:exception
  endtry
endfunction

" Test 6.3: Snippet help display
function! Test_snippet_help_command() abort
  " Test help for a known snippet
  try
    call genero_tools#snippets#help('fn')
    echo "✓ GeneroSnippetHelp command works"
  catch
    echo "✗ GeneroSnippetHelp command failed: " . v:exception
  endtry
endfunction

" Test 6.5: Snippet command trigger
function! Test_snippet_expand_command() abort
  " Test expanding a snippet by name
  try
    " This should expand the 'fn' snippet
    call genero_tools#snippets#expand('fn')
    echo "✓ GeneroSnippet command works"
  catch
    echo "✗ GeneroSnippet command failed: " . v:exception
  endtry
endfunction

" Test 6.6: Error handling
function! Test_snippet_error_handling() abort
  " Test error message for non-existent snippet
  try
    call genero_tools#snippets#expand('nonexistent')
    echo "✓ Error handling works"
  catch
    echo "✗ Error handling failed: " . v:exception
  endtry
endfunction

" Test snippet availability
function! Test_snippet_availability() abort
  let available = genero_tools#snippets#available()
  if available
    echo "✓ Snippets are available"
  else
    echo "✗ Snippets are not available"
  endif
endfunction

" Test snippet count
function! Test_snippet_count() abort
  let count = genero_tools#snippets#get_count()
  if count > 0
    echo "✓ Snippet count: " . count
  else
    echo "✗ No snippets loaded"
  endif
endfunction

" Run all tests
function! Test_run_all() abort
  echo "Running snippet command tests..."
  echo ""
  
  call Test_snippet_availability()
  call Test_snippet_count()
  call Test_snippet_list_command()
  call Test_snippet_help_command()
  call Test_snippet_expand_command()
  call Test_snippet_error_handling()
  
  echo ""
  echo "Tests complete"
endfunction

" Run tests if this file is executed directly
if exists('v:progname') && v:progname =~? 'nvim'
  call Test_run_all()
endif
