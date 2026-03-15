" Genero-Tools Plugin - Codebase Path Detection

" Detect the codebase root directory
" Searches for configured project markers starting from the current file
" Falls back to current working directory if no markers found
function! genero_tools#codebase#get_root() abort
  " Get configured markers from config (castle.sch is first by default)
  let markers = genero_tools#config#get('codebase_markers')
  let current_dir = expand('%:p:h')
  
  " Search for each marker starting from current file directory
  for marker in markers
    " Check if marker is a file
    let marker_path = findfile(marker, current_dir . ';')
    if !empty(marker_path)
      " Return the directory containing the marker file
      return fnamemodify(marker_path, ':h')
    endif
    
    " Check if marker is a directory
    let marker_path = finddir(marker, current_dir . ';')
    if !empty(marker_path)
      return fnamemodify(marker_path, ':h')
    endif
  endfor
  
  " Fall back to current working directory
  return getcwd()
endfunction

" Check if a codebase root was found (vs falling back to cwd)
" Returns 1 if a marker was found, 0 if using fallback
function! genero_tools#codebase#has_marker() abort
  let markers = genero_tools#config#get('codebase_markers')
  let current_dir = expand('%:p:h')
  
  for marker in markers
    let marker_path = findfile(marker, current_dir . ';')
    if !empty(marker_path)
      return 1
    endif
    
    let marker_path = finddir(marker, current_dir . ';')
    if !empty(marker_path)
      return 1
    endif
  endfor
  
  return 0
endfunction

" Get the configured codebase markers
function! genero_tools#codebase#get_markers() abort
  return genero_tools#config#get('codebase_markers')
endfunction

" Set custom codebase markers
" Usage: call genero_tools#codebase#set_markers(['castle.sch', 'custom.marker'])
function! genero_tools#codebase#set_markers(markers) abort
  if type(a:markers) != type([])
    call genero_tools#display#echo('Error: markers must be a list')
    return 0
  endif
  
  let g:genero_tools_config['codebase_markers'] = a:markers
  return 1
endfunction
