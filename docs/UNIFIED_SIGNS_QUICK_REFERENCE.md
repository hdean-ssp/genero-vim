# Unified Signs - Quick Reference

## Commands

### Enable Unified Signs
```vim
:GeneroUnifiedSignsEnable
```
Enables combined display of compiler and SVN signs in a single column.

### Disable Unified Signs
```vim
:GeneroUnifiedSignsDisable
```
Disables unified signs and clears combined signs from all buffers.

### Toggle Unified Signs
```vim
:GeneroUnifiedSignsToggle
```
Quickly switch between unified and separate sign columns.

### Show Status
```vim
:GeneroUnifiedSignsStatus
```
Display current status of unified signs and individual sign systems.

## Quick Setup

### In Your Config (init.vim / .vimrc)

**Enable by default:**
```vim
let g:genero_tools_unified_signs_enabled = 1
```

**Add keybindings for quick access:**
```vim
" Toggle unified signs with <leader>us
nnoremap <leader>us :GeneroUnifiedSignsToggle<CR>

" Enable with <leader>ue
nnoremap <leader>ue :GeneroUnifiedSignsEnable<CR>

" Disable with <leader>ud
nnoremap <leader>ud :GeneroUnifiedSignsDisable<CR>

" Show status with <leader>uss
nnoremap <leader>uss :GeneroUnifiedSignsStatus<CR>
```

## Usage Examples

### Example 1: Quick Toggle While Editing

```vim
" You're editing and want to see both compiler and SVN signs
:GeneroUnifiedSignsToggle

" Now you see combined signs like ✕|~ on the same line
" Press again to go back to separate columns
:GeneroUnifiedSignsToggle
```

### Example 2: Using Keybindings

With the keybindings above:

```vim
" Press <leader>us to toggle
" Press <leader>ue to enable
" Press <leader>ud to disable
" Press <leader>uss to check status
```

### Example 3: Conditional Setup

```vim
" Enable unified signs only for certain file types
autocmd FileType fgl let g:genero_tools_unified_signs_enabled = 1
autocmd FileType vim let g:genero_tools_unified_signs_enabled = 0
```

## Sign Display

### Unified Mode (Enabled)
```
Line  Col1      Code
  1   ✕         function foo()
  2   +         let x = 1
  3   ✕|~       let y = x + 2
  4             return y
```

### Separate Mode (Disabled)
```
Line  Col1  Col2  Code
  1   ✕           function foo()
  2        +      let x = 1
  3   ✕     ~     let y = x + 2
  4               return y
```

## Troubleshooting

### Command Not Found
If you get "Not an editor command: GeneroUnifiedSignsEnable", ensure:
1. genero-tools plugin is installed
2. Plugin is loaded: `:echo exists('g:loaded_genero_tools')`

### Signs Not Showing
Check if signs are enabled:
```vim
:GeneroUnifiedSignsStatus
```

If disabled, enable them:
```vim
:GeneroUnifiedSignsEnable
```

### Too Many Signs
If the sign column is crowded:
```vim
" Disable SVN signs, keep compiler signs
let g:genero_tools_svn_signs_enabled = 0

" Or disable compiler signs, keep SVN signs
let g:genero_tools_compiler_signs_enabled = 0
```

## Performance

- Unified signs are more efficient than separate columns
- No performance impact when toggling
- Sign caching prevents redundant definitions
- Safe to toggle frequently

## Related Commands

```vim
" Compiler commands
:GeneroCompile              " Compile current file
:GeneroClearErrors          " Clear error signs
:GeneroNextError            " Jump to next error
:GeneroPrevError            " Jump to previous error

" SVN commands
:GeneroSVNRefresh           " Refresh SVN signs
:GeneroSVNToggle            " Toggle SVN signs
:GeneroSVNStatus            " Show SVN status

" Sign commands
:GeneroUnifiedSignsEnable   " Enable unified signs
:GeneroUnifiedSignsDisable  " Disable unified signs
:GeneroUnifiedSignsToggle   " Toggle unified signs
:GeneroUnifiedSignsStatus   " Show unified signs status
```

## Tips

1. **Use keybindings** for fastest access - toggle with one keystroke
2. **Check status** if signs aren't showing as expected
3. **Combine with other commands** - compile, then toggle signs to see results
4. **Experiment** - try both modes to see which you prefer

## See Also

- `UNIFIED_SIGN_COLUMN.md` - Architecture and design
- `UNIFIED_SIGN_CONFIGURATION.md` - Detailed configuration guide
