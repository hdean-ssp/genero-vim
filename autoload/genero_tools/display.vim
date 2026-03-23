" Genero-Tools Plugin - Display Modes

" Check if formatted content has meaningful data (not just whitespace)
function! genero_tools#display#has_content(formatted) abort
  if empty(a:formatted)
    return 0
  endif
  
  for line in a:formatted
    if line !~# '^\s*$'
      return 1
    endif
  endfor
  
  return 0
endfunction

" Main display dispatcher
function! genero_tools#display#result(result, display_mode) abort
  if a:result.success
    let formatted = genero_tools#display#format_success(a:result.data)
  else
    let formatted = genero_tools#display#format_error(a:result.error)
  endif
  
  " Don't display if there's no meaningful content
  if !genero_tools#display#has_content(formatted)
    return
  endif
  
  " Check result size and enable pagination if needed (Requirement 17.1)
  let result_limit = genero_tools#config#get('result_limit')
  if type(a:result.data) == type([]) && len(a:result.data) > result_limit
    call genero_tools#display#echo('Warning: Result set exceeds limit (' . len(a:result.data) . ' results)')
    call genero_tools#display#echo('Suggestion: Narrow your search criteria or use pagination')
    call genero_tools#display#echo('Examples: Use more specific terms, filter by module, or increase result_limit')
    let formatted = formatted[0:result_limit-1]
  endif
  
  " Validate and fallback display mode if needed
  let display_mode = genero_tools#compat#validate_display_mode(a:display_mode)
  
  " Route to appropriate display mode
  if display_mode == 'quickfix'
    call genero_tools#display#quickfix(formatted, a:result)
  elseif display_mode == 'popup'
    call genero_tools#display#popup(formatted)
  elseif display_mode == 'inline'
    call genero_tools#display#inline(formatted)
  elseif display_mode == 'split'
    call genero_tools#display#split(formatted)
  else
    call genero_tools#display#echo(join(formatted, "\n"))
  endif
endfunction

" Display in quickfix list
function! genero_tools#display#quickfix(formatted, result) abort
  let qf_list = []
  
  if a:result.success && type(a:result.data) == type([])
    for item in a:result.data
      if type(item) == type({}) && has_key(item, 'file') && has_key(item, 'line')
        call add(qf_list, {
          \ 'filename': item.file,
          \ 'lnum': item.line,
          \ 'text': get(item, 'name', '') . ' - ' . get(item, 'signature', '')
          \ })
      endif
    endfor
  endif
  
  if empty(qf_list)
    call add(qf_list, {'text': join(a:formatted, "\n")})
  endif
  
  call setqflist(qf_list)
  silent! copen
endfunction

" Display in popup window (neovim only - large floating window)
function! genero_tools#display#popup(formatted) abort
  if !has('nvim')
    call genero_tools#display#echo(join(a:formatted, "\n"))
    return
  endif
  
  " Don't display if there's no content
  if empty(a:formatted)
    return
  endif
  
  " Check if all lines are just whitespace
  let has_content = 0
  for line in a:formatted
    if line !~# '^\s*$'
      let has_content = 1
      break
    endif
  endfor
  
  if !has_content
    return
  endif
  
  try
    " Create popup buffer
    let buf = nvim_create_buf(v:false, v:true)
    call nvim_buf_set_lines(buf, 0, -1, v:false, a:formatted)
    
    " Get configuration values
    let width = genero_tools#config#get('floating_window_width')
    let height = genero_tools#config#get('floating_window_height')
    let border = genero_tools#config#get('floating_window_border')
    let title = genero_tools#config#get('floating_window_title')
    let position = genero_tools#config#get('floating_window_position')
    
    " Calculate dimensions based on content if needed
    let max_line_width = 0
    for line in a:formatted
      let max_line_width = max([max_line_width, len(line)])
    endfor
    let width = min([max([width, max_line_width + 2], 40), &columns - 4])
    let height = min([max([height, len(a:formatted) + 2], 5), &lines - 4])
    
    " Calculate position
    if position == 'center'
      let row = (&lines - height) / 2
      let col = (&columns - width) / 2
      let anchor = 'NW'
    elseif position == 'top'
      let row = 1
      let col = (&columns - width) / 2
      let anchor = 'NW'
    elseif position == 'bottom'
      let row = &lines - height - 1
      let col = (&columns - width) / 2
      let anchor = 'NW'
    else " cursor
      let row = 1
      let col = 0
      let anchor = 'NW'
    endif
    
    " Create popup window
    let opts = {
      \ 'relative': 'editor',
      \ 'width': width,
      \ 'height': height,
      \ 'col': col,
      \ 'row': row,
      \ 'anchor': anchor,
      \ 'style': 'minimal',
      \ 'border': border,
      \ 'title': title,
      \ 'title_pos': 'center'
      \ }
    
    call nvim_open_win(buf, v:true, opts)
  catch
    " Fallback to echo if popup fails
    call genero_tools#display#echo(join(a:formatted, "\n"))
  endtry
endfunction

" Display in split window
function! genero_tools#display#split(formatted) abort
  " Create new split
  new
  
  " Set buffer content
  call append(0, a:formatted)
  
  " Set buffer options
  setlocal buftype=nofile
  setlocal bufhidden=wipe
  setlocal noswapfile
  setlocal nomodifiable
endfunction

" Display in command line (echo)
function! genero_tools#display#echo(text) abort
  echo a:text
endfunction

" Format successful result
function! genero_tools#display#format_success(data) abort
  if type(a:data) == type([])
    if empty(a:data)
      return ['No results found']
    endif
    let lines = []
    for item in a:data
      if type(item) == type({})
        call add(lines, genero_tools#display#format_item(item))
      else
        call add(lines, string(item))
      endif
    endfor
    return lines
  elseif type(a:data) == type({})
    if empty(a:data)
      return ['No results found']
    endif
    return [genero_tools#display#format_item(a:data)]
  else
    return [string(a:data)]
  endif
endfunction

" Format error message
function! genero_tools#display#format_error(error) abort
  return ['Error: ' . a:error]
endfunction

" Format individual item
function! genero_tools#display#format_item(item) abort
  let parts = []
  
  if type(a:item) == type({})
    if has_key(a:item, 'name')
      call add(parts, a:item.name)
    endif
    
    if has_key(a:item, 'file')
      call add(parts, 'File: ' . a:item.file)
    endif
    
    if has_key(a:item, 'line_start')
      call add(parts, 'Line: ' . a:item.line_start)
    elseif has_key(a:item, 'line')
      call add(parts, 'Line: ' . a:item.line)
    endif
    
    if has_key(a:item, 'signature')
      call add(parts, 'Signature: ' . a:item.signature)
    endif
    
    if has_key(a:item, 'parameters') && !empty(a:item.parameters)
      let param_strs = []
      for param in a:item.parameters
        if type(param) == type({}) && has_key(param, 'name')
          call add(param_strs, param.name . ':' . get(param, 'type', 'unknown'))
        else
          call add(param_strs, string(param))
        endif
      endfor
      call add(parts, 'Parameters: ' . join(param_strs, ', '))
    endif
    
    if has_key(a:item, 'returns') && !empty(a:item.returns)
      let return_strs = []
      for ret in a:item.returns
        if type(ret) == type({}) && has_key(ret, 'name')
          call add(return_strs, ret.name . ':' . get(ret, 'type', 'unknown'))
        else
          call add(return_strs, string(ret))
        endif
      endfor
      call add(parts, 'Returns: ' . join(return_strs, ', '))
    endif
    
    if has_key(a:item, 'calls') && !empty(a:item.calls)
      let call_count = len(a:item.calls)
      call add(parts, 'Calls: ' . call_count . ' function(s)')
    endif
    
    if has_key(a:item, 'module')
      call add(parts, 'Module: ' . a:item.module)
    endif
  else
    call add(parts, string(a:item))
  endif
  
  return join(parts, ' | ')
endfunction


" Display inline popup above cursor (works in both vim and neovim)
function! genero_tools#display#inline(formatted) abort
  " Don't display if there's no content
  if empty(a:formatted)
    return
  endif
  
  " Check if all lines are just whitespace
  let has_content = 0
  for line in a:formatted
    if line !~# '^\s*$'
      let has_content = 1
      break
    endif
  endfor
  
  if !has_content
    return
  endif
  
  " Limit to first few lines for inline display
  let max_lines = 5
  let display_lines = a:formatted[0:max_lines-1]
  
  if genero_tools#compat#is_neovim()
    call genero_tools#display#inline_neovim(display_lines)
  else
    call genero_tools#display#inline_vim(display_lines)
  endif
endfunction

" Inline popup for Neovim using floating window
function! genero_tools#display#inline_neovim(lines) abort
  if !has('nvim')
    call genero_tools#display#inline_vim(a:lines)
    return
  endif
  
  try
    " Create popup buffer
    let buf = nvim_create_buf(v:false, v:true)
    call nvim_buf_set_lines(buf, 0, -1, v:false, a:lines)
    
    " Get configuration values
    let border = genero_tools#config#get('floating_window_border')
    let auto_close_delay = genero_tools#config#get('popup_auto_close_delay')
    
    " Calculate dimensions
    let width = 0
    for line in a:lines
      let width = max([width, len(line)])
    endfor
    let width = min([width + 2, 100])
    let height = len(a:lines)
    
    " Create floating window just above cursor
    let opts = {
      \ 'relative': 'cursor',
      \ 'width': width,
      \ 'height': height,
      \ 'col': 0,
      \ 'row': -height - 1,
      \ 'anchor': 'SW',
      \ 'style': 'minimal',
      \ 'border': border
      \ }
    
    let win = nvim_open_win(buf, v:false, opts)
    
    " Set buffer options
    call nvim_buf_set_option(buf, 'modifiable', v:false)
    
    " Auto-close after configured delay
    call timer_start(auto_close_delay, function('genero_tools#display#close_inline_window', [win]))
  catch
    " Fallback to echo
    call genero_tools#display#echo(join(a:lines, "\n"))
  endtry
endfunction

" Inline popup for Vim using echo with visual formatting
function! genero_tools#display#inline_vim(lines) abort
  try
    " For classic Vim, use a simple echo-based popup that doesn't disrupt layout
    " Format the output nicely
    let formatted = []
    call add(formatted, '┌' . repeat('─', 78) . '┐')
    
    for line in a:lines
      let truncated = line[0:76]
      let padding = repeat(' ', 78 - len(truncated))
      call add(formatted, '│ ' . truncated . padding . ' │')
    endfor
    
    call add(formatted, '└' . repeat('─', 78) . '┘')
    
    " Display using echo (non-intrusive)
    call genero_tools#display#echo(join(formatted, "\n"))
    
  catch
    " Fallback to simple echo
    call genero_tools#display#echo(join(a:lines, "\n"))
  endtry
endfunction

" Close inline window (Neovim)
function! genero_tools#display#close_inline_window(win_id, timer_id) abort
  if !has('nvim')
    return
  endif
  
  try
    if nvim_win_is_valid(a:win_id)
      call nvim_win_close(a:win_id, v:true)
    endif
  catch
  endtry
endfunction

" Get error and warning counts for current buffer
function! genero_tools#display#get_diagnostic_counts() abort
  let bufnr = bufnr('%')
  let errors = 0
  let warnings = 0
  
  " Get all signs in the current buffer for compiler group
  try
    let signs = sign_getplaced(bufnr, {'group': 'genero_compiler'})
    
    if !empty(signs) && !empty(signs[0].signs)
      for sign in signs[0].signs
        if sign.name == 'GeneroCompilerError'
          let errors += 1
        elseif sign.name == 'GeneroCompilerWarning'
          let warnings += 1
        endif
      endfor
    endif
  catch
    " Silently ignore if sign_getplaced is not available
  endtry
  
  return {'errors': errors, 'warnings': warnings}
endfunction

" Format diagnostic counts for statusline
function! genero_tools#display#format_diagnostics() abort
  let counts = genero_tools#display#get_diagnostic_counts()
  let parts = []
  
  if counts.errors > 0
    call add(parts, '%#ErrorMsg#E' . counts.errors . '%*')
  endif
  
  if counts.warnings > 0
    call add(parts, '%#WarningMsg#W' . counts.warnings . '%*')
  endif
  
  if empty(parts)
    return ''
  endif
  
  return ' ' . join(parts, ' ')
endfunction

" Setup statusline integration
function! genero_tools#display#setup_statusline() abort
  " Add diagnostic counts to statusline if not already present
  if &statusline !~# 'genero_tools#display#format_diagnostics'
    let &statusline = &statusline . '%{genero_tools#display#format_diagnostics()}'
  endif
endfunction

" Get effective display mode for a feature
" Returns feature-specific override if set, otherwise returns global display_mode
function! genero_tools#display#get_mode(feature) abort
  " Check for feature-specific override
  let override_key = a:feature . '_display_mode'
  let override = genero_tools#config#get(override_key)
  
  if !empty(override)
    return override
  endif
  
  " Fall back to global display_mode
  return genero_tools#config#get('display_mode')
endfunction

" Display notification/status message
" Auto-dismisses after duration (0 = no auto-dismiss)
" Messages always display in echo mode, not in floating windows
function! genero_tools#display#notify(message, duration) abort
  if !genero_tools#config#get('notify_enabled')
    return
  endif
  
  " Always use echo for notifications, not floating windows
  call genero_tools#display#echo(a:message)
  
  " Auto-dismiss is not applicable for echo mode
  " (echo messages disappear when user presses a key or after a short time naturally)
endfunction

" Neovim notification using floating window
function! genero_tools#display#notify_neovim(message, duration) abort
  if !has('nvim')
    call genero_tools#display#notify_vim(a:message, a:duration)
    return
  endif
  
  try
    let buf = nvim_create_buf(v:false, v:true)
    call nvim_buf_set_lines(buf, 0, -1, v:false, [a:message])
    
    let width = min([len(a:message) + 2, &columns - 4])
    let height = 1
    
    let opts = {
      \ 'relative': 'editor',
      \ 'width': width,
      \ 'height': height,
      \ 'col': (&columns - width) / 2,
      \ 'row': 1,
      \ 'anchor': 'NW',
      \ 'style': 'minimal',
      \ 'border': 'rounded'
      \ }
    
    let win = nvim_open_win(buf, v:false, opts)
    
    if a:duration > 0
      call timer_start(a:duration, function('genero_tools#display#close_inline_window', [win]))
    endif
  catch
    call genero_tools#display#echo(a:message)
  endtry
endfunction

" Vim notification using echo
function! genero_tools#display#notify_vim(message, duration) abort
  call genero_tools#display#echo(a:message)
  
  if a:duration > 0 && has('timers')
    call timer_start(a:duration, function('s:clear_notification'))
  endif
endfunction

" Helper function to clear notification
function! s:clear_notification(timer_id) abort
  redraw
endfunction

" Display error with display mode support
function! genero_tools#display#error(error_message, display_mode) abort
  let display_mode = genero_tools#compat#validate_display_mode(a:display_mode)
  
  let formatted = ['Error: ' . a:error_message]
  
  if genero_tools#config#get('error_show_details')
    call add(formatted, '')
    call add(formatted, 'For more information, check the debug log.')
  endif
  
  call genero_tools#display#result({'success': 0, 'data': formatted}, display_mode)
endfunction

" Display detailed information in appropriate mode
function! genero_tools#display#details(title, content, display_mode) abort
  let display_mode = genero_tools#compat#validate_display_mode(a:display_mode)
  
  let formatted = [a:title]
  call add(formatted, repeat('=', len(a:title)))
  call add(formatted, '')
  
  if type(a:content) == type([])
    call extend(formatted, a:content)
  else
    call add(formatted, a:content)
  endif
  
  call genero_tools#display#result({'success': 1, 'data': formatted}, display_mode)
endfunction

" Safe display with error handling
function! genero_tools#display#safe_result(result, display_mode) abort
  try
    call genero_tools#display#result(a:result, a:display_mode)
  catch /E\d\+/
    " Log error for debugging if debug_mode enabled
    if genero_tools#config#get('debug_mode')
      call genero_tools#error#log('display', 'Error in display: ' . v:exception)
    endif
    
    " Fallback to echo
    if a:result.success
      call genero_tools#display#echo(join(a:result.data, "\n"))
    else
      call genero_tools#display#echo('Error: ' . a:result.error)
    endif
  endtry
endfunction
