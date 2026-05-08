" Genero-Tools Plugin - Filetype Plugin for Genero Form Files (.per)

" Setup completion (omnifunc always enabled for Ctrl+N, pause-based optional)
call genero_tools#complete#setup_auto()

" Setup completion preview window
call genero_tools#complete#setup_preview()

" Set comment string for per files (# for comments)
setlocal commentstring=#\ %s

" Enable autocompile for per files if configured
if genero_tools#config#get('compiler_autocompile')
  call genero_tools#compiler#autocompile#enable()
endif

" Smart Tab completion - accepts exact match or cycles through options
function! s:smart_tab_complete() abort
  if pumvisible()
    " Get what the user has typed
    let line = getline('.')
    let col = col('.')
    let typed = matchstr(line[0:col-2], '\k\+$')
    
    if !empty(typed)
      " Check if any completion item is an exact match
      let info = complete_info(['items'])
      for item in info.items
        let word = type(item) == type({}) ? get(item, 'word', '') : item
        
        " If exact match found, accept and close
        if word ==# typed
          return "\<C-y>"
        endif
      endfor
    endif
    
    " Otherwise cycle to next
    return "\<C-n>"
  else
    return "\<Tab>"
  endif
endfunction

" Navigation in completion menu
inoremap <buffer> <expr> <Tab> <SID>smart_tab_complete()
inoremap <buffer> <expr> <Down> pumvisible() ? "\<C-n>" : "\<Down>"
inoremap <buffer> <expr> <Up> pumvisible() ? "\<C-p>" : "\<Up>"
inoremap <buffer> <expr> <CR> pumvisible() ? "\<C-y>" : "\<CR>"
inoremap <buffer> <expr> <Esc> pumvisible() ? "\<C-e>" : "\<Esc>"
