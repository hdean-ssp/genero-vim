" Genero-Tools Plugin - Hint Display System
" Renders hints in the editor using signs and/or virtual text

" Initialize display system
function! genero_tools#hints#display#init() abort
  " Define hint signs — small diamond, unobtrusive
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
  
  " Sign column highlight groups (just the diamond icon color, no background)
  if !hlexists('GeneroHintInfo')
    highlight GeneroHintInfo ctermfg=Blue ctermbg=NONE guifg=#5c7aaa guibg=NONE
  endif
  
  if !hlexists('GeneroHintWarning')
    highlight GeneroHintWarning ctermfg=Yellow ctermbg=NONE guifg=#a08050 guibg=NONE
  endif
  
  if !hlexists('GeneroHintStyle')
    highlight GeneroHintStyle ctermfg=Gray ctermbg=NONE guifg=#555555 guibg=NONE
  endif
  
  " Virtual text highlight groups — subtle italic with faint background tint
  " Just enough bg to lift the text slightly off the editor background
  if !hlexists('GeneroHintInfoVirtual')
    highlight GeneroHintInfoVirtual ctermfg=DarkBlue ctermbg=234 guifg=#4a6a8a guibg=#1e2030 gui=italic
  endif
  
  if !hlexists('GeneroHintWarningVirtual')
    highlight GeneroHintWarningVirtual ctermfg=DarkYellow ctermbg=234 guifg=#8a7a50 guibg=#1e2030 gui=italic
  endif
  
  if !hlexists('GeneroHintStyleVirtual')
    highlight GeneroHintStyleVirtual ctermfg=DarkGray ctermbg=234 guifg=#555555 guibg=#1e2030 gui=italic
  endif
  
  " Set up CursorMoved autocommand for current-line-only mode
  call genero_tools#hints#display#setup_cursor_autocmd()
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
  
  " Signs always show for all lines (they're small and unobtrusive)
  if display_mode == 'signs' || display_mode == 'both'
    call genero_tools#hints#display#show_signs(bufnr, a:hints)
  endif
  
  " Virtual text: respect current-line-only setting
  if display_mode == 'virtual_text' || display_mode == 'both'
    if has('nvim')
      if genero_tools#hints#config#get('hints_current_line_only')
        " Only show virtual text for the current cursor line
        call genero_tools#hints#display#show_virtual_text_for_line(bufnr, a:hints, line('.'))
      else
        call genero_tools#hints#display#show_virtual_text(bufnr, a:hints)
      endif
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
  
  " Highlight columns if enabled
  if genero_tools#hints#config#get('hints_highlight_columns')
    call genero_tools#hints#display#highlight_columns(a:bufnr, a:hints)
  endif
endfunction

" Highlight columns where hints are located
function! genero_tools#hints#display#highlight_columns(bufnr, hints) abort
  if !has('nvim')
    return
  endif
  
  let ns_id = nvim_create_namespace('genero_hints_columns')
  
  for hint in a:hints
    let hl_group = 'GeneroHint' . toupper(hint.severity[0]) . hint.severity[1:]
    
    try
      " Highlight from hint column to end of line (or a reasonable length)
      let col_start = hint.column - 1
      let col_end = min([col_start + 20, 200])  " Highlight up to 20 chars or end of line
      
      call nvim_buf_set_extmark(a:bufnr, ns_id, hint.line - 1, col_start, {
        \ 'end_col': col_end,
        \ 'hl_group': hl_group,
        \ 'priority': 100
        \ })
    catch
      " Silently ignore extmark errors
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
    let hl_group = genero_tools#hints#display#get_virtual_text_highlight_group(hint.severity)
    
    try
      call nvim_buf_set_extmark(a:bufnr, ns_id, hint.line - 1, 0, {
        \ 'virt_text': [['  ▸ ' . hint.message . ' ', hl_group]],
        \ 'virt_text_pos': 'eol',
        \ 'priority': 50
        \ })
    catch
      " Silently ignore extmark errors
    endtry
  endfor
endfunction

" Display virtual text for a single line only (current-line-only mode)
function! genero_tools#hints#display#show_virtual_text_for_line(bufnr, hints, current_line) abort
  if !has('nvim')
    return
  endif
  
  let ns_id = nvim_create_namespace('genero_hints')
  
  " Clear existing virtual text (but not signs)
  call nvim_buf_clear_namespace(a:bufnr, ns_id, 0, -1)
  
  " Only place virtual text for hints on the current line
  for hint in a:hints
    if hint.line == a:current_line
      let hl_group = genero_tools#hints#display#get_virtual_text_highlight_group(hint.severity)
      
      try
        call nvim_buf_set_extmark(a:bufnr, ns_id, hint.line - 1, 0, {
          \ 'virt_text': [['  ▸ ' . hint.message . ' ', hl_group]],
          \ 'virt_text_pos': 'eol',
          \ 'priority': 50
          \ })
      catch
      endtry
    endif
  endfor
endfunction

" Setup CursorMoved autocommand for current-line-only virtual text
" NOTE: Autocommands are now handled by the unified cursor dispatcher (cursor.vim)
function! genero_tools#hints#display#setup_cursor_autocmd() abort
  " No-op — cursor.vim handles the dispatch
endfunction

" Called by cursor dispatcher when line changes
function! genero_tools#hints#display#on_line_changed(bufnr, current_line) abort
  let display_mode = genero_tools#hints#config#get('hints_display')
  if display_mode != 'virtual_text' && display_mode != 'both'
    return
  endif
  
  if !genero_tools#hints#config#get('hints_current_line_only')
    return
  endif
  
  let hints = genero_tools#hints#get_hints(a:bufnr)
  if empty(hints)
    return
  endif
  
  call genero_tools#hints#display#show_virtual_text_for_line(a:bufnr, hints, a:current_line)
endfunction

" Legacy handler — kept for backward compatibility
function! genero_tools#hints#display#on_cursor_moved() abort
  if !has('nvim')
    return
  endif
  call genero_tools#hints#display#on_line_changed(bufnr('%'), line('.'))
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
  
  " Clear column highlights (Neovim)
  if has('nvim')
    try
      let ns_id = nvim_create_namespace('genero_hints_columns')
      call nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)
    catch
      " Silently ignore errors
    endtry
  endif
  
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

" Get virtual text highlight group for severity level (more subtle)
function! genero_tools#hints#display#get_virtual_text_highlight_group(severity) abort
  if a:severity == 'info'
    return 'GeneroHintInfoVirtual'
  elseif a:severity == 'warning'
    return 'GeneroHintWarningVirtual'
  elseif a:severity == 'style'
    return 'GeneroHintStyleVirtual'
  else
    return 'GeneroHintWarningVirtual'
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
    " Position just above the cursor line for better visibility
    let opts = {
      \ 'relative': 'cursor',
      \ 'row': -len(lines) - 1,
      \ 'col': 0,
      \ 'width': 60,
      \ 'height': len(lines),
      \ 'style': 'minimal',
      \ 'border': 'rounded',
      \ 'anchor': 'SW'
      \ }
    
    let buf = nvim_create_buf(v:false, v:true)
    call nvim_buf_set_lines(buf, 0, -1, v:false, lines)
    call nvim_open_win(buf, v:false, opts)
  else
    " Use popup in Vim 8.1+
    if exists('*popup_create')
      call popup_create(lines, {
        \ 'pos': 'cursor',
        \ 'line': 'cursor-' . len(lines),
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

" Highlight a specific hint (used for navigation)
function! genero_tools#hints#display#highlight_hint(hint) abort
  if !has('nvim')
    return
  endif
  
  " Create a temporary namespace for highlighting the current hint
  let ns_id = nvim_create_namespace('genero_hints_current')
  
  " Clear previous highlight
  call nvim_buf_clear_namespace(bufnr('%'), ns_id, 0, -1)
  
  " Get highlight group based on severity
  let hl_group = genero_tools#hints#display#get_highlight_group(a:hint.severity)
  
  try
    " Highlight the entire line where the hint is
    call nvim_buf_set_extmark(bufnr('%'), ns_id, a:hint.line - 1, 0, {
      \ 'end_col': -1,
      \ 'hl_group': hl_group,
      \ 'priority': 200
      \ })
  catch
    " Silently ignore errors
  endtry
  
  " Show hint details in popup
  call genero_tools#hints#display#show_details(a:hint)
endfunction
