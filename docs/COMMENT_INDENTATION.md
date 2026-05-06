# Comment Indentation in Genero Files

## Issue

By default, Vim's `smartindent` option has special handling for lines starting with `#` that moves them to column 0. This is designed for C preprocessor directives (`#include`, `#define`, etc.) but causes problems for Genero comments which use `#` as the comment character.

### Problem Behavior

```4gl
FUNCTION test()
    LET x = 1
    #|  <- Typing # here moves cursor to column 0
```

Expected:
```4gl
FUNCTION test()
    LET x = 1
    # Comment at proper indentation
```

Actual (before fix):
```4gl
FUNCTION test()
    LET x = 1
# Comment moved to column 0
```

## Solution

The plugin provides indent files for all Genero filetypes that disable `smartindent`'s special `#` handling while preserving proper indentation behavior.

### Files Created

- `indent/4gl.vim` - For `.4gl` files
- `indent/fgl.vim` - For `.fgl` files  
- `indent/genero.vim` - For generic Genero files
- `indent/per.vim` - For `.per` form files

### What These Files Do

1. **Disable smartindent** - Prevents `#` from being moved to column 0
2. **Enable autoindent** - Preserves current indentation level
3. **Disable cindent** - Prevents C-style indentation rules
4. **Clear indentkeys** - Removes special key triggers for `#`

## Technical Details

### smartindent Behavior

From Vim documentation:
> When typing '#' as the first character in a new line, the indent for that line is removed, the '#' is put in the first column.

This is useful for C but problematic for Genero where `#` is the comment character.

### Our Approach

```vim
" Disable smartindent's special # handling
setlocal nosmartindent

" Use autoindent instead (preserves current indentation)
setlocal autoindent

" Disable cindent's special # handling
setlocal nocindent

" Clear indentkeys to prevent special # handling
setlocal indentkeys=

" Preserve indentation when typing # for comments
setlocal cinkeys-=0#
setlocal indentkeys-=0#
```

## Usage

No configuration needed - the indent files are automatically loaded when you open a Genero file.

### Testing

1. Open a `.4gl` file
2. Create a function with proper indentation:
   ```4gl
   FUNCTION test()
       LET x = 1
   ```
3. On the indented line, type `#` to start a comment
4. The cursor should stay at the current indentation level
5. Type your comment:
   ```4gl
   FUNCTION test()
       LET x = 1
       # This comment stays indented
   ```

## Compatibility

### Neovim
Works with both `init.lua` and `init.vim` configurations.

### Vim 8.x
Works with `.vimrc` configuration.

### Global Settings
If you have `smartindent` set globally in your config (like in `init.lua.example`), the indent files will override it for Genero filetypes only. Other filetypes will still use `smartindent`.

## Related Settings

### formatoptions
The plugin also sets `formatoptions` to auto-insert comment leaders:

```vim
" In ftplugin/*.vim files
setlocal commentstring=#\ %s
```

```lua
-- In init.lua.example
vim.opt.formatoptions:append("ro")
```

This means:
- `r` - Auto-insert comment leader after Enter in insert mode
- `o` - Auto-insert comment leader after o/O in normal mode

### Example

```4gl
FUNCTION test()
    # First comment line
    # <-- Press Enter, # is auto-inserted
```

## Troubleshooting

### Comments Still Moving to Column 0

If comments are still being moved to column 0:

1. Check if indent files are being loaded:
   ```vim
   :set indentexpr?
   :set smartindent?
   :set cindent?
   ```

2. Verify filetype is detected:
   ```vim
   :set filetype?
   ```
   Should show: `4gl`, `fgl`, `genero`, or `per`

3. Check if another plugin is overriding settings:
   ```vim
   :verbose set smartindent?
   ```

4. Manually apply settings:
   ```vim
   :setlocal nosmartindent autoindent
   ```

### Custom Indentation

If you want different indentation behavior, create your own indent file in:
- `~/.vim/after/indent/4gl.vim` (Vim)
- `~/.config/nvim/after/indent/4gl.vim` (Neovim)

This will override the plugin's indent settings.

## References

- `:help smartindent`
- `:help autoindent`
- `:help cindent`
- `:help indentkeys`
- `:help cinkeys`
- `:help formatoptions`

## Related Issues

This fix addresses the common complaint: "Why do my comments jump to the beginning of the line?"

The answer: Vim's `smartindent` treats `#` specially for C preprocessor directives. Our indent files disable this for Genero files where `#` is the comment character.
