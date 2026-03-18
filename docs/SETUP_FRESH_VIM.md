# Setting Up Genero-Tools Plugin on Fresh Vim Install

This guide walks you through setting up the genero-tools plugin on a completely fresh Vim installation using vim-plug.

## Prerequisites

- Vim 8.0+ or Neovim 0.4+
- `query.sh` from genero-tools (must be in PATH or configured)
- Git (for vim-plug installation)
- curl (for vim-plug auto-installation)

## Step 1: Create Fresh `.vimrc`

Copy the provided `.vimrc.example` to your home directory:

```bash
cp .vimrc.example ~/.vimrc
```

Or manually create `~/.vimrc` with the contents from `.vimrc.example`. The example includes:
- vim-plug plugin manager setup
- Genero-tools plugin configuration
- Neovim-specific enhancements (lualine, which-key, tokyonight theme)
- Sensible defaults for both Vim and Neovim
- Helpful keybindings and commands

## Step 2: Install Vim-Plug

The `.vimrc` includes automatic vim-plug installation. When you start Vim for the first time, it will:

1. Download vim-plug to `~/.vim/autoload/plug.vim`
2. Automatically run `:PlugInstall` to install all plugins
3. Reload your configuration

The `.vimrc.example` includes these plugins:
- **genero-vim** - Genero-tools plugin
- **LuaSnip** - Code snippets (Vim 8.2+ and Neovim)
- **lualine.nvim** - Modern statusline (Vim 8+ and Neovim)
- **which-key.nvim** - Keybinding hints (Neovim only)
- **tokyonight.nvim** - Modern color theme (Neovim only)
- **Comment.nvim** - Easy commenting (Neovim only)
- **indent-blankline.nvim** - Visual indentation guides (Neovim only)

Alternatively, install vim-plug manually:

```bash
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```

## Step 3: Start Vim and Install Plugins

```bash
vim
```

Vim will automatically:
- Install vim-plug (if not already installed)
- Install the genero-tools plugin
- Load your configuration

If plugins don't install automatically, run:

```vim
:PlugInstall
```

## Step 4: Verify Installation

Inside Vim, run:

```vim
:GeneroConfigShow
```

You should see:
- Current configuration settings
- Cache statistics
- Supported display modes
- Estimated memory usage

## Step 5: Configure genero-tools Path (if needed)

If `query.sh` is not in your PATH, edit `~/.vimrc` and set:

```vim
let g:genero_tools_config.genero_tools_path = '/full/path/to/query.sh'
```

Then restart Vim to load the updated configuration.

## Step 6: Test the Plugin

Try these commands:

```vim
" Test function lookup
:GeneroLookup test_function

" Test with keybinding (place cursor on a function name)
<leader>gl

" Show configuration
:GeneroConfigShow

" Clear cache
:GeneroClearCache
```

## Configuration Options

### Basic Configuration

```vim
let g:genero_tools_config = {
  \ 'genero_tools_path': 'query.sh',
  \ 'cache_enabled': v:true,
  \ 'cache_ttl': 3600,
  \ 'display_mode': 'quickfix',
  \ 'keybindings_enabled': v:true,
  \ 'timeout': 10000,
  \ 'async_enabled': v:true,
  \ 'result_limit': 1000,
  \ 'pagination_size': 50,
  \ 'codebase_markers': ['castle.sch', 'genero.conf', '.genero', '.git'],
  \ 'compiler_enabled': v:true,
  \ 'compiler_autocompile': v:true,
  \ 'compiler_autocompile_delay': 1000
  \ }
```

### Codebase Detection

The plugin automatically detects your project root by searching for markers. By default, it looks for `castle.sch` first, then falls back to `genero.conf`, `.genero`, and `.git`. Customize the markers for your project:

```vim
let g:genero_tools_config.codebase_markers = ['custom.marker', '.git']
```

### For Large Codebases (6M+ LOC)

```vim
let g:genero_tools_config = {
  \ 'genero_tools_path': 'query.sh',
  \ 'cache_enabled': v:true,
  \ 'cache_ttl': 7200,
  \ 'cache_max_size': 200,
  \ 'display_mode': 'quickfix',
  \ 'keybindings_enabled': v:true,
  \ 'timeout': 15000,
  \ 'async_enabled': v:true,
  \ 'result_limit': 2000,
  \ 'pagination_size': 100,
  \ 'codebase_markers': ['castle.sch', 'genero.conf', '.genero', '.git'],
  \ 'compiler_enabled': v:true,
  \ 'compiler_autocompile': v:true,
  \ 'compiler_autocompile_delay': 1000
  \ }
```

### Neovim Lua Layer (Optional)

For Neovim users, enable the optional Lua layer for enhanced features:

```vim
let g:genero_tools_config.lua_enabled = v:true           " Enable Lua layer
let g:genero_tools_config.async_enabled = v:true         " Use async operations
```

**Lua Layer Features** (Neovim 0.4+ only):
- Async operations with non-blocking execution
- Floating windows for rich UI
- Better performance on large codebases

The Lua layer is optional and gracefully falls back to VimScript if unavailable.

## Display Modes

Choose your preferred display mode:

```vim
" Quickfix list (default, works everywhere)
let g:genero_tools_config.display_mode = 'quickfix'

" Inline popup above cursor (Neovim: floating, Vim: preview)
let g:genero_tools_config.display_mode = 'inline'

" Large floating window (Neovim only, falls back to inline in Vim)
let g:genero_tools_config.display_mode = 'popup'

" New split window
let g:genero_tools_config.display_mode = 'split'

" Command line output
let g:genero_tools_config.display_mode = 'echo'
```

## Default Keybindings

| Keybinding | Action |
|-----------|--------|
| `<leader>gl` | Find function under cursor |
| `<leader>gf` | List functions in current file |
| `<leader>gs` | Get function signature under cursor |
| `<leader>gm` | Get metadata for current file |

To disable keybindings:

```vim
let g:genero_tools_config.keybindings_enabled = v:false
```

To customize keybindings, add to your `.vimrc`:

```vim
nnoremap <silent> <leader>gl :GeneroLookup <C-R><C-W><CR>
nnoremap <silent> <leader>gf :GeneroListFunctions %<CR>
nnoremap <silent> <leader>gs :GeneroFunctionSignature <C-R><C-W><CR>
nnoremap <silent> <leader>gm :GeneroFileMetadata %<CR>
```

## Available Commands

```vim
:GeneroLookup [function_name]           " Find function definition
:GeneroListFunctions [file_path]        " List functions in file
:GeneroListModuleFiles [module_name]    " List files in module
:GeneroFunctionSignature [function_name] " Get function signature
:GeneroFileMetadata [file_path]         " Get file metadata
:GeneroConfigShow                       " Display current config
:GeneroClearCache                       " Clear result cache
:GeneroCompile [file]                   " Compile file
:GeneroAutocompileEnable                " Enable autocompile for buffer
:GeneroAutocompileDisable               " Disable autocompile for buffer
:GeneroAutocompileStatus                " Show autocompile status
:GeneroNextError                        " Jump to next error
:GeneroPrevError                        " Jump to previous error
:GeneroClearErrors                      " Clear error markers
```

## Troubleshooting

### query.sh not found

Set the full path in your `.vimrc`:

```vim
let g:genero_tools_config.genero_tools_path = '/path/to/query.sh'
```

### Slow queries

Increase the timeout:

```vim
let g:genero_tools_config.timeout = 20000  " 20 seconds
```

### Results not updating

Clear the cache:

```vim
:GeneroClearCache
```

### Plugin not loading

Check that vim-plug is installed:

```bash
ls -la ~/.vim/autoload/plug.vim
```

If missing, install manually:

```bash
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```

Then run `:PlugInstall` in Vim.

### Verify Installation

Run this command in Vim:

```vim
:GeneroConfigShow
```

Should display configuration and cache statistics.

## Next Steps

- Read [API_INTEGRATION.md](API_INTEGRATION.md) for detailed API documentation
- Check [COMPATIBILITY.md](COMPATIBILITY.md) for Vim/Neovim compatibility details
- Review [QUICK_START.md](QUICK_START.md) for usage examples
- Check genero-tools API documentation in `/genero-tools-api/api/`

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review the documentation in `/docs/`
3. Check genero-tools API documentation
4. Open an issue on GitHub

