" Genero-Tools Plugin - Filetype Plugin for Genero/FGL

" Set omnifunc for fgl files
setlocal omnifunc=genero_tools#complete#omnifunc

" Set other useful options for fgl files
setlocal commentstring=--\ %s

" Tab-based completion keybindings
" Tab to trigger completion
inoremap <buffer> <Tab> <C-x><C-o>

" In completion menu:
" - Tab/Down arrow to navigate down
" - Shift+Tab/Up arrow to navigate up
" - Enter to accept
" - Esc to cancel
inoremap <buffer> <expr> <Tab> pumvisible() ? "\<C-n>" : "\<C-x>\<C-o>"
inoremap <buffer> <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <buffer> <expr> <Down> pumvisible() ? "\<C-n>" : "\<Down>"
inoremap <buffer> <expr> <Up> pumvisible() ? "\<C-p>" : "\<Up>"
inoremap <buffer> <expr> <CR> pumvisible() ? "\<C-y>" : "\<CR>"
inoremap <buffer> <expr> <Esc> pumvisible() ? "\<C-e>" : "\<Esc>"
