" Genero-Tools Plugin - SVN Blame Module
" Provides SVN blame functionality for displaying line-level authorship information

" Get SVN blame for a specific line (optimized - doesn't parse entire file)
" Returns: dict with keys: success (bool), error (string), blame (dict)
" Blame entry contains: line_num, revision, author, date
function! genero_tools#svn#blame#get_line_blame_fast(file_path, line_num) abort
  let file_path = a:file_path
  if empty(file_path)
    let file_path = expand('%:p')
  endif
  
  if empty(file_path)
    return {}
  endif
  
  " Check if SVN is available
  if !genero_tools#svn#detection#is_available()
    return {}
  endif
  
  " Check if file is in SVN working copy
  if !genero_tools#svn#detection#is_in_working_copy(file_path)
    return {}
  endif
  
  " Execute svn blame for specific line only (much faster)
  let cmd = printf('svn blame -r BASE %s 2>&1 | sed -n ''%dp''', shellescape(file_path), a:line_num)
  
  try
    let blame_output = system(cmd)
    
    if v:shell_error != 0
      return {}
    endif
    
    " Parse the single line output
    " Format: "   123 username     line content"
    let match = matchlist(blame_output, '^\s*\(\d\+\)\s\+\(\S\+\)')
    
    if len(match) >= 3
      return {
        \ 'line_num': a:line_num,
        \ 'revision': match[1],
        \ 'author': match[2],
        \ 'date': ''
        \ }
    endif
    
    return {}
  catch
    return {}
  endtry
endfunction

" Get SVN blame for a file
" Returns: dict with keys: success (bool), error (string), blame (list of dicts)
" Each blame entry contains: line_num, revision, author, date, content
function! genero_tools#svn#blame#get_blame(file_path) abort
  let file_path = a:file_path
  if empty(file_path)
    let file_path = expand('%:p')
  endif
  
  if empty(file_path)
    return {'success': 0, 'error': genero_tools#svn#error#format_no_file(), 'blame': []}
  endif
  
  " Check if SVN is available
  if !genero_tools#svn#detection#is_available()
    return {'success': 0, 'error': genero_tools#svn#error#format_not_available(), 'blame': []}
  endif
  
  " Check if file is in SVN working copy
  if !genero_tools#svn#detection#is_in_working_copy(file_path)
    return {'success': 0, 'error': genero_tools#svn#error#format_not_in_working_copy(file_path), 'blame': []}
  endif
  
  " Execute svn blame command with XML output for easier parsing
  let cmd = 'svn blame --xml ' . shellescape(file_path) . ' 2>&1'
  
  try
    let blame_output = system(cmd)
    
    if v:shell_error != 0
      " Check for binary file error
      if blame_output =~? 'binary'
        return {'success': 0, 'error': genero_tools#svn#error#format_binary_file(file_path), 'blame': []}
      endif
      
      " Check for authentication errors
      if blame_output =~? 'authentication'
        return {'success': 0, 'error': genero_tools#svn#error#format_auth_failure(), 'blame': []}
      endif
      
      " Check for permission errors
      if blame_output =~? 'permission denied'
        return {'success': 0, 'error': genero_tools#svn#error#format_permission_denied(file_path), 'blame': []}
      endif
      
      return {'success': 0, 'error': genero_tools#svn#error#format_svn_failure('blame', blame_output), 'blame': []}
    endif
    
    " Parse the blame output
    let blame_data = genero_tools#svn#blame#parse_blame(blame_output)
    
    return {'success': 1, 'error': '', 'blame': blame_data}
  catch
    return {'success': 0, 'error': genero_tools#svn#error#format_svn_failure('blame', v:exception), 'blame': []}
  endtry
endfunction

" Parse SVN blame XML output
" Returns: list of dicts with keys: line_num, revision, author, date
function! genero_tools#svn#blame#parse_blame(xml_output) abort
  let lines = split(a:xml_output, '\n')
  let blame_data = []
  let line_num = 1
  let in_entry = 0
  let current_entry = {}
  
  for line in lines
    " Start of entry
    if line =~? '<entry'
      let in_entry = 1
      let current_entry = {'line_num': line_num}
    endif
    
    " Extract revision
    if line =~? '<commit.*revision='
      let match = matchlist(line, 'revision="\(\d\+\)"')
      if len(match) > 1
        let current_entry.revision = match[1]
      endif
    endif
    
    " Extract author
    if line =~? '<author>'
      let match = matchlist(line, '<author>\(.\{-}\)</author>')
      if len(match) > 1
        let current_entry.author = match[1]
      else
        let current_entry.author = 'unknown'
      endif
    endif
    
    " Extract date
    if line =~? '<date>'
      let match = matchlist(line, '<date>\(.\{-}\)</date>')
      if len(match) > 1
        let current_entry.date = genero_tools#svn#blame#format_date(match[1])
      else
        let current_entry.date = 'unknown'
      endif
    endif
    
    " End of entry
    if line =~? '</entry>'
      let in_entry = 0
      if !empty(current_entry)
        call add(blame_data, current_entry)
        let line_num += 1
      endif
      let current_entry = {}
    endif
  endfor
  
  return blame_data
endfunction

" Format ISO 8601 date to readable format
" Input: 2024-01-15T10:30:45.123456Z
" Output: 2024-01-15 10:30
function! genero_tools#svn#blame#format_date(iso_date) abort
  " Extract date and time parts
  let match = matchlist(a:iso_date, '\(\d\{4\}-\d\{2\}-\d\{2\}\)T\(\d\{2\}:\d\{2\}\)')
  if len(match) > 2
    return match[1] . ' ' . match[2]
  endif
  return a:iso_date
endfunction

" Get blame info for a specific line
" Returns: dict with keys: revision, author, date, or empty dict if not found
function! genero_tools#svn#blame#get_line_blame(file_path, line_num) abort
  " Try fast method first (doesn't parse entire file)
  let blame_entry = genero_tools#svn#blame#get_line_blame_fast(a:file_path, a:line_num)
  
  if !empty(blame_entry)
    return blame_entry
  endif
  
  " Fallback to full blame if fast method fails
  let blame_result = genero_tools#svn#blame#get_blame(a:file_path)
  
  if !blame_result.success
    return {}
  endif
  
  " Find the blame entry for the specified line
  for entry in blame_result.blame
    if entry.line_num == a:line_num
      return entry
    endif
  endfor
  
  return {}
endfunction

" Get blame info for a range of lines
" Returns: list of blame entries for the specified range
function! genero_tools#svn#blame#get_range_blame(file_path, start_line, end_line) abort
  let blame_result = genero_tools#svn#blame#get_blame(a:file_path)
  
  if !blame_result.success
    return []
  endif
  
  let range_blame = []
  for entry in blame_result.blame
    if entry.line_num >= a:start_line && entry.line_num <= a:end_line
      call add(range_blame, entry)
    endif
  endfor
  
  return range_blame
endfunction

" Format blame info for display
" Returns: string formatted for display
function! genero_tools#svn#blame#format_blame_info(blame_entry) abort
  if empty(a:blame_entry)
    return 'No blame information available'
  endif
  
  let revision = get(a:blame_entry, 'revision', '?')
  let author = get(a:blame_entry, 'author', 'unknown')
  let date = get(a:blame_entry, 'date', 'unknown')
  
  return printf('r%s | %s | %s', revision, author, date)
endfunction

" Show blame info in a floating window
function! genero_tools#svn#blame#show_blame_window(blame_data) abort
  if empty(a:blame_data)
    call genero_tools#display#echo('No blame information available')
    return
  endif
  
  " Format blame data for display
  let lines = []
  call add(lines, '=== SVN Blame ===')
  call add(lines, '')
  
  for entry in a:blame_data
    let line_info = printf('Line %d: r%s | %s | %s',
      \ entry.line_num,
      \ get(entry, 'revision', '?'),
      \ get(entry, 'author', 'unknown'),
      \ get(entry, 'date', 'unknown'))
    call add(lines, line_info)
  endfor
  
  " Display using the display module
  if has('nvim')
    call genero_tools#display#popup(lines)
  else
    call genero_tools#display#echo(join(lines, "\n"))
  endif
endfunction

" Show blame as virtual text for current line (Neovim only)
function! genero_tools#svn#blame#show_virtual_text(bufnr, line_num, blame_entry) abort
  if !has('nvim')
    return
  endif
  
  if empty(a:blame_entry)
    return
  endif
  
  " Create namespace for SVN blame virtual text
  if !exists('s:blame_ns_id')
    let s:blame_ns_id = nvim_create_namespace('genero_svn_blame')
  endif
  
  " Clear existing virtual text for this line
  call nvim_buf_clear_namespace(a:bufnr, s:blame_ns_id, a:line_num - 1, a:line_num)
  
  " Format blame info
  let revision = get(a:blame_entry, 'revision', '?')
  let author = get(a:blame_entry, 'author', 'unknown')
  let text = printf('  r%s %s', revision, author)
  
  " Add virtual text at end of line
  try
    call nvim_buf_set_extmark(a:bufnr, s:blame_ns_id, a:line_num - 1, 0, {
      \ 'virt_text': [[text, 'Comment']],
      \ 'virt_text_pos': 'eol',
      \ 'priority': 100
      \ })
  catch
    " Silently fail if extmark fails
  endtry
endfunction

" Clear blame virtual text
function! genero_tools#svn#blame#clear_virtual_text(bufnr) abort
  if !has('nvim')
    return
  endif
  
  if !exists('s:blame_ns_id')
    return
  endif
  
  try
    call nvim_buf_clear_namespace(a:bufnr, s:blame_ns_id, 0, -1)
  catch
    " Silently fail
  endtry
endfunction

" Toggle blame virtual text for current line
function! genero_tools#svn#blame#toggle_virtual_text() abort
  if !has('nvim')
    call genero_tools#display#echo('Virtual text requires Neovim')
    return
  endif
  
  let bufnr = bufnr('%')
  let line_num = line('.')
  
  " Check if virtual text is already shown
  if !exists('s:blame_ns_id')
    let s:blame_ns_id = nvim_create_namespace('genero_svn_blame')
  endif
  
  let marks = nvim_buf_get_extmarks(bufnr, s:blame_ns_id, [line_num - 1, 0], [line_num - 1, -1], {})
  
  if !empty(marks)
    " Clear if already shown
    call genero_tools#svn#blame#clear_virtual_text(bufnr)
    call genero_tools#display#echo('Blame virtual text cleared')
  else
    " Show blame
    let file_path = expand('%:p')
    let blame_entry = genero_tools#svn#blame#get_line_blame(file_path, line_num)
    
    if !empty(blame_entry)
      call genero_tools#svn#blame#show_virtual_text(bufnr, line_num, blame_entry)
      let info = genero_tools#svn#blame#format_blame_info(blame_entry)
      call genero_tools#display#echo('Blame: ' . info)
    else
      call genero_tools#display#echo('No blame information available')
    endif
  endif
endfunction

