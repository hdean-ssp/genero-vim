" Genero-Tools Plugin - SVN Revert Module
" Provides selective revert functionality for reverting specific lines or sections

" Get the original (base) content of a file from SVN
" Returns: dict with keys: success (bool), error (string), content (list of lines)
function! genero_tools#svn#revert#get_base_content(file_path) abort
  let file_path = a:file_path
  if empty(file_path)
    let file_path = expand('%:p')
  endif
  
  if empty(file_path)
    return {'success': 0, 'error': genero_tools#svn#error#format_no_file(), 'content': []}
  endif
  
  " Check if SVN is available
  if !genero_tools#svn#detection#is_available()
    return {'success': 0, 'error': genero_tools#svn#error#format_not_available(), 'content': []}
  endif
  
  " Check if file is in SVN working copy
  if !genero_tools#svn#detection#is_in_working_copy(file_path)
    return {'success': 0, 'error': genero_tools#svn#error#format_not_in_working_copy(file_path), 'content': []}
  endif
  
  " Execute svn cat command to get base revision
  let cmd = 'svn cat ' . shellescape(file_path) . ' 2>&1'
  
  try
    let base_content = system(cmd)
    
    if v:shell_error != 0
      " Check for binary file error
      if base_content =~? 'binary'
        return {'success': 0, 'error': genero_tools#svn#error#format_binary_file(file_path), 'content': []}
      endif
      
      " Check for authentication errors
      if base_content =~? 'authentication'
        return {'success': 0, 'error': genero_tools#svn#error#format_auth_failure(), 'content': []}
      endif
      
      " Check for permission errors
      if base_content =~? 'permission denied'
        return {'success': 0, 'error': genero_tools#svn#error#format_permission_denied(file_path), 'content': []}
      endif
      
      " Check if file is not in repository (newly added)
      if base_content =~? 'not found in repository' || base_content =~? 'was not found'
        return {'success': 0, 'error': 'File is newly added and has no base version', 'content': []}
      endif
      
      return {'success': 0, 'error': genero_tools#svn#error#format_svn_failure('cat', base_content), 'content': []}
    endif
    
    " Split content into lines
    let lines = split(base_content, '\n', 1)
    
    return {'success': 1, 'error': '', 'content': lines}
  catch
    return {'success': 0, 'error': genero_tools#svn#error#format_svn_failure('cat', v:exception), 'content': []}
  endtry
endfunction

" Revert specific lines in the current buffer to their base version
" line_nums: list of line numbers to revert
" Returns: dict with keys: success (bool), error (string), reverted_count (int)
function! genero_tools#svn#revert#revert_lines(line_nums) abort
  let file_path = expand('%:p')
  
  if empty(file_path)
    return {'success': 0, 'error': genero_tools#svn#error#format_no_file(), 'reverted_count': 0}
  endif
  
  " Get base content
  let base_result = genero_tools#svn#revert#get_base_content(file_path)
  
  if !base_result.success
    return {'success': 0, 'error': base_result.error, 'reverted_count': 0}
  endif
  
  let base_lines = base_result.content
  let current_lines = getline(1, '$')
  let reverted_count = 0
  
  " Sort line numbers in descending order to avoid line number shifts
  let sorted_lines = sort(copy(a:line_nums), {a, b -> b - a})
  
  for line_num in sorted_lines
    " Validate line number
    if line_num < 1 || line_num > len(current_lines)
      continue
    endif
    
    " Check if base has this line
    if line_num <= len(base_lines)
      " Replace with base version
      call setline(line_num, base_lines[line_num - 1])
      let reverted_count += 1
    else
      " Line doesn't exist in base, delete it (it was added)
      execute line_num . 'delete'
      let reverted_count += 1
    endif
  endfor
  
  return {'success': 1, 'error': '', 'reverted_count': reverted_count}
endfunction

" Revert a range of lines to their base version
" Returns: dict with keys: success (bool), error (string), reverted_count (int)
function! genero_tools#svn#revert#revert_range(start_line, end_line) abort
  let file_path = expand('%:p')
  
  if empty(file_path)
    return {'success': 0, 'error': genero_tools#svn#error#format_no_file(), 'reverted_count': 0}
  endif
  
  " Validate range
  if a:start_line < 1 || a:end_line < a:start_line
    return {'success': 0, 'error': 'Invalid line range', 'reverted_count': 0}
  endif
  
  " Get base content
  let base_result = genero_tools#svn#revert#get_base_content(file_path)
  
  if !base_result.success
    return {'success': 0, 'error': base_result.error, 'reverted_count': 0}
  endif
  
  let base_lines = base_result.content
  let current_lines = getline(1, '$')
  
  " Build the replacement content
  let new_lines = []
  
  " Keep lines before the range
  if a:start_line > 1
    let new_lines = current_lines[0 : a:start_line - 2]
  endif
  
  " Add base lines for the range
  let base_start = a:start_line - 1
  let base_end = min([a:end_line - 1, len(base_lines) - 1])
  
  if base_start < len(base_lines)
    let new_lines += base_lines[base_start : base_end]
  endif
  
  " Keep lines after the range
  if a:end_line < len(current_lines)
    let new_lines += current_lines[a:end_line :]
  endif
  
  " Replace buffer content
  silent! execute '1,' . line('$') . 'delete _'
  call setline(1, new_lines)
  
  let reverted_count = a:end_line - a:start_line + 1
  
  return {'success': 1, 'error': '', 'reverted_count': reverted_count}
endfunction

" Revert current line to base version
" Returns: dict with keys: success (bool), error (string)
function! genero_tools#svn#revert#revert_current_line() abort
  let line_num = line('.')
  let result = genero_tools#svn#revert#revert_lines([line_num])
  
  if result.success
    call genero_tools#display#echo('Reverted line ' . line_num . ' to base version')
  else
    call genero_tools#display#echo('Error: ' . result.error)
  endif
  
  return result
endfunction

" Revert visual selection to base version
" Returns: dict with keys: success (bool), error (string)
function! genero_tools#svn#revert#revert_visual_selection() abort
  " Get visual selection range
  let start_line = line("'<")
  let end_line = line("'>")
  
  let result = genero_tools#svn#revert#revert_range(start_line, end_line)
  
  if result.success
    call genero_tools#display#echo(printf('Reverted %d lines to base version', result.reverted_count))
  else
    call genero_tools#display#echo('Error: ' . result.error)
  endif
  
  return result
endfunction

" Revert all changed lines in the current buffer
" Returns: dict with keys: success (bool), error (string), reverted_count (int)
function! genero_tools#svn#revert#revert_all_changes() abort
  let file_path = expand('%:p')
  
  if empty(file_path)
    return {'success': 0, 'error': genero_tools#svn#error#format_no_file(), 'reverted_count': 0}
  endif
  
  " Get diff to find changed lines
  let diff_result = genero_tools#svn#diff#get_diff(file_path)
  
  if !diff_result.success
    return {'success': 0, 'error': diff_result.error, 'reverted_count': 0}
  endif
  
  " Parse diff to get changed lines
  let changes = genero_tools#svn#parser#parse_diff(diff_result.diff)
  
  " Collect all changed line numbers
  let changed_lines = []
  let changed_lines += changes.added
  let changed_lines += changes.modified
  let changed_lines += changes.deleted
  
  if empty(changed_lines)
    return {'success': 1, 'error': '', 'reverted_count': 0}
  endif
  
  " Revert all changed lines
  return genero_tools#svn#revert#revert_lines(changed_lines)
endfunction

" Show a preview of what would be reverted
" Returns: list of strings showing the diff
function! genero_tools#svn#revert#preview_revert(start_line, end_line) abort
  let file_path = expand('%:p')
  
  if empty(file_path)
    return ['Error: No file open']
  endif
  
  " Get base content
  let base_result = genero_tools#svn#revert#get_base_content(file_path)
  
  if !base_result.success
    return ['Error: ' . base_result.error]
  endif
  
  let base_lines = base_result.content
  let current_lines = getline(1, '$')
  let preview = []
  
  call add(preview, '=== Revert Preview ===')
  call add(preview, printf('Lines %d-%d', a:start_line, a:end_line))
  call add(preview, '')
  
  for line_num in range(a:start_line, a:end_line)
    if line_num > len(current_lines)
      break
    endif
    
    let current = current_lines[line_num - 1]
    let base = line_num <= len(base_lines) ? base_lines[line_num - 1] : '[deleted]'
    
    if current !=# base
      call add(preview, printf('Line %d:', line_num))
      call add(preview, '  Current: ' . current)
      call add(preview, '  Base:    ' . base)
      call add(preview, '')
    endif
  endfor
  
  if len(preview) == 3
    call add(preview, 'No changes in this range')
  endif
  
  return preview
endfunction

" Interactive revert with confirmation
function! genero_tools#svn#revert#revert_with_confirmation(start_line, end_line) abort
  " Show preview
  let preview = genero_tools#svn#revert#preview_revert(a:start_line, a:end_line)
  
  " Display preview
  if genero_tools#compat#has_floating_window()
    call genero_tools#display#show_floating_window(preview, {
      \ 'title': 'Revert Preview',
      \ 'width': 80,
      \ 'height': min([len(preview), 20])
      \ })
  else
    echo join(preview, "\n")
  endif
  
  " Ask for confirmation
  let response = input('Revert these lines? (y/n): ')
  
  if response ==? 'y' || response ==? 'yes'
    let result = genero_tools#svn#revert#revert_range(a:start_line, a:end_line)
    if result.success
      call genero_tools#display#echo(printf('Reverted %d lines', result.reverted_count))
    else
      call genero_tools#display#echo('Error: ' . result.error)
    endif
  else
    call genero_tools#display#echo('Revert cancelled')
  endif
endfunction
