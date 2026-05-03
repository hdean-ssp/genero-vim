# Genero-Tools Plugin Demo

A walkthrough of the plugin's key features for Genero development in Vim/Neovim.
Target audience: developers on the team. Keep each section to ~1 minute.

---

## 1. Zero to Running (Setup)

Show that a new developer can be productive in under 2 minutes.

```bash
# Install
Plug 'hdean-ssp/genero-vim'    # add to config, :PlugInstall

# Copy the example config and go
cp init.lua.example ~/.config/nvim/init.lua
```

Open any `.4gl` file — everything works out of the box. No configuration required.

---

## 2. Write Code Faster

### Auto-Close Blocks

Type a block opener and press Enter — the matching `END` statement is inserted
automatically with correct indentation.

```
IF l_count > 0 THEN<Enter>
```

Produces:

```4gl
IF l_count > 0 THEN
    |                    ← cursor here
END IF
```

Works for all 12+ Genero block types: `IF`, `FOR`, `WHILE`, `CASE`, `FUNCTION`,
`MAIN`, `REPORT`, `MENU`, `INPUT`, `DIALOG`, `CONSTRUCT`, `FOREACH`.

### Code Snippets (Neovim)

Type a trigger and press `Tab` to expand. `Tab`/`Shift+Tab` navigates placeholders.

| Trigger | Result |
|---------|--------|
| `fn`    | Full `FUNCTION ... END FUNCTION` skeleton |
| `if`    | `IF ... THEN ... END IF` |
| `for`   | `FOR` loop with counter |
| `try`   | `TRY ... CATCH ... END TRY` |
| `rec`   | `RECORD` definition |
| `arr`   | Array declaration |

Smart parameter population: snippets query function signatures and fill in
parameter names and types automatically.

### Intelligent Autocomplete

Start typing a function name and press `Ctrl+N`:

- Prioritizes functions in the current module
- Falls back to project-wide search
- Shows parameter signatures in the completion menu
- Cached for speed on large codebases

---

## 3. Catch Errors Without Leaving the Editor

### Autocompile on Save

Save a file → the compiler runs automatically → errors and warnings appear
instantly. No manual compile step.

What you see:
- **Sign column**: `✕` (error, red) and `⚠` (warning, yellow) markers
- **Inline diagnostics** (Neovim): error text appears as virtual text on the
  affected line — no need to open the quickfix list
- **Unused variable highlighting**: all occurrences highlighted in yellow

Navigate errors:
```
Ctrl+,    previous error
Ctrl+.    next error
F5        manual compile
```

### Compiler Diagnostics via Telescope

`:GeneroDiagnostics` opens a Telescope picker with all errors and warnings.
Filter, fuzzy-search, and preview the error location before jumping.

---

## 4. Navigate a Large Codebase

Designed for codebases with thousands of files and 6M+ lines of code.

### Go to Definition / Peek

```
gd        jump to the function definition (opens the file)
gp        peek definition in a floating window (stay where you are)
```

### Find References

```
gr        find all callers of the function under the cursor (Telescope picker)
```

### Telescope Pickers

```
<space>gF    file functions — browse all functions in the current file
<space>gM    module functions — browse all functions in the current module
<space>gS    module sibling files — switch between files in the same module
```

All pickers include a live file preview so you see context before jumping.

### Function Signature on Hover (Neovim)

Move the cursor to a function call — its signature appears as faded virtual text
at the end of the line. Variable types are resolved from `DEFINE` statements.
No keypress needed.

---

## 5. Keep Code Clean

### Real-Time Code Hints

The hints system runs as you type and flags quality issues:

- Trailing whitespace, mixed indentation
- Inconsistent keyword casing
- Excessive nesting depth, long lines
- Deprecated function usage

Hints appear in the sign column (`◆`) and optionally as virtual text.

### One-Key Auto-Fix

Cursor on a hint → `<space>hf` → the issue is fixed in place.

```
<space>hn    next hint
<space>hp    previous hint
<space>hl    list all hints in the file
<space>hd    show hint details
<space>hf    apply auto-fix
```

Every check is individually toggleable in the config.

---

## 6. Track Changes at a Glance

### SVN Diff Markers

Open a file in an SVN working copy and the sign column shows what changed:

```
+   added line      (green)
~   modified line   (yellow)
-   deleted line    (red)
```

Markers load automatically, refresh on save, and are cached for performance.

### Unified Sign Column

Compiler markers and SVN markers share a single sign column — no wasted screen
space. Toggle with `<space>su`.

### Statusline Breadcrumb

The statusline shows your current context at all times:

```
module.m3 › file.4gl › ƒ my_function    E2 W1    +3 ~5 -1
```

Module, file, current function, error/warning counts, and SVN change counts —
all updated in real-time as you move the cursor.

---

## 7. Keyword Highlighting

`TODO`, `BUG`, `FIX`, `HACK`, `WARN`, `NOTE`, `TMP` tags are highlighted in
code and comments. User-specific temp tags (`#TMP<initials>` derived from
`$USER`) are also detected, with `]]`/`[[` to jump between them.

---

## Quick Reference Card

| Key | Action |
|-----|--------|
| `F5` | Compile |
| `Ctrl+,` / `Ctrl+.` | Prev / next error |
| `Ctrl+N` | Autocomplete |
| `gd` | Go to definition |
| `gp` | Peek definition |
| `gr` | Find references |
| `<space>gF` | File functions (Telescope) |
| `<space>gM` | Module functions (Telescope) |
| `<space>hf` | Auto-fix hint |
| `<space>sv` | Toggle SVN markers |
| `<space>su` | Toggle unified signs |
| `<space>cD` | Diagnostics (Telescope) |

---

## Compatibility

All core features work in Vim 7+. Neovim unlocks:
- Inline diagnostics (virtual text)
- Floating windows and Telescope pickers
- Code snippets with smart expansion
- Function signature hover
- Breadcrumb winbar
- Async compilation

The plugin auto-detects the environment and enables what's available.
