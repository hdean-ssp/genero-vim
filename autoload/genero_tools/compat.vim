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
function! genero_tools#compat#get_supported_display_modes() abort
  if genero_tools#compat#is_neovim()
    return ['quickfix', 'popup', 'inline', 'split', 'echo']
  else
    " Vim supports all modes except popup (uses inline instead)
    return ['quickfix', 'inline', 'split', 'echo']
  endif
endfunction

" Validate and fallback display mode if needed
function! genero_tools#compat#validate_display_mode(mode) abort
  let supported = genero_tools#compat#get_supported_display_modes()
  
  if index(supported, a:mode) >= 0
    return a:mode
  endif
  
  " Fallback logic
  if a:mode == 'popup' && genero_tools#compat#is_vim()
    return 'inline'
  endif
  
  " Default fallback
  return 'echo'
endfunction

" Check if display mode is available
function! genero_tools#compat#is_display_mode_available(mode) abort
  let supported = genero_tools#compat#get_supported_display_modes()
  return index(supported, a:mode) >= 0
endfunction
