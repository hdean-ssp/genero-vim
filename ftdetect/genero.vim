" Genero-Tools Plugin - Filetype Detection

" Detect .4gl files as fgl filetype (vim default)
" Our ftplugin will handle the omnifunc setup
autocmd BufRead,BufNewFile *.m3 setfiletype fgl
autocmd BufRead,BufNewFile *.m4 setfiletype fgl

