# Neovim Lua Layer Architecture

## Overview

The vim-genero-tools plugin maintains VimScript as its primary interface while offering an optional Lua layer for Neovim users. This approach ensures:

- **Vim compatibility first** - All core functionality works in classic Vim
- **Neovim enhancements** - Lua layer adds modern capabilities for Neovim users
- **Gradual adoption** - Users discover value in Vim, then upgrade to Neovim for more features
- **No rebranding** - Plugin remains "vim-genero-tools", not "lua-first"

## Architecture Principles

### 1. VimScript as Primary Interface
- All commands, keybindings, and configuration remain in VimScript
- VimScript layer is the "public API"
- Works identically in Vim and Neovim

### 2. Lua as Enhancement Layer
- Lua modules provide advanced implementations
- Lua is optional - plugin works without it
- Lua modules are called from VimScript when available
- Graceful fallback to VimScript implementations

### 3. Shared Data Model
- Configuration stored in `g:genero_tools_config` (accessible to both)
- Cache layer works identically in both
- Command execution abstracted for both environments

## Directory Structure

```
plugin/
  genero_tools.vim              # Main entry point (VimScript)

autoload/
  genero_tools.vim              # Core API (VimScript)
  genero_tools/
    config.vim                  # Configuration (VimScript)
    cache.vim                   # Caching (VimScript)
    command.vim                 # Command execution (VimScript)
    display.vim                 # Display modes (VimScript)
    complete.vim                # Autocomplete (VimScript)
    compiler.vim                # Compiler integration (VimScript)
    lua_bridge.vim              # NEW: Bridge to Lua layer

lua/
  genero_tools/
    init.lua                    # Lua module initialization
    config.lua                  # Lua config helpers
    cache.lua                   # Lua cache implementation
    async.lua                   # Async operations (Neovim-specific)
    ui.lua                      # UI components (floating windows, etc.)
    lsp.lua                      # LSP integration (Neovim-specific)
    ai.lua                       # AI IDE features (Neovim-specific)
```

## Implementation Pattern

### VimScript Calls Lua (When Available)

```vim
" In autoload/genero_tools/lua_bridge.vim
function! genero_tools#lua_bridge#call(module, function, args) abort
  if !has('nvim')
    return {}
  endif
  
  try
    return luaeval('require("genero_tools.' . a:module . '").' . a:function . '(...)', a:args)
  catch
    " Fallback to VimScript implementation
    return {}
  endtry
endfunction
```

### Lua Calls VimScript (For Shared Logic)

```lua
-- In lua/genero_tools/async.lua
local function get_config(key)
  -- Call VimScript config function
  return vim.fn['genero_tools#config#get'](key)
end
```

## Feature Mapping

### Core Features (VimScript - Works Everywhere)
- Function lookup
- Module exploration
- File metadata
- Autocomplete (basic)
- Compiler integration
- Caching
- Configuration

### Enhanced Features (Lua - Neovim Only)
- **Async Operations** - Non-blocking AI API calls
- **Floating Windows** - Rich UI for results
- **LSP Integration** - Language server protocol support
- **AI IDE Tools** - Code generation, error explanation, refactoring
- **Advanced Caching** - Lua-optimized cache with better performance
- **Real-time Analysis** - Background code analysis

## Lua Module Organization

### `lua/genero_tools/init.lua`
Entry point for Lua layer. Detects Neovim version and initializes available features.

```lua
local M = {}

function M.setup(config)
  -- Initialize Lua layer
  -- Called from VimScript plugin initialization
end

function M.is_available()
  -- Check if Lua layer can be used
  return vim.fn.has('nvim') == 1
end

return M
```

### `lua/genero_tools/async.lua`
Handles async operations using Neovim's job control.

```lua
local M = {}

function M.execute_async(command, args, callback)
  -- Non-blocking command execution
  -- Calls callback with results
end

function M.call_ai_api(prompt, context, callback)
  -- Async AI API call
  -- Prevents blocking editor
end

return M
```

### `lua/genero_tools/ui.lua`
Modern UI components for Neovim.

```lua
local M = {}

function M.show_floating_window(content, options)
  -- Create floating window with results
  -- Supports rich formatting
end

function M.show_popup_menu(items, callback)
  -- Interactive popup menu
  -- Better than quickfix for some use cases
end

return M
```

### `lua/genero_tools/lsp.lua`
LSP integration for Neovim.

```lua
local M = {}

function M.setup_lsp_client()
  -- Initialize LSP client for Genero
  -- Provides hover, goto definition, etc.
end

function M.get_hover_info(position)
  -- Get hover information at cursor
end

return M
```

### `lua/genero_tools/ai.lua`
AI IDE features (code generation, error explanation, etc.).

```lua
local M = {}

function M.explain_error(error_message, context)
  -- Use AI to explain compiler error
  -- Returns explanation and suggestions
end

function M.generate_code(prompt, context)
  -- Generate code using AI
  -- Uses genero-tools metadata as context
end

function M.suggest_refactoring(code_section)
  -- Suggest refactoring improvements
end

return M
```

## Integration Points

### 1. Configuration
VimScript reads/writes to `g:genero_tools_config`. Lua reads from same config:

```lua
-- In Lua
local config = vim.g.genero_tools_config
local timeout = config.timeout
```

### 2. Caching
Both layers can use same cache:

```vim
" VimScript can call Lua cache
let result = genero_tools#lua_bridge#call('cache', 'get', [cache_key])
```

### 3. Command Execution
Lua can call VimScript command execution:

```lua
-- In Lua
local result = vim.fn['genero_tools#command#execute_shell'](cmd, args)
```

## User Experience Flow

### Vim User
1. Install plugin
2. Use VimScript commands and keybindings
3. Get full functionality (lookup, autocomplete, compiler)
4. See value in plugin

### Neovim User (Initial)
1. Install plugin
2. Use same VimScript commands and keybindings
3. Get same functionality as Vim user
4. Optionally enable Lua layer for enhancements

### Neovim User (After Lua Layer)
1. Enable Lua features in config
2. Get async operations (non-blocking)
3. Get floating windows (better UI)
4. Get AI IDE features (code generation, error explanation)
5. Get LSP integration (hover, goto definition)

## Configuration for Lua Features

```vim
" In user's vimrc
let g:genero_tools_config = {
  \ 'lua_enabled': v:true,           " Enable Lua layer (Neovim only)
  \ 'async_enabled': v:true,         " Use async operations
  \ 'ui_mode': 'floating',           " Use floating windows (Neovim only)
  \ 'lsp_enabled': v:true,           " Enable LSP integration
  \ 'ai_enabled': v:true,            " Enable AI IDE features
  \ 'ai_provider': 'openai',         " AI provider (openai, claude, local)
  \ 'ai_api_key': $OPENAI_API_KEY,   " AI API key
  \ }
```

## Implementation Roadmap

### Phase 1: Foundation (Current)
- VimScript core functionality
- Basic Lua bridge
- Lua module structure

### Phase 2: Async & UI
- Lua async operations
- Floating window UI
- Non-blocking command execution

### Phase 3: LSP Integration
- Lua LSP client setup
- Hover information
- Goto definition

### Phase 4: AI IDE Features
- Error explanation
- Code generation
- Refactoring suggestions

## Benefits of This Approach

1. **Low barrier to entry** - Works in Vim immediately
2. **Gradual enhancement** - Lua features are optional
3. **No fragmentation** - Single plugin, not separate "lua version"
4. **Backward compatible** - Vim users never affected
5. **Future-proof** - Can add Lua features without breaking Vim support
6. **Clear separation** - VimScript for interface, Lua for implementation

## Testing Strategy

- VimScript tests run in both Vim and Neovim
- Lua tests run only in Neovim
- Integration tests verify VimScript ↔ Lua communication
- Fallback tests verify graceful degradation

## Documentation

- Keep README focused on VimScript interface
- Add Lua-specific docs in `docs/NEOVIM_LUA_FEATURES.md`
- Document Lua API for advanced users
- Provide examples for each Lua feature
