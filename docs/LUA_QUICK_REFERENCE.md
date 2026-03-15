# Lua Layer Quick Reference

Quick lookup for common Lua layer operations.

## Checking Lua Availability

```vim
" In VimScript
if genero_tools#lua_bridge#available()
  " Lua layer is available
endif
```

```lua
-- In Lua
if require('genero_tools').is_available() then
  -- Lua layer is available
end
```

## Calling Lua from VimScript

```vim
" Simple call
let result = genero_tools#lua_bridge#call('module', 'function', [arg1, arg2])

" Safe call with fallback
let result = genero_tools#lua_bridge#call_safe('module', 'function', [args], {})
```

## Calling VimScript from Lua

```lua
-- Call VimScript function
local result = vim.fn['genero_tools#config#get']('key')

-- Call VimScript command
vim.fn['genero_tools#command#execute_shell']('cmd', {'arg1', 'arg2'})
```

## Async Operations

```lua
-- Execute command asynchronously
require('genero_tools.async').execute_async('find-function', {'myFunc'}, 'my_callback')

-- Execute multiple commands in parallel
require('genero_tools.async').execute_parallel({
  {command = 'find-function', args = {'func1'}},
  {command = 'find-function', args = {'func2'}},
}, 'my_callback')

-- Debounce function
local debounced = require('genero_tools.async').debounce(function(arg)
  -- Function body
end, 300)

-- Throttle function
local throttled = require('genero_tools.async').throttle(function(arg)
  -- Function body
end, 1000)
```

## UI Components

```lua
-- Show floating window
require('genero_tools.ui').show_floating_window(content, {
  title = 'My Window',
  width = 80,
  height = 20,
  border = 'rounded',
})

-- Show popup menu
require('genero_tools.ui').show_popup_menu({'Item 1', 'Item 2'}, function(item, index)
  print('Selected: ' .. item)
end)

-- Show split window
require('genero_tools.ui').show_split(content, {
  direction = 'horizontal',
  size = 10,
})

-- Show notification
require('genero_tools.ui').notify('Message', vim.log.levels.INFO)

-- Show progress
require('genero_tools.ui').show_progress('Loading...', 50)

-- Highlight pattern in buffer
require('genero_tools.ui').highlight_pattern(buf, 'pattern', 'Search')
```

## AI Features

```lua
-- Explain error
local result = require('genero_tools.ai').explain_error(error_msg, context)
if result.success then
  print(result.content)
end

-- Generate code
local result = require('genero_tools.ai').generate_code(prompt, context)
if result.success then
  print(result.content)
end

-- Suggest refactoring
local result = require('genero_tools.ai').suggest_refactoring(code)
if result.success then
  print(result.content)
end

-- Cache response
require('genero_tools.ai').cache_response('key', value)

-- Get cached response
local cached = require('genero_tools.ai').get_cached_response('key', 3600)
```

## LSP Integration

```lua
-- Set up LSP client
require('genero_tools.lsp').setup_lsp_client()

-- Get hover information
local hover = require('genero_tools.lsp').get_hover_info()

-- Get definition
local def = require('genero_tools.lsp').get_definition('symbol')

-- Get references
local refs = require('genero_tools.lsp').get_references('symbol')

-- Rename symbol
require('genero_tools.lsp').rename_symbol('new_name')

-- Format document
require('genero_tools.lsp').format_document()

-- Format range
require('genero_tools.lsp').format_range(start_line, end_line)
```

## Configuration

```vim
" Enable Lua layer
let g:genero_tools_config.lua_enabled = v:true

" Enable async operations
let g:genero_tools_config.async_enabled = v:true

" Use floating windows
let g:genero_tools_config.ui_mode = 'floating'

" Enable LSP
let g:genero_tools_config.lsp_enabled = v:true

" Enable AI features
let g:genero_tools_config.ai_enabled = v:true
let g:genero_tools_config.ai_provider = 'openai'
let g:genero_tools_config.ai_api_key = $OPENAI_API_KEY

" Enable development mode (reload Lua on save)
let g:genero_tools_config.dev_mode = v:true
```

## Common Patterns

### Async Callback Pattern

```vim
" VimScript
function! my_callback(result) abort
  if a:result.success
    call genero_tools#display#echo('Success: ' . a:result.data)
  else
    call genero_tools#display#echo('Error: ' . a:result.error)
  endif
endfunction

call genero_tools#lua_bridge#execute_async('find-function', ['myFunc'], 'my_callback')
```

### Floating Window Pattern

```lua
-- Lua
local content = 'Result content here'
require('genero_tools.ui').show_floating_window(content, {
  title = 'Result',
  width = 80,
  height = 20,
})
```

### Error Handling Pattern

```lua
-- Lua
local ok, result = pcall(function()
  return require('genero_tools.ai').explain_error(error_msg, context)
end)

if not ok then
  vim.notify('Error: ' .. result, vim.log.levels.ERROR)
else
  -- Handle result
end
```

### Safe VimScript Call Pattern

```vim
" VimScript
let result = genero_tools#lua_bridge#call_safe('module', 'function', [args], {})
if empty(result)
  " Fallback to VimScript implementation
  let result = genero_tools#vimscript_fallback()
endif
```

## Debugging

```vim
" Check Lua availability
:echo genero_tools#lua_bridge#available()

" Show configuration
:GeneroConfigShow

" Enable verbose logging
:set verbose=9

" Check for errors
:messages
```

```lua
-- In Lua
print(vim.inspect(vim.g.genero_tools_config))
print(require('genero_tools').health_check())
```

## Performance Tips

1. **Use async for long operations**
   ```lua
   require('genero_tools.async').execute_async(cmd, args, callback)
   ```

2. **Cache results**
   ```lua
   require('genero_tools.ai').cache_response(key, value)
   ```

3. **Use debounce for frequent operations**
   ```lua
   local debounced = require('genero_tools.async').debounce(func, 300)
   ```

4. **Use floating windows for large results**
   ```vim
   let g:genero_tools_config.ui_mode = 'floating'
   ```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Lua layer not loading | Check `has('nvim')` and `lua_enabled` config |
| Floating windows not working | Ensure Neovim 0.5+ |
| AI features not working | Check API key and provider configuration |
| LSP not connecting | Verify LSP server is installed |
| Async operations blocking | Check `async_enabled` config |

## Resources

- [NEOVIM_LUA_LAYER.md](NEOVIM_LUA_LAYER.md) - Architecture guide
- [NEOVIM_LUA_FEATURES.md](NEOVIM_LUA_FEATURES.md) - User guide
- [lua-layer-architecture.md](../.kiro/steering/lua-layer-architecture.md) - Developer guide
- [Neovim Lua Guide](https://neovim.io/doc/user/lua.html)
- [Neovim API](https://neovim.io/doc/user/api.html)
