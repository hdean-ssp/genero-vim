# Neovim Lua Features Guide

This guide explains how to use and extend the Lua layer in vim-genero-tools for Neovim users.

## Quick Start

The Lua layer is **optional** and **disabled by default**. To enable it:

```vim
" In your vimrc
let g:genero_tools_config = {
  \ 'lua_enabled': v:true,
  \ }
```

## Features

### 1. Async Operations

Execute genero-tools commands without blocking the editor.

```vim
" Enable async mode
let g:genero_tools_config.async_enabled = v:true

" Commands now execute in background
:GeneroLookup myFunction
```

**Benefits:**
- Editor remains responsive during long queries
- Multiple commands can run in parallel
- Better for large codebases (6M+ LOC)

### 2. Floating Windows

Display results in modern floating windows instead of quickfix.

```vim
" Use floating windows for results
let g:genero_tools_config.ui_mode = 'floating'
```

**Features:**
- Centered floating window
- Syntax highlighting
- Keyboard navigation (j/k, gg/G, q to close)
- Better for large result sets

### 3. LSP Integration

Get IDE-like features through Language Server Protocol.

```vim
" Enable LSP integration
let g:genero_tools_config.lsp_enabled = v:true
```

**Features:**
- Hover information (K)
- Go to definition (gd)
- Find references (gr)
- Rename symbol (<leader>rn)
- Code actions (<leader>ca)
- Diagnostics navigation ([d, ]d)

**Requirements:**
- Genero LSP server installed (genero-lsp, genero-language-server, or fgl-lsp)

### 4. AI IDE Features

Use AI to explain errors, generate code, and suggest refactoring.

```vim
" Enable AI features
let g:genero_tools_config.ai_enabled = v:true
let g:genero_tools_config.ai_provider = 'openai'
let g:genero_tools_config.ai_api_key = $OPENAI_API_KEY
```

**Features:**
- Explain compiler errors
- Generate code from prompts
- Suggest refactoring improvements
- Cached responses to avoid redundant API calls

**Supported Providers:**
- `openai` - OpenAI GPT-4
- `claude` - Anthropic Claude
- `local` - Local model (Ollama, etc.)

## Configuration

### Complete Configuration Example

```vim
let g:genero_tools_config = {
  \ 'lua_enabled': v:true,
  \ 'async_enabled': v:true,
  \ 'ui_mode': 'floating',
  \ 'lsp_enabled': v:true,
  \ 'ai_enabled': v:true,
  \ 'ai_provider': 'openai',
  \ 'ai_api_key': $OPENAI_API_KEY,
  \ 'dev_mode': v:false,
  \ }
```

### Configuration Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `lua_enabled` | bool | false | Enable Lua layer |
| `async_enabled` | bool | true | Use async operations |
| `ui_mode` | string | 'quickfix' | UI mode: 'quickfix', 'floating', 'split', 'echo' |
| `lsp_enabled` | bool | false | Enable LSP integration |
| `ai_enabled` | bool | false | Enable AI features |
| `ai_provider` | string | 'openai' | AI provider: 'openai', 'claude', 'local' |
| `ai_api_key` | string | '' | API key for AI provider |
| `claude_api_key` | string | '' | Claude API key (if using Claude) |
| `local_ai_url` | string | 'http://localhost:11434/api/generate' | Local AI endpoint |
| `dev_mode` | bool | false | Enable development mode (reload Lua on save) |

## Usage Examples

### Example 1: Async Function Lookup

```vim
" With async enabled, this won't block the editor
:GeneroLookup validate_input

" Results appear in floating window when ready
```

### Example 2: AI Error Explanation

When you get a compiler error:

```vim
" Compiler shows error in sign column
" Place cursor on error line
:GeneroExplainError

" AI explains the error and suggests fixes
```

### Example 3: AI Code Generation

```vim
" Generate a function using AI
:GeneroGenerateCode "Create a function to validate email addresses"

" AI generates code based on codebase context
```

### Example 4: LSP Hover Information

```vim
" Place cursor on a function name
" Press K to see hover information
K

" Shows function signature, documentation, etc.
```

## Lua API for Advanced Users

### Calling Lua from VimScript

```vim
" Call a Lua function from VimScript
let result = genero_tools#lua_bridge#call('async', 'execute_async', [cmd, args, callback])

" Safe call with fallback
let result = genero_tools#lua_bridge#call_safe('ui', 'show_floating_window', [content, opts], {})
```

### Lua Module Reference

#### `genero_tools.async`

```lua
require('genero_tools.async').execute_async(command, args, callback)
require('genero_tools.async').call_ai_api(prompt, context, callback)
require('genero_tools.async').execute_parallel(commands, callback)
require('genero_tools.async').debounce(func, delay)
require('genero_tools.async').throttle(func, interval)
```

#### `genero_tools.ui`

```lua
require('genero_tools.ui').show_floating_window(content, options)
require('genero_tools.ui').show_popup_menu(items, callback)
require('genero_tools.ui').show_split(content, options)
require('genero_tools.ui').notify(message, level)
require('genero_tools.ui').show_progress(message, percentage)
```

#### `genero_tools.ai`

```lua
require('genero_tools.ai').explain_error(error_message, context)
require('genero_tools.ai').generate_code(prompt, context)
require('genero_tools.ai').suggest_refactoring(code_section)
require('genero_tools.ai').call_api(prompt, request_type)
```

#### `genero_tools.lsp`

```lua
require('genero_tools.lsp').setup_lsp_client()
require('genero_tools.lsp').get_hover_info(row, col)
require('genero_tools.lsp').get_definition(symbol)
require('genero_tools.lsp').get_references(symbol)
require('genero_tools.lsp').rename_symbol(new_name)
require('genero_tools.lsp').format_document()
```

### Example: Custom Lua Command

```lua
-- In your init.lua
local genero = require('genero_tools')

-- Create custom command
vim.api.nvim_create_user_command('GeneroExplainError', function()
  local error_msg = vim.fn.getline('.')
  local context = table.concat(vim.fn.getline(vim.fn.line('.') - 5, vim.fn.line('.') + 5), '\n')
  
  local result = require('genero_tools.ai').explain_error(error_msg, context)
  if result.success then
    require('genero_tools.ui').show_floating_window(result.content, {
      title = 'Error Explanation'
    })
  end
end, {})
```

## Troubleshooting

### Lua layer not loading

Check if Lua is available:
```vim
:echo has('nvim')  " Should be 1
:echo genero_tools#lua_bridge#available()  " Should be 1
```

### Floating windows not working

Ensure you're using Neovim 0.5+:
```vim
:echo nvim_version()
```

### AI features not working

Check API key configuration:
```vim
:echo g:genero_tools_config.ai_api_key
```

Verify API provider is accessible:
```bash
curl https://api.openai.com/v1/models -H "Authorization: Bearer $OPENAI_API_KEY"
```

### LSP not connecting

Check if LSP server is installed:
```bash
which genero-lsp
which genero-language-server
which fgl-lsp
```

## Performance Tips

1. **Use async mode** for large codebases
   ```vim
   let g:genero_tools_config.async_enabled = v:true
   ```

2. **Enable caching** to reduce API calls
   ```vim
   let g:genero_tools_config.cache_enabled = v:true
   ```

3. **Use floating windows** instead of quickfix for better performance
   ```vim
   let g:genero_tools_config.ui_mode = 'floating'
   ```

4. **Cache AI responses** to avoid redundant API calls
   ```lua
   require('genero_tools.ai').cache_response(key, value)
   ```

## Development

### Enable Development Mode

```vim
let g:genero_tools_config.dev_mode = v:true
```

This reloads Lua modules when you save them, making development faster.

### Debug Lua Errors

```vim
" Check for Lua errors
:messages

" Enable verbose logging
:set verbose=9
```

## Migration from VimScript

If you're currently using the VimScript-only version:

1. Update your config to enable Lua features
2. All existing commands continue to work
3. New Lua features are opt-in
4. No breaking changes

## Next Steps

- Read [NEOVIM_LUA_LAYER.md](NEOVIM_LUA_LAYER.md) for architecture details
- Check [API_INTEGRATION.md](API_INTEGRATION.md) for genero-tools API reference
- Explore Lua module source code in `lua/genero_tools/`
