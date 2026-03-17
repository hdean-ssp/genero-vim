" Genero-Tools Plugin - SVN Sign Column Integration
" Provides sign placement for SVN diff markers (added/modified/deleted)

" Define sign names
let s:sign_added = 'GeneroSVNAdded'
let s:sign_modified = 'GeneroSVNModified'
let s:sign_deleted = 'GeneroSVNDeleted'

" Initialize SVN signs (define them once)
function! genero_tools#svn#signs#init() abort
  " Define highlight groups if they don't exist
  if !hlexists('GeneroSVNAdded')
    highlight GeneroSVNAdded ctermfg=2 guifg=#00ff00
  endif
  
  if !hlexists('GeneroSVNModified')
    highlight GeneroSVNModified ctermfg=3 guifg=#ffff00
  endif
  
  if !hlexists('GeneroSVNDeleted')
    highlight GeneroSVNDeleted ctermfg=1 guifg=#ff0000
  endif
  
  " Define signs
  execute 'sign define ' . s:sign_added . ' text=+ texthl=GeneroSVNAdded'
  execute 'sign define ' . s:sign_modified . ' text=~ texthl=GeneroSVNModified'
  execute 'sign define ' . s:sign_deleted . ' text=- texthl=GeneroSVNDeleted'
endfunction

" Place SVN signs for a buffer
" Arguments:
"   bufnr - buffer number
"   changes - dict with keys: added (list), modified (list), deleted (list)
function! genero_tools#svn#signs#place(bufnr, changes) abort
  " Initialize signs if not already done
  if !exists('s:signs_initialized')
    call genero_tools#svn#signs#init()
    let s:signs_initialized = v:true
  endif
  
  " Clear existing SVN signs first
  call genero_tools#svn#signs#clear(a:bufnr)
  
  let sign_id = 1
  let file_path = fnamemodify(bufname(a:bufnr), ':p')
  
  " Get the lists from changes dict
  let added = get(a:changes, 'added', [])
  let modified = get(a:changes, 'modified', [])
  let deleted = get(a:changes, 'deleted', [])
  
  " Create a set of modified lines for quick lookup
  let modified_set = {}
  for line_num in modified
    let modified_set[line_num] = 1
  endfor
  
  " Place signs for added lines
  for line_num in added
    " Skip if this line is also in modified (treat as modified)
    if has_key(modified_set, line_num)
      continue
    endif
    
    try
      execute 'sign place ' . sign_id . ' group=genero_svn line=' . line_num . 
            \ ' name=' . s:sign_added . 
            \ ' buffer=' . a:bufnr
      let sign_id += 1
    catch
      " Silently ignore if sign placement fails
    endtry
  endfor
  
  " Place signs for modified lines
  for line_num in modified
    try
      execute 'sign place ' . sign_id . ' group=genero_svn line=' . line_num . 
            \ ' name=' . s:sign_modified . 
            \ ' buffer=' . a:bufnr
      let sign_id += 1
    catch
      " Silently ignore if sign placement fails
    endtry
  endfor
  
  " Place signs for deleted lines (on line before deletion)
  for line_num in deleted
    " Show deleted marker on the line before the deletion
    let marker_line = line_num > 1 ? line_num - 1 : 1
    
    try
      execute 'sign place ' . sign_id . ' group=genero_svn line=' . marker_line . 
            \ ' name=' . s:sign_deleted . 
            \ ' buffer=' . a:bufnr
      let sign_id += 1
    catch
      " Silently ignore if sign placement fails
    endtry
  endfor
endfunction

" Clear all SVN signs for a buffer
" Arguments:
"   bufnr - buffer number
function! genero_tools#svn#signs#clear(bufnr) abort
  try
    execute 'sign unplace * group=genero_svn buffer=' . a:bufnr
  catch
    " Silently ignore if no signs to clear
  endtry
endfunction

" Clear all SVN signs globally
function! genero_tools#svn#signs#clear_all() abort
  try
    execute 'sign unplace * group=genero_svn'
  catch
    " Silently ignore if no signs to clear
  endtry
endfunction

