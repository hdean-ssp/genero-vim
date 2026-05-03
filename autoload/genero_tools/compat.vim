" Genero-Tools Plugin - Vim/Neovim Compatibility

" Check if running in neovim
function! genero_tools#compat#is_neovim() abort
  return has('nvim')
endfunction

" Check if running in vim
function! genero_tools#compat#is_vim() abort
  return !has('nvim')
endfunction

" Get supported display modes for current editor
" Canonical modes: quickfix, floating (Neovim only), echo
function! genero_tools#compat#get_supported_display_modes() abort
  if genero_tools#compat#is_neovim()
    return ['quickfix', 'floating', 'echo']
  else
    return ['quickfix', 'echo']
  endif
endfunction

" Normalize display mode: validate against canonical modes
function! genero_tools#compat#normalize_display_mode(mode) abort
  if a:mode == 'floating'
    if genero_tools#compat#is_neovim()
      return 'floating'
    else
      return 'echo'
    endif
  endif
  
  if a:mode == 'quickfix' || a:mode == 'echo'
    return a:mode
  endif
  
  " Unknown mode — fall back to echo
  return 'echo'
endfunction

" Validate and fallback display mode if needed
function! genero_tools#compat#validate_display_mode(mode) abort
  return genero_tools#compat#normalize_display_mode(a:mode)
endfunction

" Check if display mode is available
function! genero_tools#compat#is_display_mode_available(mode) abort
  let normalized = genero_tools#compat#normalize_display_mode(a:mode)
  let supported = genero_tools#compat#get_supported_display_modes()
  return index(supported, normalized) >= 0
endfunction
