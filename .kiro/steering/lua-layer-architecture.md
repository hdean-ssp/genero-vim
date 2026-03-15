---
inclusion: manual
---

# Lua Layer Architecture Steering

This document guides development of the Lua layer for vim-genero-tools.

## Core Principles

1. **VimScript First** - All core functionality remains in VimScript
2. **Lua as Enhancement** - Lua adds modern capabilities for Neovim
3. **Graceful Degradation** - Plugin works without Lua
4. **No Rebranding** - Plugin remains "vim-genero-tools", not "lua-first"

## Architecture Pattern

### VimScript Layer (Primary Interface)
- Entry point: `plugin/genero_tools.vim`
- Core API: `autoload/genero_tools.vim`
- Configuration: `autoload/genero_tools/config.vim`
- Bridge: `autoload/genero_tools/lua_bridge.vim`

### Lua Layer (Enhancement)
- Entry point: `lua/genero_tools/init.lua`
- Async operations: `lua/genero_tools/async.lua`
- UI components: `lua/genero_tools/ui.lua`
- AI features: `lua/genero_tools/ai.lua`
- LSP integration: `lua/genero_tools/lsp.lua`

## Integration Points

### 1. Configuration
Both layers read from `g:genero_tools_config`:
```vim
" VimScript
let config = genero_tools#config#get('key')

" Lua
local config = vim.g.genero_tools_config['key']
```

### 2. Command Execution
Lua calls VimScript command execution:
```lua
local result = vim.fn['genero_tools#command#execute_shell'](cmd, args)
```

### 3. Caching
Both layers can use same cache:
```vim
" VimScript
let result = genero_tools#cache#get(key)

" Lua (via bridge)
local result = vim.fn['genero_tools#cache#get'](key)
```

## Development Guidelines

### Adding a New Lua Feature

1. **Create Lua module** in `lua/genero_tools/feature.lua`
2. **Add VimScript bridge** in `autoload/genero_tools/lua_bridge.vim`
3. **Create VimScript command** in `plugin/genero_tools.vim`
4. **Document in** `docs/NEOVIM_LUA_FEATURES.md`

### Example: Adding a New Feature

```lua
-- lua/genero_tools/feature.lua
local M = {}

function M.init()
  -- Initialize feature
end

function M.do_something(arg)
  -- Feature implementation
  return result
end

return M
```

```vim
" autoload/genero_tools/lua_bridge.vim
function! genero_tools#lua_bridge#feature_do_something(arg) abort
  if !genero_tools#lua_bridge#available()
    return {}
  endif
  
  try
    return luaeval('require("genero_tools.feature").do_something(...)', [a:arg])
  catch
    call genero_tools#error#log('Feature error: ' . v:exception)
    return {}
  endtry
endfunction
```

```vim
" plugin/genero_tools.vim
command! -nargs=1 GeneroFeatureDoSomething call genero_tools#lua_bridge#feature_do_something(<q-args>)
```

## Testing Strategy

### VimScript Tests
- Run in both Vim and Neovim
- Located in `test/`
- Use `test/property_tests.vim` pattern

### Lua Tests
- Run only in Neovim
- Located in `test/lua/`
- Use Lua testing framework (busted, etc.)

### Integration Tests
- Test VimScript ↔ Lua communication
- Verify fallback behavior
- Test graceful degradation

## Performance Considerations

### Async Operations
- Use `vim.fn.jobstart()` for background tasks
- Implement debounce/throttle for frequent operations
- Cache results to avoid redundant calls

### UI Components
- Use floating windows for large result sets
- Implement pagination for very large results
- Optimize rendering for performance

### AI Features
- Cache AI responses with TTL
- Implement request queuing
- Handle API rate limits gracefully

## Error Handling

### Lua Error Handling
```lua
local ok, result = pcall(function()
  -- Risky operation
end)

if not ok then
  vim.notify('Error: ' .. result, vim.log.levels.ERROR)
  return {}
end
```

### VimScript Error Handling
```vim
try
  let result = luaeval('...')
catch
  call genero_tools#error#log('Error: ' . v:exception)
  return {}
endtry
```

## Configuration Management

### Adding New Config Option

1. Add to defaults in `autoload/genero_tools/config.vim`
2. Document in `docs/NEOVIM_LUA_FEATURES.md`
3. Use in Lua via `vim.g.genero_tools_config`

```vim
" In config.vim
let defaults = {
  \ 'new_option': v:true,
  \ }
```

```lua
-- In Lua
local enabled = vim.g.genero_tools_config.new_option
```

## Documentation

### For Each Feature
1. Add to `docs/NEOVIM_LUA_FEATURES.md`
2. Include configuration example
3. Provide usage examples
4. Document Lua API

### For Architecture Changes
1. Update `docs/NEOVIM_LUA_LAYER.md`
2. Update this steering file
3. Add comments in code

## Backward Compatibility

### Maintaining Vim Compatibility
- All VimScript changes must work in Vim 8.0+
- Lua layer is Neovim-only
- Use `has('nvim')` to check for Neovim
- Provide VimScript fallbacks

### Version Checking
```vim
if has('nvim')
  " Neovim-specific code
else
  " Vim fallback
endif
```

## Common Patterns

### Async Callback Pattern
```lua
-- Lua
require('genero_tools.async').execute_async(cmd, args, 'my_callback')

-- VimScript callback
function! my_callback(result) abort
  " Handle result
endfunction
```

### UI Display Pattern
```lua
-- Show result in floating window
require('genero_tools.ui').show_floating_window(content, {
  title = 'Result',
  width = 80,
  height = 20,
})
```

### Error Handling Pattern
```lua
-- Safe operation with fallback
local result = vim.fn['genero_tools#lua_bridge#call_safe'](
  'module', 'function', {args}, {}
)
```

## Debugging

### Enable Verbose Logging
```vim
:set verbose=9
```

### Check Lua Availability
```vim
:echo has('nvim')
:echo genero_tools#lua_bridge#available()
```

### Inspect Configuration
```vim
:GeneroConfigShow
```

### Reload Lua Modules (Dev Mode)
```vim
let g:genero_tools_config.dev_mode = v:true
" Save any Lua file to reload all modules
```

## Future Enhancements

### Planned Features
1. Advanced async operations with progress tracking
2. Rich UI components (tabs, panels, etc.)
3. Full LSP integration
4. AI-powered code generation
5. Real-time code analysis

### Extensibility
- Plugin API for third-party extensions
- Custom Lua modules
- User-defined commands
- Custom UI themes

## References

- [NEOVIM_LUA_LAYER.md](../docs/NEOVIM_LUA_LAYER.md) - Architecture overview
- [NEOVIM_LUA_FEATURES.md](../docs/NEOVIM_LUA_FEATURES.md) - User guide
- [Neovim Lua Guide](https://neovim.io/doc/user/lua.html)
- [Neovim API](https://neovim.io/doc/user/api.html)
