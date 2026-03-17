" Genero-Tools Plugin - SVN Commands Module
" Provides user-facing commands for SVN diff markers management

" Initialize per-buffer toggle state
if !exists('g:genero_tools_svn_toggle_state')
  let g:genero_tools_svn_toggle_state = {}
endif

" Manually refresh diff markers for current buffer
" Command: :GeneroSVNRefresh
function! genero_tools#svn#commands#refresh() abort
  let file_path = expand('%')
  
  " Check if file is open
  if !genero_tools#svn#error#check_file_open()
    return
  endif
  
  " Check if SVN is enabled
  if !genero_tools#svn#error#check_enabled()
    return
  endif
  
  " Check if SVN is available
  if !genero_tools#svn#error#check_availability()
    return
  endif
  
  " Check if file is in SVN working copy
  if !genero_tools#svn#error#check_in_working_copy(file_path)
    return
  endif
  
  " Invalidate cache for this file
  call genero_tools#svn#cache_invalidate(file_path)
  
  " Get fresh diff
  let diff_result = genero_tools#svn#diff#get_diff(file_path)
  
  if !diff_result.success
    call genero_tools#display#echo('Error: ' . diff_result.error)
    return
  endif
  
  " Cache the result
  call genero_tools#svn#cache_set(file_path, diff_result)
  
  " Parse the diff
  let changes = genero_tools#svn#parser#parse_diff(diff_result.diff)
  
  " Place signs in the current buffer
  let bufnr = bufnr('%')
  call genero_tools#svn#signs#place(bufnr, changes)
  
  " Show status message
  let summary = genero_tools#svn#parser#get_summary(diff_result.diff)
  let msg = printf('SVN markers refreshed: +%d ~%d -%d', 
    \ summary.added_count, 
    \ summary.modified_count, 
    \ summary.deleted_count)
  call genero_tools#display#echo(msg)
endfunction

" Helper function to display SVN signs for current buffer
function! genero_tools#svn#commands#display_signs_for_buffer() abort
  let file_path = expand('%')
  
  if empty(file_path)
    return
  endif
  
  " Check if file is in SVN working copy
  if !genero_tools#svn#detection#is_in_working_copy(file_path)
    return
  endif
  
  " Get diff for the file
  let diff_result = genero_tools#svn#diff#get_diff(file_path)
  
  if !diff_result.success
    return
  endif
  
  " Parse the diff
  let changes = genero_tools#svn#parser#parse_diff(diff_result.diff)
  
  " Place signs in the current buffer
  let bufnr = bufnr('%')
  call genero_tools#svn#signs#place(bufnr, changes)
endfunction

" Toggle SVN diff markers on/off for current buffer
" Command: :GeneroSVNToggle
function! genero_tools#svn#commands#toggle() abort
  let bufnr = bufnr('%')
  let file_path = expand('%')
  
  " Check if file is open
  if !genero_tools#svn#error#check_file_open()
    return
  endif
  
  " Check if SVN is enabled
  if !genero_tools#svn#error#check_enabled()
    return
  endif
  
  " Check if SVN is available
  if !genero_tools#svn#error#check_availability()
    return
  endif
  
  " Get current toggle state for this buffer
  let toggle_key = 'buffer_' . bufnr
  let is_enabled = get(g:genero_tools_svn_toggle_state, toggle_key, 1)
  
  " Toggle the state
  let new_state = !is_enabled
  let g:genero_tools_svn_toggle_state[toggle_key] = new_state
  
  if new_state
    " Re-enable signs for this buffer
    call genero_tools#svn#commands#display_signs_for_buffer()
    call genero_tools#display#echo('SVN diff markers enabled for this buffer')
  else
    " Disable signs for this buffer
    call genero_tools#svn#signs#clear(bufnr)
    call genero_tools#display#echo('SVN diff markers disabled for this buffer')
  endif
endfunction

" Show SVN status for current file
" Command: :GeneroSVNStatus
function! genero_tools#svn#commands#status() abort
  let file_path = expand('%')
  
  " Check if file is open
  if !genero_tools#svn#error#check_file_open()
    return
  endif
  
  " Check if SVN is enabled
  if !genero_tools#svn#error#check_enabled()
    return
  endif
  
  " Check if SVN is available
  if !genero_tools#svn#error#check_availability()
    return
  endif
  
  " Check if file is in SVN working copy
  if !genero_tools#svn#error#check_in_working_copy(file_path)
    return
  endif
  
  " Get SVN status
  let status_result = genero_tools#svn#diff#get_status(file_path)
  
  if !genero_tools#svn#error#handle_status_result(status_result)
    return
  endif
  
  " Get diff for change summary
  let diff_result = genero_tools#svn#diff#get_diff(file_path)
  
  " Build status message
  let output = []
  call add(output, '=== SVN Status ===')
  call add(output, '')
  call add(output, 'File: ' . file_path)
  call add(output, '')
  
  " Parse SVN status output
  let status_lines = split(status_result.status, '\n')
  if len(status_lines) > 0 && !empty(status_lines[0])
    let status_line = status_lines[0]
    call add(output, 'Status: ' . status_line)
  else
    call add(output, 'Status: No changes')
  endif
  
  call add(output, '')
  
  " Add change summary if diff is available
  if diff_result.success
    let summary = genero_tools#svn#parser#get_summary(diff_result.diff)
    call add(output, 'Changes:')
    call add(output, '  Added lines: ' . summary.added_count)
    call add(output, '  Modified lines: ' . summary.modified_count)
    call add(output, '  Deleted lines: ' . summary.deleted_count)
    call add(output, '  Total changes: ' . summary.total_changes)
    call add(output, '')
  endif
  
  " Check cache status
  let cached = genero_tools#svn#cache_get(file_path)
  if !empty(cached)
    call add(output, 'Cache: Cached (fresh)')
  else
    call add(output, 'Cache: Not cached')
  endif
  
  " Display the status
  call genero_tools#display#echo(join(output, "\n"))
endfunction

" Register SVN commands
function! genero_tools#svn#commands#register() abort
  command! GeneroSVNRefresh call genero_tools#svn#commands#refresh()
  command! GeneroSVNToggle call genero_tools#svn#commands#toggle()
  command! GeneroSVNStatus call genero_tools#svn#commands#status()
  command! GeneroSVNCacheStats call genero_tools#svn#commands#cache_stats()
  command! GeneroSVNCacheClear call genero_tools#svn#commands#cache_clear()
endfunction

" Show SVN cache statistics
" Command: :GeneroSVNCacheStats
function! genero_tools#svn#commands#cache_stats() abort
  call genero_tools#svn#cache#show_stats()
endfunction

" Clear SVN cache
" Command: :GeneroSVNCacheClear
function! genero_tools#svn#commands#cache_clear() abort
  call genero_tools#svn#cache#clear()
  call genero_tools#svn#cache#reset_stats()
  call genero_tools#display#echo('SVN cache cleared and statistics reset')
endfunction
