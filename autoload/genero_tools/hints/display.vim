" Genero-Tools Plugin - Hint Display System
" Renders hints in the editor using signs and/or virtual text

" Initialize display system
function! genero_tools#hints#display#init() abort
  " Define hint signs
  call sign_define('GeneroHintInfo', {
    \ 'text': '◆',
    \ 'texthl': 'GeneroHintInfo'
    \ })
  
  call sign_define('GeneroHintWarning', {
    \ 'text': '◆',
    \ 'texthl': 'GeneroHintWarning'
    \ })
  
  call sign_define('GeneroHintStyle', {
    \ 'text': '◆',
    \ 'texthl': 'GeneroHintStyle'
    \ })
  
  " Define highlight groups
  if !hlexists('GeneroHintInfo')
    highlight GeneroHintInfo ctermfg=Blue guifg=#0087FF
  endif
  
  if !hlexists('GeneroHintWarning')
    highlight GeneroHintWarning ctermfg=Yellow guifg=#FFFF00
  endif
  
  if !hlexists('GeneroHintStyle')
    highlight GeneroHintStyle ctermfg=Cyan guifg=#00FFFF
  endif
endfunction

" Display hints for a buffer
function! genero_tools#hints#display#show(bufnr, hints) abort
  let bufnr = a:bufnr > 0 ? a:bufnr : bufnr('%')
  
  " Clear existing hints
  call genero_tools#hints#display#clear(bufnr)
  
  if empty(a:hints)
    return
  endif
  
  let display_mode = genero_tools#hints#config#get('hints_display')
  
  " Display hints based on configured mode
  if display_mode == 'signs' || display_mode == 'both'
    call genero_tools#hints#display#show_signs(bufnr, a:hints)
  endif
  
  if display_mode == 'virtual_text' || display_mode == 'both'
    if has('nvim')
      call genero_tools#hints#display#show_virtual_text(bufnr, a:hints)
    endif
  endif
endfunction

" Display hints as signs in sign column
function! genero_tools#hints#display#show_signs(bufnr, hints) abort
  for hint in a:hints
    let sign_name = genero_tools#hints#display#get_sign_name(hint.severity)
    
    try
      call sign_place(0, 'GeneroHints', sign_name, a:bufnr, {
        \ 'lnum': hint.line
        \ })
    catch
      " Silently ignore sign placement errors
    endtry
  endfor
endfunction

" Display hints as virtual text (Neovim only)
function! genero_tools#hints#display#show_virtual_text(bufnr, hints) abort
  if !has('nvim')
    return
  endif
  
  " Get or create namespace for hints
  let ns_id = nvim_create_namespace('genero_hints')
  
  for hint in a:hints
    let hl_group = genero_tools#hints#display#get_highlight_group(hint.severity)
    
    try
      call nvim_buf_set_extmark(a:bufnr, ns_id, hint.line - 1, 0, {
        \ 'virt_text': [[hint.message, hl_group]],
        \ 'virt_text_pos': 'eol'
        \ })
    catch
      " Silently ignore extmark errors
    endtry
  endfor
endfunction

" Clear all hints for a buffer
function! genero_tools#hints#display#clear(bufnr) abort
  let bufnr = a:bufnr > 0 ? a:bufnr : bufnr('%')
  
  " Clear signs
  try
    call sign_unplace('GeneroHints', { 'buffer': bufnr })
  catch
    " Silently ignore errors
  endtry
  
  " Clear virtual text (Neovim)
  if has('nvim')
    try
      let ns_id = nvim_create_namespace('genero_hints')
      call nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)
    catch
      " Silently ignore errors
    endtry
  endif
endfunction

" Get sign name for severity level
function! genero_tools#hints#display#get_sign_name(severity) abort
  if a:severity == 'info'
    return 'GeneroHintInfo'
  elseif a:severity == 'warning'
    return 'GeneroHintWarning'
  elseif a:severity == 'style'
    return 'GeneroHintStyle'
  else
    return 'GeneroHintWarning'
  endif
endfunction

" Get highlight group for severity level
function! genero_tools#hints#display#get_highlight_group(severity) abort
  if a:severity == 'info'
    return 'GeneroHintInfo'
  elseif a:severity == 'warning'
    return 'GeneroHintWarning'
  elseif a:severity == 'style'
    return 'GeneroHintStyle'
  else
    return 'GeneroHintWarning'
  endif
endfunction

" Show hint details in popup/floating window
function! genero_tools#hints#display#show_details(hint) abort
  let lines = [
    \ 'Hint: ' . a:hint.message,
    \ 'Line: ' . a:hint.line . ', Column: ' . a:hint.column,
    \ 'Category: ' . a:hint.category,
    \ 'Check: ' . a:hint.check,
    \ 'Severity: ' . a:hint.severity
    \ ]
  
  if !empty(a:hint.auto_fix)
    call add(lines, 'Auto-fix: ' . a:hint.auto_fix.description)
  endif
  
  if has('nvim')
    " Use floating window in Neovim
    let opts = {
      \ 'relative': 'cursor',
      \ 'row': 1,
      \ 'col': 0,
      \ 'width': 60,
      \ 'height': len(lines),
      \ 'style': 'minimal',
      \ 'border': 'rounded'
      \ }
    
    let buf = nvim_create_buf(v:false, v:true)
    call nvim_buf_set_lines(buf, 0, -1, v:false, lines)
    call nvim_open_win(buf, v:false, opts)
  else
    " Use popup in Vim 8.1+
    if exists('*popup_create')
      call popup_create(lines, {
        \ 'pos': 'cursor',
        \ 'line': 'cursor+1',
        \ 'col': 'cursor',
        \ 'maxwidth': 60,
        \ 'border': [1, 1, 1, 1]
        \ })
    else
      " Fallback: echo to command line
      call genero_tools#display#echo(join(lines, ' | '))
    endif
  endif
endfunction

" Refresh display after configuration change
function! genero_tools#hints#display#refresh() abort
  let bufnr = bufnr('%')
  let hints = genero_tools#hints#get_hints(bufnr)
  call genero_tools#hints#display#show(bufnr, hints)
endfunction
