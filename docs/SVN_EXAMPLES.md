# SVN Blame and Revert Examples

Practical examples of using SVN blame and selective revert features.

## Example 1: Finding Who Broke the Build

**Scenario:** The build is broken and you need to find out who made the recent changes.

```vim
" 1. Open the problematic file
:e src/customer.4gl

" 2. Navigate to the error line (let's say line 156)
:156

" 3. Check who last modified this line
<leader>sb
" Output: Line 156: r2345 | bob.jones | 2024-01-22 09:15

" 4. Check the surrounding context
V
5k
5j
<leader>sb
" Shows blame for lines 151-161 in a floating window

" 5. If Bob's change broke it, you can revert just that section
:'<,'>GeneroSVNRevertRangeConfirm
" Preview shows what will change
y  " Confirm the revert

" 6. Test if the build works now
:w
:!fglcomp %
```

## Example 2: Cleaning Up Debug Code

**Scenario:** You added debug print statements throughout a function and want to remove them.

```vim
" 1. Open the file with debug code
:e src/process_order.4gl

" 2. Find the first debug statement
/DISPLAY "DEBUG:

" 3. Revert just this line
<leader>sr
" Output: Reverted line 89 to base version

" 4. Find the next debug statement
n

" 5. Revert this line too
<leader>sr

" 6. Or select all debug lines at once
V
/end of debug section
<leader>sr
y  " Confirm revert

" 7. Verify all debug code is gone
:GeneroSVNStatus
" Output: Shows remaining changes
```

## Example 3: Reverting Experimental Code

**Scenario:** You tried a new approach but want to go back to the original.

```vim
" 1. Check what you changed
:GeneroSVNStatus
" Output:
" Changes:
"   Added lines: 15
"   Modified lines: 8
"   Deleted lines: 3

" 2. Review the changes with blame
:GeneroSVNBlame
" Shows all your recent changes

" 3. Decide to revert the experimental function (lines 100-150)
:100,150GeneroSVNRevertRangeConfirm
" Preview shows:
" Line 105:
"   Current: let new_approach = calculate_fast(x)
"   Base:    let result = calculate_slow(x)
" ...
y  " Confirm revert

" 4. Keep other changes, just revert this section
:w
```

## Example 4: Selective Code Review

**Scenario:** Reviewing your changes before committing.

```vim
" 1. See all your changes
:GeneroSVNStatus
" Output: +12 ~5 -2 changes

" 2. Review each changed section
:GeneroSVNBlame
" Scroll through to see what you changed

" 3. Found a mistake in lines 45-48
:45
V
3j
<leader>sr
y  " Revert the mistake

" 4. Found another issue at line 92
:92
<leader>sr  " Revert just this line

" 5. Verify final changes
:GeneroSVNStatus
" Output: +10 ~4 -2 changes (reduced)

" 6. Commit the cleaned-up changes
:!svn commit -m "Fixed customer processing"
```

## Example 5: Investigating a Bug

**Scenario:** A bug appeared recently and you need to find when it was introduced.

```vim
" 1. Open the file with the bug
:e src/calculate_total.4gl

" 2. Navigate to the buggy calculation
/calculate_discount

" 3. Check when this was last changed
<leader>sb
" Output: Line 234: r2301 | alice.smith | 2024-01-18 14:30

" 4. Check the entire function
V
]]  " Jump to end of function
<leader>sb
" Shows blame for entire function

" 5. See that lines 234-240 were changed in r2301
" 6. Revert those lines to test if that was the bug
:234,240GeneroSVNRevertRangeConfirm
y  " Confirm

" 7. Test the calculation
:!fglcomp % && fglrun %

" 8. Bug is fixed! The revert identified the problem
" 9. Now you can either:
"    a) Keep the revert and commit
"    b) Undo and fix the bug properly
u  " Undo the revert
" Fix the actual bug in the code
```

## Example 6: Merging Manual Changes

**Scenario:** You made changes in two different areas and want to commit them separately.

```vim
" 1. Check all changes
:GeneroSVNStatus
" Output: Changes in lines 50-60 and 150-160

" 2. Commit the first change
" First, revert the second change temporarily
:150,160GeneroSVNRevertRange

" 3. Commit the first change
:!svn commit -m "Feature A: Added validation"

" 4. Undo the revert to restore the second change
u

" 5. Now commit the second change
:!svn commit -m "Feature B: Improved performance"
```

## Example 7: Comparing with Base Version

**Scenario:** You want to see exactly what changed in a section.

```vim
" 1. Select the section you're interested in
V
10j

" 2. Show blame to see who changed what
<leader>sb
" Output shows different authors for different lines

" 3. Preview what reverting would do
:'<,'>GeneroSVNRevertRangeConfirm
" Shows side-by-side comparison:
" Line 45:
"   Current: if status = "A" or status = "B" then
"   Base:    if status = "A" then

" 4. Decide not to revert
n  " Cancel

" 5. Keep your changes
```

## Example 8: Recovering from Accidental Changes

**Scenario:** You accidentally modified lines while navigating.

```vim
" 1. Notice unexpected SVN markers
" See yellow ~ markers in sign column

" 2. Check what changed
:GeneroSVNStatus
" Output: ~3 modified lines

" 3. Don't remember changing anything
" Check the specific lines
:GeneroSVNBlame

" 4. Revert all accidental changes
:GeneroSVNRevertAllChanges
" Prompt: Revert all changes in this file? (y/n):
y

" 5. Verify everything is back to normal
:GeneroSVNStatus
" Output: No changes
```

## Example 9: Working with Multiple Files

**Scenario:** You changed several files and want to selectively revert.

```vim
" 1. Open first file
:e src/customer.4gl
:GeneroSVNStatus
" Decide to keep these changes

" 2. Open second file
:e src/order.4gl
:GeneroSVNStatus
" Want to revert some changes here

" 3. Revert specific lines
:50,75GeneroSVNRevertRangeConfirm
y

" 4. Open third file
:e src/invoice.4gl
:GeneroSVNStatus
" Revert everything in this file
:GeneroSVNRevertAllChanges
y

" 5. Review all files
:!svn status
" Shows which files still have changes
```

## Example 10: Using with Vim Diff

**Scenario:** Combine SVN revert with Vim's diff mode for detailed comparison.

```vim
" 1. Open your modified file
:e src/report.4gl

" 2. Open a vertical split with the base version
:vnew
:r !svn cat #
:1d  " Delete empty first line

" 3. Enter diff mode
:windo diffthis

" 4. Navigate through differences
]c  " Next difference
[c  " Previous difference

" 5. Decide which changes to keep
" Switch to the modified file
<C-w>h

" 6. Revert specific sections
:100,120GeneroSVNRevertRange

" 7. Exit diff mode
:windo diffoff

" 8. Close the base version
:q
```

## Tips and Tricks

### Quick Blame Check
```vim
" Map a quick blame check to a function key
nnoremap <F9> :GeneroSVNBlameCurrentLine<CR>

" Now just press F9 to see who changed the current line
```

### Revert with Undo Safety
```vim
" Always use the confirm version for safety
vnoremap <leader>sR :GeneroSVNRevertRangeConfirm<CR>

" If you revert by mistake, just undo
u
```

### Blame in Status Line
```vim
" Show blame info in status line (Neovim)
function! SVNBlameStatusLine()
  let l:blame = genero_tools#svn#blame#get_line_blame(expand('%:p'), line('.'))
  if !empty(l:blame)
    return printf('r%s %s', l:blame.revision, l:blame.author)
  endif
  return ''
endfunction

set statusline+=%{SVNBlameStatusLine()}
```

### Batch Revert Pattern
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
  
  if !empty(l:lines)
    call genero_tools#svn#revert#revert_lines(l:lines)
    echo 'Reverted ' . len(l:lines) . ' lines'
  endif
endfunction

" Usage: Revert all lines with DISPLAY statements
:call RevertPattern('DISPLAY')
```

## Common Patterns

### Before Committing
```vim
:GeneroSVNStatus        " Check what changed
:GeneroSVNBlame         " Review who changed what
" Revert any mistakes
:!svn commit -m "..."   " Commit
```

### During Code Review
```vim
<leader>sb              " Check line author
V                       " Select section
<leader>sb              " Check section authors
<leader>sr              " Revert if needed
```

### Debugging
```vim
/DEBUG                  " Find debug code
<leader>sr              " Revert debug line
n                       " Next occurrence
<leader>sr              " Revert next debug line
```

### Cleanup
```vim
:GeneroSVNRevertAllChanges  " Start fresh
u                           " Undo if needed
```
