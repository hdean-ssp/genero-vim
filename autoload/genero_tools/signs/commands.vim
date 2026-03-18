" Genero-Tools Plugin - Sign Column Commands
" Provides user commands for managing unified signs

" Register sign commands
function! genero_tools#signs#commands#register() abort
  " Enable unified signs
  command! GeneroUnifiedSignsEnable call genero_tools#signs#enable_unified()
  
  " Disable unified signs
  command! GeneroUnifiedSignsDisable call genero_tools#signs#disable_unified()
  
  " Toggle unified signs
  command! GeneroUnifiedSignsToggle call genero_tools#signs#toggle_unified()
  
  " Show unified signs status
  command! GeneroUnifiedSignsStatus call genero_tools#signs#commands#show_status()
endfunction

" Show current unified signs status
function! genero_tools#signs#commands#show_status() abort
  let status = genero_tools#signs#get_unified_status()
  
  if status
    echo "Unified signs: ENABLED"
  else
    echo "Unified signs: DISABLED"
  endif
  
  echo "Compiler signs: " . (genero_tools#config#get('compiler_signs_enabled') ? 'enabled' : 'disabled')
  echo "SVN signs: " . (genero_tools#config#get('svn_signs_enabled') ? 'enabled' : 'disabled')
endfunction
