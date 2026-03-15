-- Genero-Tools Lua Layer
-- Provides enhanced functionality for Neovim
-- Currently focused on feature parity with Vim plugin
-- Future enhancements: AI features, LSP integration, advanced analysis

local M = {}

-- Check if Lua layer is available and enabled
function M.is_available()
  return vim.fn.has('nvim') == 1
end

-- Get configuration value from VimScript
local function get_config(key)
  return vim.g.genero_tools_config[key] or false
end

-- Initialize Lua layer
function M.setup(config)
  if not M.is_available() then
    return
  end

  -- Store config reference
  M.config = config or {}

  -- Initialize submodules based on config
  if get_config('async_enabled') then
    require('genero_tools.async').init()
  end

  if get_config('ui_mode') == 'floating' then
    require('genero_tools.ui').init()
  end

  -- Set up autocommands for Lua features
  M.setup_autocommands()
end

-- Set up autocommands for Lua features
function M.setup_autocommands()
  local group = vim.api.nvim_create_augroup('GeneroToolsLua', { clear = true })

  -- Auto-initialize Lua layer when plugin loads
  vim.api.nvim_create_autocmd('VimEnter', {
    group = group,
    callback = function()
      if get_config('lua_enabled') then
        M.setup(vim.g.genero_tools_config)
      end
    end,
  })

  -- Reload Lua modules on config change (for development)
  if get_config('dev_mode') then
    vim.api.nvim_create_autocmd('BufWritePost', {
      group = group,
      pattern = 'lua/genero_tools/*.lua',
      callback = function()
        -- Clear Lua module cache
        for key, _ in pairs(package.loaded) do
          if key:match('^genero_tools') then
            package.loaded[key] = nil
          end
        end
        vim.notify('Genero-Tools Lua modules reloaded', vim.log.levels.INFO)
      end,
    })
  end
end

-- Get Lua module version
function M.version()
  return '1.0.0'
end

-- Health check for Lua layer
function M.health_check()
  local health = {
    available = M.is_available(),
    version = M.version(),
    features = {
      async = get_config('async_enabled'),
      ui = get_config('ui_mode') == 'floating',
    },
  }
  return health
end

return M
