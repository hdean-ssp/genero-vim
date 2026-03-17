" Genero-Tools Plugin - SVN Detection Module
" Provides SVN availability and working copy detection with caching

" Initialize detection cache
if !exists('g:genero_tools_svn_detection_cache')
  let g:genero_tools_svn_detection_cache = {}
endif

" Check if SVN is installed and available
" Returns: 1 if available, 0 if not
function! genero_tools#svn#detection#is_available() abort
  let cache_key = 'svn_available'
  let cache_ttl = 3600  " Cache for 1 hour
  
  " Check cache first
  if has_key(g:genero_tools_svn_detection_cache, cache_key)
    let entry = g:genero_tools_svn_detection_cache[cache_key]
    if localtime() - entry.timestamp < cache_ttl
      return entry.value
    endif
  endif
  
  " Try to execute svn --version
  let result = system('svn --version 2>&1')
  let is_available = v:shell_error == 0
  
  " Cache the result
  let g:genero_tools_svn_detection_cache[cache_key] = {
    \ 'value': is_available,
    \ 'timestamp': localtime()
    \ }
  
  return is_available
endfunction

" Get SVN version string
" Returns: version string or empty if not available
function! genero_tools#svn#detection#get_version() abort
  if !genero_tools#svn#detection#is_available()
    return ''
  endif
  
  let result = system('svn --version 2>&1')
  if v:shell_error == 0
    " Extract first line which contains version
    let lines = split(result, '\n')
    if len(lines) > 0
      return lines[0]
    endif
  endif
  
  return ''
endfunction

" Check if a file is in an SVN working copy
" Returns: 1 if in working copy, 0 if not
function! genero_tools#svn#detection#is_in_working_copy(file_path) abort
  let file_path = a:file_path
  if empty(file_path)
    let file_path = expand('%')
  endif
  
  if empty(file_path)
    return 0
  endif
  
  " Get the directory containing the file
  let dir = fnamemodify(file_path, ':h')
  if empty(dir)
    let dir = '.'
  endif
  
  " Check for .svn directory
  return genero_tools#svn#detection#find_svn_dir(dir) != ''
endfunction

" Find SVN directory (.svn) by searching up the directory tree
" Returns: path to .svn directory, or empty string if not found
function! genero_tools#svn#detection#find_svn_dir(start_dir) abort
  let dir = a:start_dir
  let max_depth = 20  " Prevent infinite loops
  let depth = 0
  
  while depth < max_depth
    let svn_dir = dir . '/.svn'
    
    " Check if .svn directory exists
    if isdirectory(svn_dir)
      return svn_dir
    endif
    
    " Move to parent directory
    let parent = fnamemodify(dir, ':h')
    if parent == dir
      " Reached root directory
      break
    endif
    
    let dir = parent
    let depth += 1
  endwhile
  
  return ''
endfunction

" Get the SVN working copy root directory
" Returns: path to working copy root, or empty string if not in working copy
function! genero_tools#svn#detection#get_working_copy_root(file_path) abort
  let file_path = a:file_path
  if empty(file_path)
    let file_path = expand('%')
  endif
  
  if empty(file_path)
    return ''
  endif
  
  let dir = fnamemodify(file_path, ':h')
  if empty(dir)
    let dir = '.'
  endif
  
  let svn_dir = genero_tools#svn#detection#find_svn_dir(dir)
  if empty(svn_dir)
    return ''
  endif
  
  " Return the parent directory of .svn
  return fnamemodify(svn_dir, ':h')
endfunction

" Clear detection cache
function! genero_tools#svn#detection#cache_clear() abort
  let g:genero_tools_svn_detection_cache = {}
endfunction
