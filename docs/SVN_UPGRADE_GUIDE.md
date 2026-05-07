# SVN Features Upgrade Guide

## Overview

This guide helps you get started with the new SVN blame and selective revert features.

## What's New?

### SVN Blame
View line-level authorship information directly in Vim:
- Who last modified each line
- When the change was made
- Which revision introduced the change

### Selective Revert
Revert specific lines or sections without reverting the entire file:
- Revert individual lines
- Revert visual selections
- Preview changes before reverting
- Undo reverts if needed

## Quick Start (30 Seconds)

### Try Blame
```vim
" Open any file in an SVN working copy
:e src/customer.4gl

" Check who last modified the current line
<leader>sb
```

### Try Revert
```vim
" Make a change to a line
:s/old/new/

" Revert it back
<leader>sr
```

That's it! You're using the new features.

## Installation

### No Installation Required!

If you already have Genero-Tools installed, the new features are automatically available. Just update to the latest version:

```bash
# Using vim-plug
:PlugUpdate

# Using git
cd ~/.vim/bundle/genero-vim
git pull
```

### Verify Installation

Check that the commands are available:
```vim
:GeneroSVNBlame
:GeneroSVNRevertLine
```

If these commands exist, you're all set!

## Configuration

### No Configuration Required!

The new features use your existing SVN configuration:

```vim
" Your existing config works as-is
let g:genero_tools_config.svn_enabled = 1
let g:genero_tools_config.svn_cache_ttl = 300
```

### Optional: Customize Keybindings

If you want different keybindings:

```vim
" In your .vimrc or init.vim
" Disable default SVN keybindings
let g:genero_tools_disable_svn_keybindings = 1

" Define your own
nnoremap <leader>gb :GeneroSVNBlameCurrentLine<CR>
vnoremap <leader>gb :GeneroSVNBlameRange<CR>
nnoremap <leader>gr :GeneroSVNRevertLine<CR>
vnoremap <leader>gr :GeneroSVNRevertRangeConfirm<CR>
```

## Learning the Features

### 5-Minute Tutorial

#### Step 1: Blame a Line
```vim
" 1. Open a file
:e src/order.4gl

" 2. Navigate to any line
:42

" 3. Check who changed it
<leader>sb
" Output: Line 42: r1256 | jane.smith | 2024-01-20 14:45
```

#### Step 2: Blame a Section
```vim
" 1. Select lines in visual mode
V
5j

" 2. Check blame for selection
<leader>sb
" Shows blame for all selected lines in a window
```

#### Step 3: Revert a Line
```vim
" 1. Make a change
:s/old/new/

" 2. Revert it
<leader>sr
" Output: Reverted line 42 to base version

" 3. Undo if needed
u
```

#### Step 4: Revert a Section
```vim
" 1. Select lines to revert
V
5j

" 2. Revert with preview
<leader>sr
" Shows what will change

" 3. Confirm
y
```

### Common Workflows

#### Workflow 1: Code Review
```vim
" Check what you changed
:GeneroSVNStatus

" Review each change
:GeneroSVNBlame

" Revert mistakes
<leader>sr
```

#### Workflow 2: Debugging
```vim
" Find suspicious line
/calculate_total

" Check when it changed
<leader>sb

" Test reverting it
<leader>sr

" If bug persists, undo
u
```

#### Workflow 3: Cleanup
```vim
" Find debug code
/DISPLAY "DEBUG:

" Revert it
<leader>sr

" Find next
n
<leader>sr
```

## Migrating from Other Tools

### From Git Blame
If you're used to Git blame:

| Git | Genero-Tools SVN |
|-----|------------------|
| `git blame file` | `:GeneroSVNBlame` |
| `git blame -L 10,20 file` | `:10,20GeneroSVNBlameRange` |
| `git checkout -- file` | `:GeneroSVNRevertAllChanges` |
| `git checkout -- file:10,20` | `:10,20GeneroSVNRevertRange` |

### From SVN Command Line
If you're used to SVN commands:

| SVN CLI | Genero-Tools |
|---------|--------------|
| `svn blame file` | `:GeneroSVNBlame` |
| `svn cat file` | (Used internally by revert) |
| `svn revert file` | `:GeneroSVNRevertAllChanges` |
| (No equivalent) | `:GeneroSVNRevertLine` (new!) |

### From Other Vim Plugins
If you're used to other Vim SVN plugins:

| Feature | Genero-Tools |
|---------|--------------|
| Blame annotations | `:GeneroSVNBlame` |
| Revert file | `:GeneroSVNRevertAllChanges` |
| Revert hunk | `:GeneroSVNRevertRange` |
| Revert line | `:GeneroSVNRevertLine` (unique!) |

## Troubleshooting

### Commands Not Found

**Problem:** `:GeneroSVNBlame` says "Not an editor command"

**Solution:**
```vim
" Check if plugin is loaded
:echo exists('g:loaded_genero_tools')
" Should output: 1

" If not, check your plugin manager
:PlugStatus  " For vim-plug
```

### Keybindings Don't Work

**Problem:** `<leader>sb` doesn't do anything

**Solution:**
```vim
" Check what <leader> is
:echo mapleader
" Should output: \ (backslash) or your custom leader

" Check if mapping exists
:nmap <leader>sb
" Should show: GeneroSVNBlameCurrentLine

" Try with explicit leader
\sb
```

### Blame Shows "No SVN"

**Problem:** "SVN not available" error

**Solution:**
```bash
# Check if SVN is installed
svn --version

# If not, install it
# Ubuntu/Debian:
sudo apt-get install subversion

# macOS:
brew install subversion

# Then restart Vim
```

### Revert Doesn't Work

**Problem:** "File not in SVN working copy"

**Solution:**
```vim
" Check if file is in SVN
:!svn info %

" Check if SVN is enabled
:echo g:genero_tools_config.svn_enabled
" Should output: 1

" Enable if needed
:let g:genero_tools_config.svn_enabled = 1
```

### Slow Performance

**Problem:** Blame is slow on large files

**Solution:**
```vim
" Use line blame instead of file blame
<leader>sb  " Just current line

" Or range blame
V
10j
<leader>sb  " Just 10 lines

" Increase cache TTL
let g:genero_tools_config.svn_cache_ttl = 600  " 10 minutes
```

## Best Practices

### 1. Use Blame Before Reverting
```vim
" Check who changed it first
<leader>sb

" Then decide if you should revert
<leader>sr
```

### 2. Use Confirmation for Large Reverts
```vim
" For single lines, direct revert is fine
<leader>sr

" For ranges, use confirmation
V
10j
<leader>sr  " Shows preview
y           " Confirm
```

### 3. Check Status Regularly
```vim
" See what you've changed
:GeneroSVNStatus

" Review before committing
:GeneroSVNBlame
```

### 4. Use Visual Mode
```vim
" Select exactly what you want
V
/end of section
<leader>sb  " Blame selection
<leader>sr  " Revert selection
```

### 5. Leverage Undo
```vim
" Revert is undoable
<leader>sr  " Revert
u           " Undo if wrong
<C-r>       " Redo if right
```

## Tips and Tricks

### Tip 1: Quick Blame Check
```vim
" Map to function key for quick access
nnoremap <F9> :GeneroSVNBlameCurrentLine<CR>
```

### Tip 2: Blame in Status Line
```vim
" Show blame in status line (Neovim)
function! SVNBlameStatusLine()
  let l:blame = genero_tools#svn#blame#get_line_blame(expand('%:p'), line('.'))
  if !empty(l:blame)
    return printf('r%s %s', l:blame.revision, l:blame.author)
  endif
  return ''
endfunction

set statusline+=%{SVNBlameStatusLine()}
```

### Tip 3: Revert Pattern
```vim
" Revert all lines matching a pattern
function! RevertPattern(pattern)
  let l:lines = []
  let l:lnum = 1
  while l:lnum <= line('$')
    if getline(l:lnum) =~ a:pattern
      call add(l:lines, l:lnum)
    endif
    let l:lnum += 1
  endwhile
  call genero_tools#svn#revert#revert_lines(l:lines)
endfunction

" Usage
:call RevertPattern('DISPLAY')
```

### Tip 4: Blame and Revert Together
```vim
" Check blame, then revert if needed
nnoremap <leader>sbr :GeneroSVNBlameCurrentLine<CR>:GeneroSVNRevertLine<CR>
```

### Tip 5: Batch Operations
```vim
" Revert multiple sections
:10,20GeneroSVNRevertRange
:50,60GeneroSVNRevertRange
:100,110GeneroSVNRevertRange
```

## Getting Help

### Documentation
- **[Full Guide](SVN_BLAME_AND_REVERT.md)** - Comprehensive documentation
- **[Quick Reference](SVN_QUICK_REFERENCE.md)** - Command cheat sheet
- **[Examples](SVN_EXAMPLES.md)** - 10 practical examples
- **[Architecture](SVN_ARCHITECTURE.md)** - Technical details

### In Vim
```vim
" List all SVN commands
:command Genero

" Check configuration
:echo g:genero_tools_config

" Check keybindings
:nmap <leader>s
:vmap <leader>s
```

### Common Questions

**Q: Can I revert to a specific revision?**
A: Currently, revert only works with the base (HEAD) revision. Reverting to specific revisions is planned for a future release.

**Q: Does blame work with binary files?**
A: No, SVN blame only works with text files.

**Q: Can I revert deleted lines?**
A: Individual deleted lines cannot be reverted. Use `:GeneroSVNRevertRange` to revert the section.

**Q: Is blame cached?**
A: Yes, blame results are cached using the existing SVN cache system (default 5 minutes).

**Q: Can I use this with Git?**
A: No, these features are specific to SVN. Git support may be added in the future.

## Next Steps

1. **Try the features** - Use `<leader>sb` and `<leader>sr`
2. **Read the examples** - See [SVN_EXAMPLES.md](SVN_EXAMPLES.md)
3. **Customize** - Adjust keybindings if needed
4. **Integrate** - Add to your workflow

## Feedback

If you have suggestions or find issues:
1. Check the [Troubleshooting](#troubleshooting) section
2. Review the [Documentation](#documentation)
3. Report issues on GitHub

## Summary

The new SVN features are:
- ✅ **Easy to use** - Just two keybindings
- ✅ **No setup** - Works with existing config
- ✅ **Well documented** - Comprehensive guides
- ✅ **Safe** - Confirmation and undo support
- ✅ **Fast** - Cached for performance

Start using them today!
