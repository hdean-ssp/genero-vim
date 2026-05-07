# Genero-Tools Troubleshooting Guide

## Common Issues and Solutions

### 1. Module 'genero_tools.lualine' Not Found

**Symptoms:**
```
lazy.nvim: Failed to run config for lualine.nvim
module 'genero_tools.lualine' not found
```

**Cause:**
Plugin loading order issue - lualine is trying to load before genero-tools.

**Solution:**

Ensure lualine has genero-tools as a dependency in your `init.lua`:

```lua
{
  "nvim-lualine/lualine.nvim",
  version = "v0.9.*",
  dependencies = { "genero-tools" },  -- Add this line
  config = function()
    -- Safely load genero-tools lualine integration
    local ok, lualine_genero = pcall(require, "genero_tools.lualine")
    if ok then
      lualine_genero.setup()
    end
    
    require("lualine").setup({
      -- ... rest of config
    })
  end,
}
```

**Alternative Solution:**

If you don't want genero-tools statusline integration, remove the genero_tools references:

```lua
{
  "nvim-lualine/lualine.nvim",
  version = "v0.9.*",
  config = function()
    require("lualine").setup({
      options = {
        theme = "auto",
        -- ... options
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = {},
        lualine_c = { "diagnostics" },  -- Remove genero components
        lualine_x = { "encoding", "filetype" },  -- Remove genero components
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    })
  end,
}
```

### 2. Module 'genero_tools.cmp_source' Not Found

**Symptoms:**
```
Error in config for nvim-cmp
module 'genero_tools.cmp_source' not found
```

**Cause:**
nvim-cmp is loading before genero-tools.

**Solution:**

Add genero-tools as a dependency in nvim-cmp configuration:

```lua
{
  "hrsh7th/nvim-cmp",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "L3MON4D3/LuaSnip",
    "saadparwaiz1/cmp_luasnip",
    "genero-tools",  -- Add this line
  },
  config = function()
    local cmp = require("cmp")
    
    -- Safely load Genero cmp source
    pcall(require, "genero_tools.cmp_source")
    
    -- ... rest of config
  end,
}
```

### 3. Snippets Not Working

**Symptoms:**
- `:GeneroSnippetList` shows "No snippets available"
- Snippet expansion doesn't work

**Cause:**
Snippets module not initialized or LuaSnip not installed.

**Solution:**

1. Verify LuaSnip is installed:
   ```vim
   :Lazy
   ```
   Look for "LuaSnip" in the list.

2. Check snippet initialization in genero-tools config:
   ```lua
   {
     "hdean-ssp/genero-vim",
     name = "genero-tools",
     dependencies = { "L3MON4D3/LuaSnip" },
     config = function()
       -- Initialize snippets module if enabled
       local ok_snippets, snippets = pcall(require, "genero_tools.snippets")
       if ok_snippets and vim.g.genero_tools_config.snippets_enabled then
         snippets.setup()
       end
     end,
   }
   ```

3. Verify snippets are enabled in config:
   ```lua
   vim.g.genero_tools_config = {
     snippets_enabled = true,
     -- ... other config
   }
   ```

4. Check snippet health:
   ```vim
   :lua print(vim.inspect(require('genero_tools.snippets').health_check()))
   ```

### 4. Comments Moving to Column 0

**Symptoms:**
When typing `#` to start a comment, the cursor jumps to column 0.

**Cause:**
Vim's `smartindent` treats `#` specially for C preprocessor directives.

**Solution:**
The plugin provides indent files that fix this automatically. If it's not working:

1. Verify filetype is detected:
   ```vim
   :set filetype?
   ```
   Should show: `4gl`, `fgl`, `genero`, or `per`

2. Check if indent file is loaded:
   ```vim
   :set smartindent?
   ```
   Should show: `nosmartindent`

3. Manually apply fix:
   ```vim
   :setlocal nosmartindent autoindent
   ```

See [COMMENT_INDENTATION.md](COMMENT_INDENTATION.md) for details.

### 5. Telescope Pickers Not Working

**Symptoms:**
- `:GeneroFileFunctions` shows error
- `:GeneroModuleFiles` doesn't work

**Cause:**
Telescope not installed or not loaded.

**Solution:**

1. Install Telescope:
   ```lua
   {
     "nvim-telescope/telescope.nvim",
     dependencies = { "nvim-lua/plenary.nvim" },
   }
   ```

2. Verify Telescope is installed:
   ```vim
   :Telescope
   ```

3. Check if Telescope commands exist:
   ```vim
   :command GeneroFileFunctions
   ```

4. Fallback to VimScript commands:
   ```vim
   :GeneroListFunctions
   ```

### 6. Compiler Not Working

**Symptoms:**
- `:GeneroCompile` shows no errors
- No error signs in sign column

**Cause:**
Compiler not found or genero-tools query.sh not configured.

**Solution:**

1. Verify compiler is in PATH:
   ```bash
   which fglcomp
   ```

2. Check genero-tools path:
   ```lua
   vim.g.genero_tools_config = {
     genero_tools_path = "/path/to/genero-tools/query.sh",
     -- ... other config
   }
   ```

3. Test query.sh directly:
   ```bash
   /path/to/genero-tools/query.sh list-file-functions ./test.4gl
   ```

4. Check compiler configuration:
   ```vim
   :GeneroConfigShow
   ```

### 7. Plugin Not Loading

**Symptoms:**
- No Genero commands available
- `:command Genero` shows nothing

**Cause:**
Plugin not installed or not in runtimepath.

**Solution:**

1. Verify plugin is installed:
   ```vim
   :Lazy
   ```
   Look for "genero-tools" or "genero-vim"

2. Check if plugin directory exists:
   ```bash
   ls ~/.local/share/nvim/lazy/genero-vim/
   ```

3. Reinstall plugin:
   ```vim
   :Lazy clean
   :Lazy install
   ```

4. Check for errors:
   ```vim
   :Lazy log
   ```

### 8. Different Behavior on Different Servers

**Symptoms:**
Works on one server (e.g., RHEL 7) but not another (e.g., RHEL 9).

**Possible Causes:**
- Different Neovim versions
- Different Lua versions
- Different plugin versions
- Different environment variables

**Solution:**

1. Compare Neovim versions:
   ```vim
   :version
   ```

2. Compare Lua versions:
   ```vim
   :lua print(_VERSION)
   ```

3. Compare plugin versions:
   ```vim
   :Lazy
   ```
   Check version numbers for all plugins

4. Compare environment:
   ```bash
   env | grep -i genero
   env | grep -i brodir
   ```

5. Use exact same config:
   ```bash
   # Copy config from working server
   rsync -av server1:~/.config/nvim/ ~/.config/nvim/
   ```

6. Check for system-specific issues:
   ```vim
   :checkhealth
   ```

### 9. Telescope Preview Error: ft_to_lang is nil

**Symptoms:**
```
Error executing vim.schedule lua callback: 
...m/lazy/telescope.nvim/lua/telescope/previewers/utils.lua:135: 
attempt to call field 'ft_to_lang' (a nil value)
```

This error appears multiple times when using Telescope pickers (like `:GeneroFindReferences`), even though the functionality works correctly.

**Cause:**
Telescope is trying to use treesitter's `ft_to_lang` function for syntax highlighting in the preview window, but this function doesn't exist in some versions of nvim-treesitter.

**Solution:**

Disable treesitter highlighting in Telescope's preview window by adding this to your Telescope configuration in `init.lua`:

```lua
{
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")

    telescope.setup({
      defaults = {
        -- ... other settings ...
        
        -- Disable treesitter highlighting in preview to avoid compatibility issues
        preview = {
          treesitter = false,  -- Use vim syntax highlighting instead
        },
        
        -- ... rest of config ...
      },
    })
  end,
}
```

This tells Telescope to use Vim's built-in syntax highlighting instead of treesitter, which is more compatible and still provides good syntax highlighting.

**Note:** The `init.lua.example` file in this repository already includes this fix.

### 10. Performance Issues

**Symptoms:**
- Slow startup
- Lag when editing
- High CPU usage

**Solution:**

1. Profile startup:
   ```bash
   nvim --startuptime startup.log
   ```

2. Disable features temporarily:
   ```lua
   vim.g.genero_tools_config = {
     compiler_autocompile = false,
     hints_enabled = false,
     svn_enabled = false,
   }
   ```

3. Increase cache TTL:
   ```lua
   vim.g.genero_tools_config = {
     cache_ttl = 7200,  -- 2 hours
     hints_cache_ttl = 600,  -- 10 minutes
   }
   ```

4. Reduce hint checks:
   ```lua
   vim.g.genero_tools_config = {
     hints_realtime = false,
     hints_delay = 1000,  -- 1 second
   }
   ```

## Getting Help

### Check Health
```vim
:checkhealth
```

### View Logs
```vim
:Lazy log
:messages
```

### Debug Mode
Enable debug mode in config:
```lua
vim.g.genero_tools_config = {
  debug_mode = true,
}
```

### Report Issues
When reporting issues, include:
1. Neovim version (`:version`)
2. Plugin version (`:Lazy`)
3. Error messages (`:messages`)
4. Minimal config to reproduce
5. Operating system and version

## Related Documentation

- [SETUP.md](../SETUP.md) - Installation guide
- [COMMENT_INDENTATION.md](COMMENT_INDENTATION.md) - Comment indentation fix
- [COMMAND_AUDIT.md](COMMAND_AUDIT.md) - All available commands
- [SNIPPET_TELESCOPE_INTEGRATION.md](SNIPPET_TELESCOPE_INTEGRATION.md) - Snippet Telescope usage
