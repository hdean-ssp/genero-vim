" Genero-Tools Plugin - SVN Diff Parser Module
" Parses unified diff format and extracts line change information

" Parse unified diff format
" Returns: dict with keys: added (list), modified (list), deleted (list)
" Each list contains line numbers where changes occur
function! genero_tools#svn#parser#parse_diff(diff_output) abort
  let lines = split(a:diff_output, '\n')
  let result = {
    \ 'added': [],
    \ 'modified': [],
    \ 'deleted': []
    \ }
  
  let current_line_num = 0
  let i = 0
  let in_hunk = 0
  
  while i < len(lines)
    let line = lines[i]
    
    " Look for hunk header: @@ -OLD_START,OLD_COUNT +NEW_START,NEW_COUNT @@
    if line =~? '^@@'
      let in_hunk = 1
      " Parse the hunk header to get new line numbers
      let match = matchlist(line, '^@@ -\d\+,\?\d* +\(\d\+\),\?\(\d*\) @@')
      if len(match) > 1
        let current_line_num = str2nr(match[1])
      endif
      let i += 1
      continue
    endif
    
    " Skip file headers
    if line =~? '^Index:' || line =~? '^===' || line =~? '^---' || line =~? '^+++'
      let i += 1
      continue
    endif
    
    " Process diff lines only if we're in a hunk
    if in_hunk && len(line) > 0
      let first_char = line[0]
      
      if first_char == '+'
        " Added line (but not the +++ header)
        if line !~? '^+++' && current_line_num > 0
          call add(result.added, current_line_num)
          let current_line_num += 1
        endif
      elseif first_char == '-'
        " Deleted line (but not the --- header)
        if line !~? '^---' && current_line_num > 0
          call add(result.deleted, current_line_num)
        endif
      elseif first_char == ' '
        " Context line (unchanged)
        let current_line_num += 1
      elseif first_char == '\'
        " "\ No newline at end of file" marker - skip
        " Don't increment line number
      else
        " Unknown line type - treat as context
        let current_line_num += 1
      endif
    elseif in_hunk && len(line) == 0
      " Empty line in diff - treat as context
      let current_line_num += 1
    endif
    
    let i += 1
  endwhile
  
  return result
endfunction

" Detect modified lines (lines that appear as both added and deleted)
" Returns: list of line numbers that were modified
function! genero_tools#svn#parser#detect_modified_lines(added, deleted) abort
  let modified = []
  
  " Look for consecutive added/deleted pairs
  let i = 0
  while i < len(a:deleted)
    let deleted_line = a:deleted[i]
    
    " Check if there's an added line right after the deleted line
    if i < len(a:added) && a:added[i] == deleted_line + 1
      call add(modified, deleted_line)
      let i += 1
    endif
    
    let i += 1
  endwhile
  
  return modified
endfunction

" Extract line numbers for added lines
" Returns: list of line numbers
function! genero_tools#svn#parser#get_added_lines(diff_output) abort
  let parsed = genero_tools#svn#parser#parse_diff(a:diff_output)
  return parsed.added
endfunction

" Extract line numbers for deleted lines
" Returns: list of line numbers
function! genero_tools#svn#parser#get_deleted_lines(diff_output) abort
  let parsed = genero_tools#svn#parser#parse_diff(a:diff_output)
  return parsed.deleted
endfunction

" Extract line numbers for modified lines
" Returns: list of line numbers
function! genero_tools#svn#parser#get_modified_lines(diff_output) abort
  let parsed = genero_tools#svn#parser#parse_diff(a:diff_output)
  
  " Detect modified lines by looking for consecutive added/deleted pairs
  let modified = genero_tools#svn#parser#detect_modified_lines(parsed.added, parsed.deleted)
  
  return modified
endfunction

" Get all changed lines (added, modified, or deleted)
" Returns: dict with keys: added, modified, deleted
function! genero_tools#svn#parser#get_all_changes(diff_output) abort
  return genero_tools#svn#parser#parse_diff(a:diff_output)
endfunction

" Check if diff is empty (no changes)
" Returns: 1 if empty, 0 if has changes
function! genero_tools#svn#parser#is_empty(diff_output) abort
  let parsed = genero_tools#svn#parser#parse_diff(a:diff_output)
  
  return len(parsed.added) == 0 && len(parsed.deleted) == 0
endfunction

" Get summary of changes
" Returns: dict with keys: added_count, deleted_count, modified_count, total_changes
function! genero_tools#svn#parser#get_summary(diff_output) abort
  let parsed = genero_tools#svn#parser#parse_diff(a:diff_output)
  
  let added_count = len(parsed.added)
  let deleted_count = len(parsed.deleted)
  let modified_count = genero_tools#svn#parser#detect_modified_lines(parsed.added, parsed.deleted)
  
  return {
    \ 'added_count': added_count,
    \ 'deleted_count': deleted_count,
    \ 'modified_count': len(modified_count),
    \ 'total_changes': added_count + deleted_count
    \ }
endfunction
