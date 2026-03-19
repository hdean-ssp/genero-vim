# Quick Setup Guide

Get genero-tools running in 2 minutes.

## Installation

### Using vim-plug (Vim 8+ / Neovim)

Add to your `~/.config/nvim/init.vim` or `~/.vimrc`:

```vim
call plug#begin()
Plug 'hdean-ssp/genero-vim'
call plug#end()
```

Then run `:PlugInstall` in Vim/Neovim.

### Manual Installation

Clone into your plugins directory:

```bash
# Neovim
git clone https://github.com/hdean-ssp/genero-vim ~/.local/share/nvim/site/pack/plugins/start/genero-vim

# Vim
git clone https://github.com/hdean-ssp/genero-vim ~/.vim/pack/plugins/start/genero-vim
```

## Configuration

### Quickest Start (Copy Example Config)

```bash
# Neovim
cp init.lua.example ~/.config/nvim/init.lua

# Vim
cp .vimrc.example ~/.vimrc
```

This includes sensible defaults for:
- Plugin manager setup
- genero-tools configuration
- Essential keybindings
- Neovim enhancements (lualine, which-key, tokyonight)

### Minimal Configuration

If you prefer to add genero-tools to an existing config:

```vim
" Enable the plugin
let g:genero_tools_config = {
  \ 'compiler_enabled': 1,
  \ 'keybindings_enabled': 1,
  \ 'hints_enabled': 1,
  \ }

" Compile with F5
nnoremap <F5> :GeneroCompile<CR>

" Navigate errors
nnoremap <C-,> :GeneroPrevError<CR>
nnoremap <C-.> :GeneroNextError<CR>

" Autocomplete (insert mode)
inoremap <C-n> <C-x><C-o>

" Code navigation
nnoremap <leader>gl :GeneroLookup <C-R><C-W><CR>
nnoremap <leader>gf :call genero_tools#list_functions_in_file(expand('%'))<CR>
nnoremap <leader>gs :GeneroFunctionSignature <C-R><C-W><CR>
```

## First Steps

1. **Compile a file:** Press `F5` to compile the current file
2. **Navigate errors:** Use `Ctrl+,` and `Ctrl+.` to jump between errors
3. **Look up functions:** Press `<space>gl` to lookup a function definition
4. **Get help:** Run `:GeneroHelp` to see all available commands

## Common Keybindings

| Key | Action |
|-----|--------|
| `F5` | Compile current file |
| `Ctrl+,` | Previous error |
| `Ctrl+.` | Next error |
| `Ctrl+N` | Autocomplete (insert mode) |
| `<space>gl` | Lookup function |
| `<space>gf` | List functions in file |
| `<space>gs` | Get function signature |
| `<space>gm` | Get file metadata |

## Troubleshooting

**Plugin not loading?**
- Check that the plugin directory exists: `~/.local/share/nvim/site/pack/plugins/start/genero-vim` (Neovim) or `~/.vim/pack/plugins/start/genero-vim` (Vim)
- Run `:scriptnames` to see loaded scripts

**Keybindings not working?**
- Make sure `keybindings_enabled` is set to `1` in config
- Check for conflicting keybindings with `:map <C-n>` (example)

**Autocomplete not working?**
- Ensure `omnifunc` is set: `:set omnifunc=genero_tools#complete#omnifunc`
- Try manually triggering with `Ctrl+X Ctrl+O` in insert mode

## Next Steps

- See [README.md](README.md) for full feature list
- Check [docs/](docs/) for detailed documentation
- Run `:GeneroHelp` for command reference

## Support

For issues or questions, see the [GitHub repository](https://github.com/hdean-ssp/genero-vim).
