" Genero-Tools Plugin - Vim/Neovim Compatibility

" Check if running in neovim
function! genero_tools#compat#is_neovim() abort
  return has('nvim')
endfunction

" Check if running in vim
function! genero_tools#compat#is_vim() abort
  return !has('nvim')
endfunction

" Track whether deprecation warning has been shown (once per session)
let s:deprecation_warned = {}

" Get supported display modes for current editor
" Canonical modes: quickfix, floating (Neovim only), echo
" Legacy modes still accepted but normalized: popup, inline, split
function! genero_tools#compat#get_supported_display_modes() abort
  if genero_tools#compat#is_neovim()
    return ['quickfix', 'floating', 'echo']
  else
    return ['quickfix', 'echo']
  endif
endfunction

" Normalize display mode: map legacy names to canonical names
" popup -> floating, inline -> floating, split -> floating
function! genero_tools#compat#normalize_display_mode(mode) abort
  " Legacy mode mapping with one-time deprecation notice
  if a:mode == 'popup' || a:mode == 'inline' || a:mode == 'split'
    if !has_key(s:deprecation_warned, a:mode)
      let s:deprecation_warned[a:mode] = 1
      if genero_tools#config#get('debug_mode')
        echom '[compat] Display mode "' . a:mode . '" is deprecated. Use "floating" (Neovim) or "echo" (Vim) instead.'
      endif
    endif
    if genero_tools#compat#is_neovim()
      return 'floating'
    else
      return 'echo'
    endif
  endif
  
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
