# Getting Started with Genero-Tools

A step-by-step guide to help you discover and use all the features of the Genero-Tools plugin and Neovim configuration. This guide is designed for developers familiar with Vim but new to Neovim and modern IDE-like features.

---

## Table of Contents

1. [Installation and First Launch](#1-installation-and-first-launch)
2. [Understanding the Interface](#2-understanding-the-interface)
3. [Writing Code Faster](#3-writing-code-faster)
4. [Navigating Your Codebase](#4-navigating-your-codebase)
5. [Finding and Fixing Errors](#5-finding-and-fixing-errors)
6. [Code Quality and Hints](#6-code-quality-and-hints)
7. [Version Control Integration](#7-version-control-integration)
8. [Advanced Features](#8-advanced-features)
9. [Customization](#9-customization)
10. [Quick Reference](#10-quick-reference)

---

## 1. Installation and First Launch

### Step 1.1: Install the Plugin

Add to your Neovim plugin manager (vim-plug example):

```vim
Plug 'hdean-ssp/genero-vim'
```

Then run `:PlugInstall` in Neovim.

### Step 1.2: Copy the Example Configuration

The plugin includes a complete Neovim configuration that sets up everything:

```bash
cp init.lua.example ~/.config/nvim/init.lua
```

**What this gives you:**
- Pre-configured keybindings optimized for Genero development
- Curated set of complementary plugins (Telescope, terminal, etc.)
- Sensible defaults for code editing
- Modern UI with floating windows and notifications

### Step 1.3: First Launch

Open any `.4gl` file:

```bash
nvim myfile.4gl
```

**What happens on first launch:**
- Lazy.nvim (plugin manager) installs automatically
- All plugins download and install (takes 1-2 minutes)
- Configuration loads with no errors
- You're ready to code!

**Tip:** If you see plugin installation messages, wait for them to complete, then restart Neovim.

---

## 2. Understanding the Interface

### Step 2.1: The Sign Column (Left Side)

The sign column shows important information at a glance:

```
│ ✕  │  Error on this line (red)
│ ⚠  │  Warning on this line (yellow)
│ ◆  │  Code quality hint (blue)
│ +  │  Line added (SVN, green)
│ ~  │  Line modified (SVN, yellow)
│ -  │  Line deleted (SVN, red)
```

**Try it:** Open a file with errors or in an SVN working copy to see these markers.

### Step 2.2: The Statusline (Bottom)

The statusline shows your current context:

```
module.m3 › file.4gl › ƒ calculate_total    E2 W1    +3 ~5 -1
└─────────┘ └────────┘   └──────────────┘   └────┘   └────────┘
  module      file       current function   errors   SVN changes
```

**Try it:** Move your cursor between functions and watch the function name update in real-time.

### Step 2.3: Virtual Text (Inline Information)

Neovim can display extra information directly in your code without modifying the file:

- **Function signatures:** Hover over a function call to see its parameters
- **Variable types:** See the type of variables from their DEFINE statements
- **Inline diagnostics:** Error messages appear at the end of the line
- **Code hints:** Quality suggestions appear as faded text

**Try it:** Move your cursor to a function call and wait a moment - you'll see its signature appear.

### Step 2.4: Floating Windows

Instead of splitting your screen, many features use floating windows that appear on top of your code:

- Definition previews
- Error details
- Reference lists
- Help documentation

**Try it:** Press `<space>` and pause - a floating window shows available keybindings.

---

## 3. Writing Code Faster

### Step 3.1: Auto-Close Blocks

Type a block opener and press Enter - the matching `END` statement appears automatically:

**Try it:**
1. Type: `IF l_count > 0 THEN`
2. Press: `Enter`
3. Result:
```4gl
IF l_count > 0 THEN
    |                    ← cursor here, ready to type
END IF
```

**Works for all Genero blocks:**
- `IF ... END IF`
- `FOR ... END FOR`
- `WHILE ... END WHILE`
- `CASE ... END CASE`
- `FUNCTION ... END FUNCTION`
- `MAIN ... END MAIN`
- `REPORT ... END REPORT`
- `MENU ... END MENU`
- `INPUT ... END INPUT`
- `DIALOG ... END DIALOG`
- `CONSTRUCT ... END CONSTRUCT`
- `FOREACH ... END FOREACH`

### Step 3.2: Code Snippets

Snippets are templates that expand into full code blocks. Type a trigger word and press `Tab`:

**Try these snippets:**

1. **Function skeleton:**
   - Type: `fn`
   - Press: `Tab`
   - Result: Full function with placeholders for name, parameters, and body
   - Press: `Tab` to jump between placeholders

2. **IF statement:**
   - Type: `if`
   - Press: `Tab`
   - Result: `IF ... THEN ... END IF` with cursor on condition

3. **FOR loop:**
   - Type: `for`
   - Press: `Tab`
   - Result: Complete FOR loop with counter variable

4. **TRY-CATCH:**
   - Type: `try`
   - Press: `Tab`
   - Result: Full error handling block

**Common snippets:**

| Trigger | Expands to |
|---------|-----------|
| `fn` | Function definition |
| `if` | IF statement |
| `for` | FOR loop |
| `while` | WHILE loop |
| `case` | CASE statement |
| `try` | TRY-CATCH block |
| `rec` | RECORD definition |
| `arr` | Array declaration |
| `cur` | CURSOR declaration |
| `prep` | PREPARE statement |

**Navigation:**
- `Tab` - Jump to next placeholder
- `Shift+Tab` - Jump to previous placeholder

### Step 3.3: Intelligent Autocomplete

Get function name suggestions as you type:

**Try it:**
1. Start typing a function name: `calc`
2. Press: `Ctrl+N`
3. See: A menu with matching functions from your codebase
4. Use: Arrow keys or `Ctrl+N`/`Ctrl+P` to navigate
5. Press: `Enter` to select

**What you see in the completion menu:**
- Function name
- Parameter signature
- Module location
- Return type (if available)

**Smart features:**
- Prioritizes functions in your current module
- Searches entire codebase if needed
- Cached for speed on large projects
- Shows parameter types from function definitions

---

## 4. Navigating Your Codebase

Modern IDEs have "Go to Definition" and "Find References" - now you do too.

### Step 4.1: Go to Definition

Jump directly to where a function or variable is defined:

**Try it:**
1. Move cursor to a function name (e.g., in a `CALL` statement)
2. Press: `gd`
3. Result: Jumps to the function definition (opens the file if needed)

**What it does:**
- Searches your entire codebase
- Opens the file containing the definition
- Positions cursor on the FUNCTION line
- Adds position to jump list (press `Ctrl+O` to go back)

### Step 4.2: Peek Definition

Preview a definition without leaving your current location:

**Try it:**
1. Move cursor to a function name
2. Press: `gp`
3. Result: Floating window shows the function definition
4. Press: `Esc` to close

**When to use:**
- Quick reference to check parameters
- See implementation without losing your place
- Review multiple functions quickly

### Step 4.3: Find References (Smart Detection)

Find all places where a function or variable is used:

**Try it:**
1. Move cursor to a function name or variable
2. Press: `gr`
3. Result: Telescope picker shows all references
4. Type to filter results
5. Press: `Enter` to jump to a reference

**Smart detection:**
- On a **function name**: Searches entire codebase for all callers
- On a **variable**: Searches current buffer with scope awareness
  - Local variables: Only searches current function
  - Module variables (m_*): Searches entire file
  - Global variables (gl_*): Searches entire file

**Example:**
```4gl
CALL calculate_total(l_sum, m_config)
     ^^^^^^^^^^^^^^^  ^^^^^  ^^^^^^^^
     gr → function    gr → local var  gr → module var
     (all callers)    (in function)   (in file)
```

**Telescope picker features:**
- Fuzzy search through results
- Live preview pane shows context
- Navigate with `j`/`k` or `Ctrl+N`/`Ctrl+P`
- Press `Esc` to cancel

### Step 4.4: Browse Functions in Current File

See all functions in the file you're editing:

**Try it:**
1. Press: `<space>gF`
2. Result: Telescope picker lists all functions
3. Type to filter by name
4. Preview shows function location
5. Press: `Enter` to jump

**When to use:**
- Navigate large files quickly
- Find a function by name
- Get an overview of file structure

### Step 4.5: Browse Functions in Current Module

See all functions across all files in your module:

**Try it:**
1. Press: `<space>gM`
2. Result: Telescope picker lists all module functions
3. Shows which file each function is in
4. Preview shows function definition
5. Press: `Enter` to jump (opens file if needed)

**When to use:**
- Navigate multi-file modules
- Find related functions
- Understand module structure

### Step 4.6: Switch Between Module Files

Quickly switch between files in the same module:

**Try it:**
1. Press: `<space>gS`
2. Result: Telescope picker lists all files in module
3. Current file marked with `●`
4. Preview shows file contents
5. Press: `Enter` to switch

**When to use:**
- Navigate between related files
- Switch between implementation files
- Explore module structure

---

## 5. Finding and Fixing Errors

Catch compilation errors without leaving the editor.

### Step 5.1: Manual Compilation

Compile the current file on demand:

**Try it:**
1. Press: `F5`
2. Result: File compiles in background
3. Errors/warnings appear in sign column
4. Inline diagnostics show on affected lines

**What you see:**
- `✕` Red markers for errors
- `⚠` Yellow markers for warnings
- Error text as faded virtual text at end of line
- Unused variables highlighted in yellow

### Step 5.2: Auto-Compile on Save

Enable automatic compilation every time you save:

**Try it:**
1. Run: `:GeneroAutocompileEnable`
2. Make a change and save: `:w`
3. Result: File compiles automatically
4. Errors appear within 1-2 seconds

**When to use:**
- Catch errors as you code
- Get immediate feedback
- Reduce manual compile steps

**Disable:** `:GeneroAutocompileDisable`

### Step 5.3: Navigate Between Errors

Jump between errors without opening the quickfix list:

**Try it:**
1. Press: `]d` or `Ctrl+.` (next error)
2. Press: `[d` or `Ctrl+,` (previous error)
3. Result: Cursor jumps to error location
4. Error details shown in virtual text

**Workflow:**
1. Compile with `F5`
2. Jump to first error with `]d`
3. Fix the error
4. Jump to next error with `]d`
5. Repeat until all errors fixed

### Step 5.4: Browse All Diagnostics

View all errors and warnings in a searchable list:

**Try it:**
1. Press: `<space>cD`
2. Result: Telescope picker shows all diagnostics
3. Type to filter by error message
4. Preview shows error location
5. Press: `Enter` to jump

**Filter options:**
- `:GeneroDiagnostics` - All errors and warnings
- `:GeneroDiagnosticsErrors` - Errors only
- `:GeneroDiagnosticsWarnings` - Warnings only

**When to use:**
- Get overview of all issues
- Search for specific error types
- Prioritize which errors to fix

### Step 5.5: Clear Error Markers

Remove error markers from the sign column:

**Try it:**
1. Press: `<space>cc`
2. Result: All error markers cleared
3. Compile again to refresh

**When to use:**
- Clear stale errors after fixing
- Clean up display
- Start fresh after major changes

---

## 6. Code Quality and Hints

Automated code quality checks that run as you type.

### Step 6.1: Understanding Hints

Hints flag code quality issues in real-time:

**Types of hints:**
- **Whitespace:** Trailing spaces, mixed tabs/spaces
- **Style:** Inconsistent keyword casing, long lines
- **Structure:** Excessive nesting, complex functions
- **Best practices:** Deprecated functions, unused variables

**What you see:**
- `◆` Blue marker in sign column
- Optional virtual text with hint message
- Hint details on demand

### Step 6.2: Navigate Between Hints

Jump between code quality issues:

**Try it:**
1. Press: `]h` (next hint)
2. Press: `[h` (previous hint)
3. Result: Cursor jumps to hint location

**Alternative:**
- `<space>hn` - Next hint (also works)
- `<space>hp` - Previous hint (also works)

### Step 6.3: View Hint Details

See detailed information about a hint:

**Try it:**
1. Move cursor to a line with a hint marker
2. Press: `<space>hd`
3. Result: Floating window shows:
   - What the issue is
   - Why it matters
   - How to fix it
   - Severity level

### Step 6.4: Auto-Fix Hints

Many hints can be fixed automatically:

**Try it:**
1. Move cursor to a line with a hint
2. Press: `<space>hf`
3. Result: Issue fixed automatically

**Auto-fixable hints:**
- Remove trailing whitespace
- Fix keyword casing
- Normalize indentation
- Add missing spaces

**Example:**
```4gl
if l_count>0 then    ← inconsistent casing, no spaces
```
Press `<space>hf`:
```4gl
IF l_count > 0 THEN  ← fixed!
```

### Step 6.5: List All Hints

See all hints in the current file:

**Try it:**
1. Press: `<space>hl`
2. Result: List of all hints with line numbers
3. Navigate with `j`/`k`
4. Press: `Enter` to jump to hint

**When to use:**
- Get overview of code quality
- Prioritize which issues to fix
- Clean up file before commit

---

## 7. Version Control Integration

See what changed in your SVN working copy without leaving the editor.

### Step 7.1: SVN Diff Markers

Visual indicators show modified lines:

**What you see:**
- `+` Green marker - Line added
- `~` Yellow marker - Line modified
- `-` Red marker - Line deleted

**Try it:**
1. Open a file in an SVN working copy
2. Make a change and save
3. Result: Markers appear automatically

**Features:**
- Updates automatically on save
- Cached for performance
- Works alongside compiler markers

### Step 7.2: Toggle SVN Markers

Show or hide SVN diff markers:

**Try it:**
1. Press: `<space>sv`
2. Result: SVN markers toggle on/off

**When to use:**
- Reduce visual clutter
- Focus on code without distractions
- Temporarily disable for screenshots

### Step 7.3: Refresh SVN Status

Manually update SVN markers:

**Try it:**
1. Press: `<space>sr`
2. Result: SVN status refreshed from disk

**When to use:**
- After SVN update/commit
- After external file changes
- Force refresh if markers seem stale

### Step 7.4: Unified Sign Column

Compiler and SVN markers share one column:

**Priority order:**
1. Errors (highest priority)
2. Warnings
3. Hints
4. SVN changes (lowest priority)

**Try it:**
1. Press: `<space>su`
2. Result: Toggle unified sign column on/off

**When unified is off:**
- Separate columns for compiler and SVN
- More screen space used
- All markers always visible

---

## 8. Advanced Features

### Step 8.1: Inline Terminal

Run shell commands without leaving Neovim:

**Try it:**
1. Press: `Ctrl+\`
2. Result: Terminal opens in horizontal split
3. Type shell commands normally
4. Press: `Ctrl+\` again to close

**Navigation:**
- `Ctrl+h/j/k/l` - Move between terminal and code windows
- `Ctrl+\` - Toggle terminal visibility

**When to use:**
- Run builds or tests
- Execute SVN commands
- Check logs or file contents
- Run database queries

**Tip:** The terminal sources your login shell, so `$FGLDIR`, `$BRODIR`, and other environment variables work automatically.

### Step 8.2: Fuzzy File Finding

Find files by name across your entire project:

**Try it:**
1. Press: `<space>ff`
2. Type part of a filename
3. Result: Matching files appear
4. Preview shows file contents
5. Press: `Enter` to open

**Features:**
- Fuzzy matching (type `usrep` to find `user_report.4gl`)
- Searches entire project
- Respects `.gitignore`
- Fast even on large codebases

### Step 8.3: Live Grep (Search in Files)

Search for text across all files:

**Try it:**
1. Press: `<space>fg`
2. Type search term
3. Result: Live results as you type
4. Shows file, line number, and context
5. Press: `Enter` to jump

**When to use:**
- Find where a variable is used
- Search for error messages
- Find TODO comments
- Locate specific code patterns

### Step 8.4: Search Word Under Cursor

Quickly search for the word under cursor:

**Try it:**
1. Move cursor to a word
2. Press: `<space>fw`
3. Result: Searches all files for that word
4. Shows results in Telescope picker

**When to use:**
- Find all uses of a constant
- Search for error codes
- Find similar variable names

### Step 8.5: Buffer Switching

Switch between open files:

**Try it:**
1. Press: `]b` (next buffer)
2. Press: `[b` (previous buffer)
3. Result: Cycles through open buffers with wrapping

**Alternative with Telescope:**
1. Press: `<space>fb`
2. Result: List of open buffers
3. Type to filter by filename
4. Preview shows buffer contents
5. Press: `Enter` to switch

**When to use:**
- `]b`/`[b` - Quick cycling between recent files
- `<space>fb` - Find specific buffer by name

### Step 8.6: Comment Toggle

Quickly comment/uncomment lines:

**Try it:**
1. Move cursor to a line
2. Press: `gcc`
3. Result: Line commented with `#`
4. Press: `gcc` again to uncomment

**Visual mode:**
1. Select multiple lines with `V`
2. Press: `gc`
3. Result: All selected lines commented

**When to use:**
- Temporarily disable code
- Comment out debug statements
- Document code sections

### Step 8.7: Keyword Highlighting

Special keywords are highlighted automatically:

**Highlighted keywords:**
- `TODO` - Things to do
- `BUG` - Known bugs
- `FIX` - Things to fix
- `HACK` - Temporary workarounds
- `WARN` - Warnings
- `NOTE` - Important notes
- `TMP` - Temporary code
- `#TMP<initials>` - User-specific temp code (from `$USER`)

**Try it:**
1. Type: `# TODO: implement error handling`
2. Result: `TODO` highlighted in yellow with icon

**Navigate temp tags:**
- `]]` - Jump to next temp tag (wraps to beginning)
- `[[` - Jump to previous temp tag (wraps to end)

**Search all tags:**
1. Run: `:TodoTelescope`
2. Result: All TODO/BUG/etc tags in Telescope picker

---

## 9. Customization

### Step 9.1: Keybinding Discovery

Don't memorize keybindings - discover them as you go:

**Try it:**
1. Press: `<space>`
2. Wait 1 second
3. Result: Popup shows all available keybindings
4. Press a key to execute or `Esc` to cancel

**Keybinding groups:**
- `<space>c` - Compiler commands
- `<space>g` - Genero-Tools (goto, lookup)
- `<space>h` - Hints (code quality)
- `<space>s` - SVN/Signs/Snippets
- `<space>f` - Find/Search (Telescope)
- `<space>l` - LSP (if enabled)
- `<space>b` - Buffers

### Step 9.2: Change Color Scheme

The default theme is **Thorn** (minimal dark green). Try alternatives:

**Try it:**
1. Open: `~/.config/nvim/init.lua`
2. Find the theme section (around line 100)
3. Comment out Thorn, uncomment another theme
4. Restart Neovim

**Available themes:**
- **Thorn** (default) - Minimal dark green
- **Tokyonight** - Popular dark blue
- **Catppuccin** - Warm pastels
- **Gruvbox** - Retro warm colors

### Step 9.3: Configure Compiler

Customize compiler behavior:

**Edit:** `~/.config/nvim/init.lua`

**Common settings:**
```lua
vim.g.genero_tools_config = {
  compiler_enabled = 1,              -- Enable compiler integration
  compiler_autocompile = 0,          -- Auto-compile on save (0=off, 1=on)
  compiler_autocompile_delay = 1000, -- Delay before compile (ms)
  compiler_show_warnings = 1,        -- Show warnings (0=off, 1=on)
  compiler_show_errors = 1,          -- Show errors (0=off, 1=on)
  compiler_inline_diagnostics = 1,   -- Inline error text (0=off, 1=on)
  compiler_sign_column = 1,          -- Sign column markers (0=off, 1=on)
}
```

### Step 9.4: Configure Hints

Enable/disable specific hint checks:

**Edit:** `~/.config/nvim/init.lua`

**Example:**
```lua
vim.g.genero_tools_config = {
  hints_enabled = 1,                 -- Enable hints system
  hints_whitespace = 1,              -- Check trailing whitespace
  hints_keyword_case = 1,            -- Check keyword casing
  hints_line_length = 1,             -- Check long lines
  hints_nesting_depth = 1,           -- Check excessive nesting
}
```

### Step 9.5: Configure SVN

Customize SVN diff markers:

**Edit:** `~/.config/nvim/init.lua`

**Example:**
```lua
vim.g.genero_tools_config = {
  svn_enabled = 1,                   -- Enable SVN integration
  svn_show_added = 1,                -- Show added lines
  svn_show_modified = 1,             -- Show modified lines
  svn_show_deleted = 1,              -- Show deleted lines
  svn_auto_update = 1,               -- Auto-update on save
  svn_cache_ttl = 300,               -- Cache duration (seconds)
}
```

---

## 10. Quick Reference

### Essential Keybindings

| Key | Action | Description |
|-----|--------|-------------|
| **Compilation** |||
| `F5` | Compile | Compile current file |
| `]d` or `Ctrl+.` | Next error | Jump to next error |
| `[d` or `Ctrl+,` | Prev error | Jump to previous error |
| `<space>cc` | Clear errors | Remove error markers |
| `<space>cD` | Diagnostics | Browse all errors (Telescope) |
| **Navigation** |||
| `gd` | Go to definition | Jump to function definition |
| `gp` | Peek definition | Preview definition in popup |
| `gr` | Find references | Find all references (smart) |
| `gR` | Function references | Find function callers explicitly |
| `<space>gF` | File functions | Browse functions in file |
| `<space>gM` | Module functions | Browse functions in module |
| `<space>gS` | Module files | Switch between module files |
| `]b` | Next buffer | Next open file (wrap) |
| `[b` | Prev buffer | Previous open file (wrap) |
| **Code Quality** |||
| `]h` | Next hint | Jump to next hint |
| `[h` | Prev hint | Jump to previous hint |
| `<space>hn` | Next hint | Jump to next hint (alt) |
| `<space>hp` | Prev hint | Jump to previous hint (alt) |
| `<space>hl` | List hints | Show all hints |
| `<space>hd` | Hint details | Show hint information |
| `<space>hf` | Auto-fix | Fix hint automatically |
| **SVN** |||
| `<space>sv` | Toggle SVN | Show/hide SVN markers |
| `<space>sr` | Refresh SVN | Update SVN status |
| `<space>su` | Unified signs | Toggle unified sign column |
| **Search** |||
| `<space>ff` | Find files | Fuzzy file finder |
| `<space>fg` | Live grep | Search in all files |
| `<space>fw` | Search word | Search word under cursor |
| `<space>fb` | Buffers | Switch between open files |
| **Editing** |||
| `Ctrl+N` | Autocomplete | Show completion menu |
| `Tab` | Next placeholder | Jump to next snippet field |
| `Shift+Tab` | Prev placeholder | Jump to previous snippet field |
| `gcc` | Toggle comment | Comment/uncomment line |
| `gc` (visual) | Toggle comment | Comment/uncomment selection |
| **Temp Tags** |||
| `]]` | Next temp tag | Jump to next #TMP tag (wrap) |
| `[[` | Prev temp tag | Jump to previous #TMP tag (wrap) |
| **Terminal** |||
| `Ctrl+\` | Toggle terminal | Show/hide terminal |
| `Ctrl+h/j/k/l` | Navigate | Move between windows |
| **General** |||
| `<space>` | Which-key | Show keybinding menu |
| `:w` | Save | Save file |
| `:q` | Quit | Quit Neovim |
| `Ctrl+O` | Jump back | Return to previous location |
| `Ctrl+I` | Jump forward | Go to next location |

### Common Commands

| Command | Description |
|---------|-------------|
| `:GeneroCompile` | Compile current file |
| `:GeneroAutocompileEnable` | Enable auto-compile on save |
| `:GeneroAutocompileDisable` | Disable auto-compile |
| `:GeneroGotoDefinition` | Go to definition |
| `:GeneroPeekDefinition` | Peek definition |
| `:GeneroFindReferences` | Find function references |
| `:GeneroFindVariableReferences` | Find variable references |
| `:GeneroFindSmartReferences` | Smart reference detection |
| `:GeneroFileFunctions` | Browse file functions |
| `:GeneroModuleFunctions` | Browse module functions |
| `:GeneroModuleFiles` | Browse module files |
| `:GeneroDiagnostics` | Show all diagnostics |
| `:GeneroDiagnosticsErrors` | Show errors only |
| `:GeneroDiagnosticsWarnings` | Show warnings only |
| `:GeneroClearErrors` | Clear error markers |
| `:GeneroNextHint` | Jump to next hint |
| `:GeneroPrevHint` | Jump to previous hint |
| `:GeneroListHints` | List all hints |
| `:GeneroHintDetails` | Show hint details |
| `:GeneroHintAutofix` | Apply auto-fix |
| `:GeneroSVNToggle` | Toggle SVN markers |
| `:GeneroSVNRefresh` | Refresh SVN status |
| `:GeneroSnippetList` | List available snippets (Telescope) |
| `:GeneroSnippetsTelescope` | List snippets (explicit Telescope) |
| `:TodoTelescope` | Search TODO/BUG tags |

### Snippet Triggers

| Trigger | Expands to |
|---------|-----------|
| `fn` | Function definition |
| `if` | IF statement |
| `for` | FOR loop |
| `while` | WHILE loop |
| `case` | CASE statement |
| `try` | TRY-CATCH block |
| `rec` | RECORD definition |
| `arr` | Array declaration |
| `cur` | CURSOR declaration |
| `prep` | PREPARE statement |
| `exec` | EXECUTE statement |
| `open` | OPEN cursor |
| `fetch` | FETCH cursor |
| `close` | CLOSE cursor |

---

## Compatibility Notes

### Vim vs Neovim

**All core features work in Vim 7+:**
- Function lookup and navigation
- Compilation and error detection
- Code hints and auto-fix
- SVN integration
- Auto-close blocks

**Neovim unlocks additional features:**
- Inline diagnostics (virtual text)
- Floating windows and popups
- Telescope pickers with live preview
- Code snippets with smart expansion
- Function signature hover
- Breadcrumb in statusline/winbar
- Async compilation (non-blocking)
- Modern UI (Noice, Notify)

The plugin auto-detects your environment and enables what's available.

### Recommended Neovim Version

- **Minimum:** Neovim 0.9.0
- **Recommended:** Neovim 0.10.0 or later

Check your version: `nvim --version`

---

## Getting Help

### Built-in Help

- `:help genero-tools` - Plugin documentation
- `<space>` then wait - Show keybinding menu
- `:GeneroSnippetHelp` - Snippet documentation

### Common Issues

**Plugins not loading:**
- Restart Neovim after first install
- Run `:Lazy sync` to update plugins

**Keybindings not working:**
- Check if another plugin is using the same key
- Run `:map gr` to see what `gr` is mapped to

**Compilation not working:**
- Ensure `fglcomp` is in your `$PATH`
- Check `$FGLDIR` is set correctly
- Run `:GeneroCompile` manually to see errors

**Telescope not working:**
- Ensure Telescope is installed: `:Lazy`
- Check for errors: `:messages`

**SVN markers not showing:**
- Ensure file is in SVN working copy
- Run `:GeneroSVNRefresh` to force update
- Check `:GeneroSVNToggle` is enabled

### Support

- GitHub Issues: https://github.com/hdean-ssp/genero-vim/issues
- Documentation: See `docs/` folder in plugin directory

---

## Next Steps

Now that you've learned the basics:

1. **Practice the keybindings** - Use them daily until they become muscle memory
2. **Explore Telescope** - It's powerful for navigation and search
3. **Customize your config** - Adjust colors, keybindings, and features to your preference
4. **Learn the snippets** - They'll save you significant typing time
5. **Enable auto-compile** - Catch errors as you code

**Pro tip:** Keep this guide open in a split while you code for the first few days. Press `<space>` whenever you forget a keybinding!

Happy coding! 🚀
