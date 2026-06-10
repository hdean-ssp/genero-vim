" Genero-Tools Plugin - Filetype Detection

" .4gl files are detected as 'fgl' by Vim/Neovim's built-in filetype detection.
" We only need to handle .m3 and .m4 which are Genero-specific extensions.
" .per files are handled in ftdetect/per.vim
autocmd BufRead,BufNewFile *.m3 setfiletype fgl
autocmd BufRead,BufNewFile *.m4 setfiletype fgl

