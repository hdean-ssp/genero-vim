" Genero-Tools Plugin - Display Modes

" Main display dispatcher
function! genero_tools#display#result(result, display_mode) abort
  if a:result.success
    let formatted = genero_tools#display#format_success(a:result.data)
  else
    let formatted = genero_tools#display#format_error(a:result.error)
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
  copen
endfunction

" Display in popup window (neovim only - large floating window)
function! genero_tools#display#popup(formatted) abort
  try
    " Create popup buffer
    let buf = nvim_create_buf(v:false, v:true)
    call nvim_buf_set_lines(buf, 0, -1, v:false, a:formatted)
    
    " Calculate dimensions
    let width = 80
    let height = min([len(a:formatted) + 2, 20])
    
    " Create popup window
    let opts = {
      \ 'relative': 'cursor',
      \ 'width': width,
      \ 'height': height,
      \ 'col': 0,
      \ 'row': 1,
      \ 'anchor': 'NW',
      \ 'style': 'minimal',
      \ 'border': 'rounded'
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
  try
    " Create popup buffer
    let buf = nvim_create_buf(v:false, v:true)
    call nvim_buf_set_lines(buf, 0, -1, v:false, a:lines)
    
    " Calculate dimensions
    let width = 0
    for line in a:lines
      let width = max([width, len(line)])
    endfor
    let width = min([width + 2, 100])
    let height = len(a:lines)
    
    " Create floating window above cursor
    let opts = {
      \ 'relative': 'cursor',
      \ 'width': width,
      \ 'height': height,
      \ 'col': 0,
      \ 'row': -height - 1,
      \ 'anchor': 'SW',
      \ 'style': 'minimal',
      \ 'border': 'single'
      \ }
    
    let win = nvim_open_win(buf, v:false, opts)
    
    " Set buffer options
    call nvim_buf_set_option(buf, 'modifiable', v:false)
    
    " Auto-close after 5 seconds
    call timer_start(5000, function('genero_tools#display#close_inline_window', [win]))
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
    
    " Show a message that it will auto-clear
    echomsg 'Press any key to dismiss'
    
  catch
    " Fallback to simple echo
    call genero_tools#display#echo(join(a:lines, "\n"))
  endtry
endfunction

" Close inline window (Neovim)
function! genero_tools#display#close_inline_window(win_id, timer_id) abort
  try
    if nvim_win_is_valid(a:win_id)
      call nvim_win_close(a:win_id, v:true)
    endif
  catch
  endtry
endfunction
