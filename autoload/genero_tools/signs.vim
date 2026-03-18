" Genero-Tools Plugin - Unified Sign Column Management
" Manages both compiler diagnostics and SVN diff signs in the sign column
" Supports combined signs to reduce screen real estate

" Sign combination cache: maps (line, compiler_sign, svn_sign) -> combined_sign_name
let s:sign_cache = {}

" Global state for unified signs
let g:genero_tools_unified_signs_enabled = get(g:, 'genero_tools_unified_signs_enabled', 0)

" Initialize unified sign system
function! genero_tools#signs#init() abort
  " Initialize both subsystems
  call genero_tools#compiler#signs#init()
  call genero_tools#svn#signs#init()
endfunction

" Get combined sign name for a line with both compiler and SVN signs
" Arguments:
"   compiler_sign - compiler sign name (or empty string)
"   svn_sign - SVN sign name (or empty string)
" Returns: combined sign name
function! genero_tools#signs#get_combined_sign(compiler_sign, svn_sign) abort
  " If only one type of sign, use it directly
  if empty(a:compiler_sign)
    return a:svn_sign
  endif
  if empty(a:svn_sign)
    return a:compiler_sign
  endif
  
  " Both signs present - create combined sign
  let cache_key = a:compiler_sign . '|' . a:svn_sign
  
  if has_key(s:sign_cache, cache_key)
    return s:sign_cache[cache_key]
  endif
  
  " Create new combined sign
  let combined_name = 'GeneroCombo_' . len(s:sign_cache)
  let s:sign_cache[cache_key] = combined_name
  
  " Get text and highlight from component signs
  let compiler_text = genero_tools#signs#get_sign_text(a:compiler_sign)
  let svn_text = genero_tools#signs#get_sign_text(a:svn_sign)
  let compiler_hl = genero_tools#signs#get_sign_highlight(a:compiler_sign)
  let svn_hl = genero_tools#signs#get_sign_highlight(a:svn_sign)
  
  " Create combined text with pipe separator
  let combined_text = compiler_text . '|' . svn_text
  
  " Use compiler highlight as primary (errors take precedence)
  let combined_hl = !empty(compiler_hl) ? compiler_hl : svn_hl
  
  " Define the combined sign
  try
    execute 'sign define ' . combined_name . ' text=' . combined_text . ' texthl=' . combined_hl
  catch
    " Fallback if sign definition fails
    return a:compiler_sign
  endtry
  
  return combined_name
endfunction

" Get the text of a sign definition
function! genero_tools#signs#get_sign_text(sign_name) abort
  if empty(a:sign_name)
    return ''
  endif
  
  " Map known signs to their text representations
  let sign_map = {
    \ 'GeneroCompilerError': '✕',
    \ 'GeneroCompilerWarning': '⚠',
    \ 'GeneroCompilerInfo': 'ℹ',
    \ 'GeneroSVNAdded': '+',
    \ 'GeneroSVNModified': '~',
    \ 'GeneroSVNDeleted': '-'
    \ }
  
  return get(sign_map, a:sign_name, '?')
endfunction

" Get the highlight group of a sign definition
function! genero_tools#signs#get_sign_highlight(sign_name) abort
  if empty(a:sign_name)
    return ''
  endif
  
  " Map known signs to their highlight groups
  let hl_map = {
    \ 'GeneroCompilerError': 'ErrorMsg',
    \ 'GeneroCompilerWarning': 'WarningMsg',
    \ 'GeneroCompilerInfo': 'InfoMsg',
    \ 'GeneroSVNAdded': 'GeneroSVNAdded',
    \ 'GeneroSVNModified': 'GeneroSVNModified',
    \ 'GeneroSVNDeleted': 'GeneroSVNDeleted'
    \ }
  
  return get(hl_map, a:sign_name, '')
endfunction

" Place combined signs for a buffer
" Arguments:
"   bufnr - buffer number
"   compiler_signs - dict mapping line_num -> sign_name
"   svn_signs - dict mapping line_num -> sign_name
function! genero_tools#signs#place_combined(bufnr, compiler_signs, svn_signs) abort
  " Clear existing combined signs
  try
    execute 'sign unplace * group=genero_combined buffer=' . a:bufnr
  catch
  endtry
  
  let sign_id = 1
  let all_lines = {}
  
  " Collect all lines that have either type of sign
  for line_num in keys(a:compiler_signs)
    let all_lines[line_num] = 1
  endfor
  for line_num in keys(a:svn_signs)
    let all_lines[line_num] = 1
  endfor
  
  " Place combined signs
  for line_num in sort(keys(all_lines), 'N')
    let compiler_sign = get(a:compiler_signs, line_num, '')
    let svn_sign = get(a:svn_signs, line_num, '')
    
    let combined_sign = genero_tools#signs#get_combined_sign(compiler_sign, svn_sign)
    
    if !empty(combined_sign)
      try
        execute 'sign place ' . sign_id . ' group=genero_combined line=' . line_num . 
              \ ' name=' . combined_sign . 
              \ ' buffer=' . a:bufnr
        let sign_id += 1
      catch
        " Silently ignore if sign placement fails
      endtry
    endif
  endfor
endfunction

" Clear all combined signs for a buffer
function! genero_tools#signs#clear_combined(bufnr) abort
  try
    execute 'sign unplace * group=genero_combined buffer=' . a:bufnr
  catch
  endtry
endfunction

" Clear all combined signs globally
function! genero_tools#signs#clear_combined_all() abort
  try
    execute 'sign unplace * group=genero_combined'
  catch
  endtry
endfunction

" Enable unified signs globally
function! genero_tools#signs#enable_unified() abort
  let g:genero_tools_unified_signs_enabled = 1
  echo "Unified signs enabled"
endfunction

" Disable unified signs globally
function! genero_tools#signs#disable_unified() abort
  let g:genero_tools_unified_signs_enabled = 0
  call genero_tools#signs#clear_combined_all()
  echo "Unified signs disabled"
endfunction

" Toggle unified signs
function! genero_tools#signs#toggle_unified() abort
  if g:genero_tools_unified_signs_enabled
    call genero_tools#signs#disable_unified()
  else
    call genero_tools#signs#enable_unified()
  endif
endfunction

" Get unified signs status
function! genero_tools#signs#get_unified_status() abort
  return g:genero_tools_unified_signs_enabled
endfunction
