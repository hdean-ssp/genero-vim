" Genero-Tools Plugin - Filetype Plugin for Genero/FGL

" Setup completion (omnifunc always enabled for Ctrl+N, pause-based optional)
call genero_tools#complete#setup_auto()

" Setup completion preview window
call genero_tools#complete#setup_preview()

" Set comment string for fgl files (# for comments)
setlocal commentstring=#\ %s

" Enable autocompile for fgl files if configured
if genero_tools#config#get('compiler_autocompile')
  call genero_tools#compiler#autocompile#enable()
endif

" Smart Tab completion - accepts exact match or cycles through options
function! s:smart_tab_complete() abort
  if pumvisible()
    " Check if current selection is an exact match
    let typed = matchstr(getline('.'), '\k\+\%' . col('.') . 'c')
    let selected = complete_info(['selected', 'items'])
    
    if selected.selected >= 0
      let item = selected.items[selected.selected]
      let word = type(item) == type({}) ? get(item, 'word', '') : item
      
      " If exact match, accept and close
      if word ==# typed
        return "\<C-y>"
      endif
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
