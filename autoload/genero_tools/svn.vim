" Genero-Tools Plugin - SVN Diff Markers Module
" Provides SVN integration for displaying diff markers in sign column

" Initialize SVN module
function! genero_tools#svn#init() abort
  " Initialize SVN detection cache
  if !exists('g:genero_tools_svn_cache')
    let g:genero_tools_svn_cache = {}
  endif
  
  " Initialize SVN signs
  call genero_tools#svn#signs#init()
  
  " Register SVN commands
  call genero_tools#svn#commands#register()
  
  " Setup autocommand for file save
  call genero_tools#svn#setup_autocommand()
endfunction

" Check if SVN is available on the system
function! genero_tools#svn#is_available() abort
  return genero_tools#svn#detection#is_available()
endfunction

" Check if a file is in an SVN working copy
function! genero_tools#svn#is_in_working_copy(file_path) abort
  return genero_tools#svn#detection#is_in_working_copy(a:file_path)
endfunction

" Get the SVN working copy root directory
function! genero_tools#svn#get_working_copy_root(file_path) abort
  return genero_tools#svn#detection#get_working_copy_root(a:file_path)
endfunction

" Get SVN diff for a file
function! genero_tools#svn#get_diff(file_path) abort
  return genero_tools#svn#diff#get_diff(a:file_path)
endfunction

" Parse unified diff format
function! genero_tools#svn#parse_diff(diff_output) abort
  return genero_tools#svn#parser#parse_diff(a:diff_output)
endfunction

" Cache SVN diff results (delegates to cache module)
function! genero_tools#svn#cache_get(file_path) abort
  let cached = genero_tools#svn#cache#get(a:file_path)
  if cached.cached
    return {'diff': cached}
  endif
  return {}
endfunction

" Store SVN diff in cache (delegates to cache module)
function! genero_tools#svn#cache_set(file_path, diff_result) abort
  call genero_tools#svn#cache#set(a:file_path, a:diff_result)
endfunction

" Clear SVN cache for a file (delegates to cache module)
function! genero_tools#svn#cache_invalidate(file_path) abort
  call genero_tools#svn#cache#invalidate(a:file_path)
endfunction

" Clear all SVN cache (delegates to cache module)
function! genero_tools#svn#cache_clear() abort
  call genero_tools#svn#cache#clear()
endfunction

" Setup autocommand for file save
function! genero_tools#svn#setup_autocommand() abort
  " Only setup if auto_update is enabled
  if !genero_tools#config#get('svn_auto_update')
    return
  endif
  
  " Create autocommand group for SVN
  augroup genero_svn_autocommand
    autocmd!
    " Update SVN signs on file save
    autocmd BufWritePost * call genero_tools#svn#on_file_save()
  augroup END
endfunction

" Handle file save event
function! genero_tools#svn#on_file_save() abort
  " Check if SVN is enabled
  if !genero_tools#config#get('svn_enabled')
    return
  endif
  
  let file_path = expand('%')
  
  if empty(file_path)
    return
  endif
  
  " Check if file is in SVN working copy
  if !genero_tools#svn#detection#is_in_working_copy(file_path)
    return
  endif
  
  " Invalidate cache for this file
  call genero_tools#svn#cache_invalidate(file_path)
  
  " Get fresh diff
  let diff_result = genero_tools#svn#diff#get_diff(file_path)
  
  if !diff_result.success
    " Silently fail - don't disrupt user workflow
    return
  endif
  
  " Cache the result
  call genero_tools#svn#cache_set(file_path, diff_result)
  
  " Parse the diff
  let changes = genero_tools#svn#parser#parse_diff(diff_result.diff)
  
  " Place signs in the current buffer
  let bufnr = bufnr('%')
  
  " Check if signs are enabled for this buffer
  let toggle_key = 'buffer_' . bufnr
  let is_enabled = get(g:genero_tools_svn_toggle_state, toggle_key, 1)
  
  if is_enabled
    call genero_tools#svn#signs#place(bufnr, changes)
  endif
endfunction
