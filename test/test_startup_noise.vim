" Test for Task 21: E1.2 - Reduce Startup Noise
" Verifies that startup messages are controlled by startup_messages config

function! Test_startup_messages_silent() abort
  " Test that silent mode suppresses messages
  let g:genero_tools_config = {}
  let g:genero_tools_config.startup_messages = 'silent'
  let g:genero_tools_config.compiler_enabled = v:true
  let g:genero_tools_config.compiler_autocompile = v:false
  
  " Capture messages
  let messages_before = execute('messages')
  
  " Call enable function
  call genero_tools#compiler#autocompile#enable()
  
  let messages_after = execute('messages')
  
  " In silent mode, no new messages should appear
  if messages_before == messages_after
    echo '✓ Silent mode suppresses autocompile enable message'
  else
    echo '✗ Silent mode failed - messages were displayed'
    echo 'Before: ' . messages_before
    echo 'After: ' . messages_after
  endif
endfunction

function! Test_startup_messages_verbose() abort
  " Test that verbose mode shows messages
  let g:genero_tools_config = {}
  let g:genero_tools_config.startup_messages = 'verbose'
  let g:genero_tools_config.compiler_enabled = v:true
  let g:genero_tools_config.compiler_autocompile = v:false
  
  " Capture messages
  let messages_before = execute('messages')
  
  " Call enable function
  call genero_tools#compiler#autocompile#enable()
  
  let messages_after = execute('messages')
  
  " In verbose mode, messages should appear
  if messages_before != messages_after
    echo '✓ Verbose mode shows autocompile enable message'
  else
    echo '✗ Verbose mode failed - no messages were displayed'
  endif
endfunction

function! Test_startup_messages_normal() abort
  " Test that normal mode shows messages (same as verbose for now)
  let g:genero_tools_config = {}
  let g:genero_tools_config.startup_messages = 'normal'
  let g:genero_tools_config.compiler_enabled = v:true
  let g:genero_tools_config.compiler_autocompile = v:false
  
  " Capture messages
  let messages_before = execute('messages')
  
  " Call enable function
  call genero_tools#compiler#autocompile#enable()
  
  let messages_after = execute('messages')
  
  " In normal mode, messages should appear
  if messages_before != messages_after
    echo '✓ Normal mode shows autocompile enable message'
  else
    echo '✗ Normal mode failed - no messages were displayed'
  endif
endfunction

function! Test_config_default_silent() abort
  " Test that default config is silent
  let g:genero_tools_config = {}
  call genero_tools#config#init()
  
  let startup_mode = genero_tools#config#get('startup_messages')
  if startup_mode == 'silent'
    echo '✓ Default startup_messages is silent'
  else
    echo '✗ Default startup_messages is not silent: ' . startup_mode
  endif
endfunction

function! Test_disable_respects_startup_messages() abort
  " Test that disable also respects startup_messages
  let g:genero_tools_config = {}
  let g:genero_tools_config.startup_messages = 'silent'
  
  " Capture messages
  let messages_before = execute('messages')
  
  " Call disable function
  call genero_tools#compiler#autocompile#disable()
  
  let messages_after = execute('messages')
  
  " In silent mode, no new messages should appear
  if messages_before == messages_after
    echo '✓ Silent mode suppresses autocompile disable message'
  else
    echo '✗ Silent mode failed for disable - messages were displayed'
  endif
endfunction

" Run all tests
try
  echo "Running startup noise tests..."
  echo ""
  
  call Test_config_default_silent()
  call Test_startup_messages_silent()
  call Test_startup_messages_verbose()
  call Test_startup_messages_normal()
  call Test_disable_respects_startup_messages()
  
  echo ""
  echo "✓ All startup noise tests completed"
catch
  echo "✗ Test failed: " . v:exception
endtry
