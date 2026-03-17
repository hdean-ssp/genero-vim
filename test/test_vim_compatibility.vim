" Test Vim compatibility for snippet features
" Ensures that Neovim-only features are properly disabled in Vim

" Test 7.1: Vim feature detection
function! Test_vim_feature_detection() abort
  if has('nvim')
    echo "✓ Running on Neovim"
  else
    echo "✓ Running on Vim"
  endif
endfunction

" Test 7.2: Snippet commands disabled in Vim
function! Test_snippet_commands_disabled_in_vim() abort
  if !has('nvim')
    " In Vim, snippet commands should not be registered
    " Try to call them - they should either not exist or handle gracefully
    try
      call genero_tools#snippets#list()
      echo "✓ Snippet list command handled gracefully in Vim"
    catch /E117/
      " Command not found - this is expected in Vim
      echo "✓ Snippet list command not registered in Vim"
    catch
      " Any other error - check if it's the Neovim-only message
      if v:exception =~? 'neovim-only'
        echo "✓ Snippet list command shows Neovim-only message in Vim"
      else
        echo "✗ Unexpected error: " . v:exception
      endif
    endtry
  else
    echo "✓ Running on Neovim - snippet commands available"
  endif
endfunction

" Test 7.3: Verify no errors in Vim
function! Test_no_errors_in_vim() abort
  " Verify plugin loaded without errors
  if exists('g:loaded_genero_tools')
    echo "✓ Plugin loaded successfully"
  else
    echo "✗ Plugin failed to load"
  endif
  
  " Verify existing genero-tools features work
  if exists(':GeneroLookup')
    echo "✓ GeneroLookup command available"
  else
    echo "✗ GeneroLookup command not available"
  endif
  
  if exists(':GeneroCompile')
    echo "✓ GeneroCompile command available"
  else
    echo "✗ GeneroCompile command not available"
  endif
endfunction

" Test snippet availability check
function! Test_snippet_availability_check() abort
  let available = genero_tools#snippets#available()
  
  if has('nvim')
    echo "✓ Neovim - snippet availability: " . available
  else
    if available == 0
      echo "✓ Vim - snippets correctly unavailable"
    else
      echo "✗ Vim - snippets should not be available"
    endif
  endif
endfunction

" Test snippet count in Vim
function! Test_snippet_count_in_vim() abort
  let count = genero_tools#snippets#get_count()
  
  if has('nvim')
    echo "✓ Neovim - snippet count: " . count
  else
    if count == 0
      echo "✓ Vim - snippet count correctly 0"
    else
      echo "✗ Vim - snippet count should be 0"
    endif
  endif
endfunction

" Run all tests
function! Test_run_all() abort
  echo "Running Vim compatibility tests..."
  echo ""
  
  call Test_vim_feature_detection()
  echo ""
  
  call Test_no_errors_in_vim()
  echo ""
  
  call Test_snippet_availability_check()
  call Test_snippet_count_in_vim()
  echo ""
  
  call Test_snippet_commands_disabled_in_vim()
  
  echo ""
  echo "Vim compatibility tests complete"
endfunction

" Run tests if this file is executed directly
if exists('v:progname') && (v:progname =~? 'nvim' || v:progname =~? 'vim')
  call Test_run_all()
endif
