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
  
  " Blame commands
  command! GeneroSVNBlame call genero_tools#svn#commands#blame()
  command! GeneroSVNBlameCurrentLine call genero_tools#svn#commands#blame_current_line()
  command! -range GeneroSVNBlameRange call genero_tools#svn#commands#blame_range(<line1>, <line2>)
  
  " Revert commands
  command! GeneroSVNRevertLine call genero_tools#svn#commands#revert_current_line()
  command! -range GeneroSVNRevertRange call genero_tools#svn#commands#revert_range(<line1>, <line2>)
  command! -range GeneroSVNRevertRangeConfirm call genero_tools#svn#commands#revert_range_confirm(<line1>, <line2>)
  command! GeneroSVNRevertAllChanges call genero_tools#svn#commands#revert_all_changes()
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

" ============================================================================
" Blame Commands
" ============================================================================

" Show blame for entire file
" Command: :GeneroSVNBlame
function! genero_tools#svn#commands#blame() abort
  let file_path = expand('%:p')
  
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
  
  " Get blame information
  let blame_result = genero_tools#svn#blame#get_blame(file_path)
  
  if !blame_result.success
    call genero_tools#display#echo('Error: ' . blame_result.error)
    return
  endif
  
  " Show blame in floating window
  call genero_tools#svn#blame#show_blame_window(blame_result.blame)
endfunction

" Show blame for current line
" Command: :GeneroSVNBlameCurrentLine
function! genero_tools#svn#commands#blame_current_line() abort
  let file_path = expand('%:p')
  let line_num = line('.')
  
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
  
  " Get blame for current line
  let blame_entry = genero_tools#svn#blame#get_line_blame(file_path, line_num)
  
  if empty(blame_entry)
    call genero_tools#display#echo('No blame information for line ' . line_num)
    return
  endif
  
  " Show as virtual text if Neovim
  if has('nvim')
    let bufnr = bufnr('%')
    call genero_tools#svn#blame#show_virtual_text(bufnr, line_num, blame_entry)
    
    " Set up autocmd to clear virtual text when cursor moves
    augroup GeneroSVNBlameVirtualText
      autocmd!
      autocmd CursorMoved,CursorMovedI <buffer> call genero_tools#svn#blame#clear_virtual_text(bufnr('%')) | autocmd! GeneroSVNBlameVirtualText
    augroup END
  endif
  
  " Also show in status line
  let info = genero_tools#svn#blame#format_blame_info(blame_entry)
  call genero_tools#display#echo('Line ' . line_num . ': ' . info)
endfunction

" Show blame for a range of lines
" Command: :GeneroSVNBlameRange (with visual selection)
function! genero_tools#svn#commands#blame_range(start_line, end_line) abort
  let file_path = expand('%:p')
  
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
  
  " Get blame for range
  let blame_data = genero_tools#svn#blame#get_range_blame(file_path, a:start_line, a:end_line)
  
  if empty(blame_data)
    call genero_tools#display#echo('No blame information for lines ' . a:start_line . '-' . a:end_line)
    return
  endif
  
  " Show blame in floating window
  call genero_tools#svn#blame#show_blame_window(blame_data)
endfunction

" ============================================================================
" Revert Commands
" ============================================================================

" Revert current line to base version
" Command: :GeneroSVNRevertLine
function! genero_tools#svn#commands#revert_current_line() abort
  let file_path = expand('%:p')
  
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
  
  " Revert current line
  call genero_tools#svn#revert#revert_current_line()
  
  " Refresh SVN signs
  call genero_tools#svn#commands#display_signs_for_buffer()
endfunction

" Revert a range of lines to base version
" Command: :GeneroSVNRevertRange (with visual selection or line range)
function! genero_tools#svn#commands#revert_range(start_line, end_line) abort
  let file_path = expand('%:p')
  
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
  
  " Revert range
  let result = genero_tools#svn#revert#revert_range(a:start_line, a:end_line)
  
  if result.success
    call genero_tools#display#echo(printf('Reverted %d lines to base version', result.reverted_count))
  else
    call genero_tools#display#echo('Error: ' . result.error)
  endif
  
  " Refresh SVN signs
  call genero_tools#svn#commands#display_signs_for_buffer()
endfunction

" Revert a range with confirmation
" Command: :GeneroSVNRevertRangeConfirm (with visual selection or line range)
function! genero_tools#svn#commands#revert_range_confirm(start_line, end_line) abort
  let file_path = expand('%:p')
  
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
  
  " Revert with confirmation
  call genero_tools#svn#revert#revert_with_confirmation(a:start_line, a:end_line)
  
  " Refresh SVN signs
  call genero_tools#svn#commands#display_signs_for_buffer()
endfunction

" Revert all changes in the current buffer
" Command: :GeneroSVNRevertAllChanges
function! genero_tools#svn#commands#revert_all_changes() abort
  let file_path = expand('%:p')
  
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
  
  " Ask for confirmation
  let response = input('Revert all changes in this file? (y/n): ')
  
  if response !=? 'y' && response !=? 'yes'
    call genero_tools#display#echo('Revert cancelled')
    return
  endif
  
  " Revert all changes
  let result = genero_tools#svn#revert#revert_all_changes()
  
  if result.success
    if result.reverted_count > 0
      call genero_tools#display#echo(printf('Reverted %d lines to base version', result.reverted_count))
    else
      call genero_tools#display#echo('No changes to revert')
    endif
  else
    call genero_tools#display#echo('Error: ' . result.error)
  endif
  
  " Refresh SVN signs
  call genero_tools#svn#commands#display_signs_for_buffer()
endfunction
