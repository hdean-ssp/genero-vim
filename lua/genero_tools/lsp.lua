-- Genero-Tools LSP Integration
-- Provides Language Server Protocol support for Neovim

local M = {}

-- Initialize LSP module
function M.init()
  if not vim.fn.has('nvim') then
    return
  end

  -- Check if LSP is available
  if not vim.lsp then
    vim.notify('LSP not available in this Neovim version', vim.log.levels.WARN)
    return
  end

  M.setup_lsp_client()
end

-- Set up LSP client for Genero
function M.setup_lsp_client()
  local lsp_config = {
    name = 'genero-lsp',
    cmd = M.get_lsp_command(),
    root_dir = M.get_root_dir(),
    settings = M.get_lsp_settings(),
  }

  -- Only set up if LSP command is available
  if not lsp_config.cmd or #lsp_config.cmd == 0 then
    vim.notify('Genero LSP server not found', vim.log.levels.WARN)
    return
  end

  -- Register LSP client
  local client_id = vim.lsp.start(lsp_config)

  if client_id then
    vim.notify('Genero LSP client started', vim.log.levels.INFO)
    M.setup_lsp_keybindings()
  else
    vim.notify('Failed to start Genero LSP client', vim.log.levels.ERROR)
  end
end

-- Get LSP command
function M.get_lsp_command()
  -- Check for genero-lsp in PATH
  local lsp_servers = {
    'genero-lsp',
    'genero-language-server',
    'fgl-lsp',
  }

  for _, server in ipairs(lsp_servers) do
    if vim.fn.executable(server) == 1 then
      return { server }
    end
  end

  return {}
end

-- Get project root directory
function M.get_root_dir()
  local markers = vim.g.genero_tools_config.codebase_markers or { 'castle.sch', '.git' }

  for _, marker in ipairs(markers) do
    local root = vim.fn['genero_tools#codebase#find_root'](marker)
    if root ~= '' then
      return root
    end
  end

  return vim.fn.getcwd()
end

-- Get LSP settings
function M.get_lsp_settings()
  return {
    genero = {
      -- Genero-specific settings
      maxNumberOfProblems = 100,
      trace = {
        server = 'off',
      },
    },
  }
end

-- Set up LSP keybindings
function M.setup_lsp_keybindings()
  local opts = { noremap = true, silent = true }

  -- Hover information
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)

  -- Go to definition
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)

  -- Go to declaration
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)

  -- Find references
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)

  -- Rename symbol
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)

  -- Code actions
  vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)

  -- Diagnostics
  vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, opts)
  vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
  vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
end

-- Get hover information at cursor position
-- Args:
--   row: Line number (0-indexed)
--   col: Column number (0-indexed)
-- Returns: Hover information
function M.get_hover_info(row, col)
  row = row or vim.fn.line('.') - 1
  col = col or vim.fn.col('.') - 1

  local params = vim.lsp.util.make_position_params()
  local result = {}

  -- Query all active LSP clients
  for _, client in ipairs(vim.lsp.get_active_clients()) do
    if client.server_capabilities.hoverProvider then
      client.request('textDocument/hover', params, function(err, hover_result)
        if not err and hover_result then
          result = hover_result
        end
      end)
    end
  end

  return result
end

-- Get definition location
-- Args:
--   symbol: Symbol name
-- Returns: Location information
function M.get_definition(symbol)
  local params = vim.lsp.util.make_position_params()
  local result = {}

  for _, client in ipairs(vim.lsp.get_active_clients()) do
    if client.server_capabilities.definitionProvider then
      client.request('textDocument/definition', params, function(err, def_result)
        if not err and def_result then
          result = def_result
        end
      end)
    end
  end

  return result
end

-- Get all references to symbol
-- Args:
--   symbol: Symbol name
-- Returns: List of reference locations
function M.get_references(symbol)
  local params = vim.lsp.util.make_position_params()
  params.context = { includeDeclaration = true }
  local result = {}

  for _, client in ipairs(vim.lsp.get_active_clients()) do
    if client.server_capabilities.referencesProvider then
      client.request('textDocument/references', params, function(err, ref_result)
        if not err and ref_result then
          result = ref_result
        end
      end)
    end
  end

  return result
end

-- Get code actions at cursor
-- Returns: List of code actions
function M.get_code_actions()
  local params = vim.lsp.util.make_range_params()
  params.context = { diagnostics = vim.diagnostic.get(0) }
  local result = {}

  for _, client in ipairs(vim.lsp.get_active_clients()) do
    if client.server_capabilities.codeActionProvider then
      client.request('textDocument/codeAction', params, function(err, actions)
        if not err and actions then
          result = actions
        end
      end)
    end
  end

  return result
end

-- Rename symbol
-- Args:
--   new_name: New name for symbol
function M.rename_symbol(new_name)
  local params = vim.lsp.util.make_position_params()
  params.newName = new_name

  for _, client in ipairs(vim.lsp.get_active_clients()) do
    if client.server_capabilities.renameProvider then
      client.request('textDocument/rename', params, function(err, result)
        if err then
          vim.notify('Rename failed: ' .. err.message, vim.log.levels.ERROR)
        else
          vim.lsp.util.apply_workspace_edit(result, client.offset_encoding)
          vim.notify('Symbol renamed successfully', vim.log.levels.INFO)
        end
      end)
    end
  end
end

-- Format document
function M.format_document()
  vim.lsp.buf.format({ async = true })
end

-- Format range
-- Args:
--   start_line: Start line (1-indexed)
--   end_line: End line (1-indexed)
function M.format_range(start_line, end_line)
  local params = vim.lsp.util.make_range_params(
    { start_line - 1, 0 },
    { end_line - 1, -1 }
  )

  for _, client in ipairs(vim.lsp.get_active_clients()) do
    if client.server_capabilities.documentRangeFormattingProvider then
      client.request('textDocument/rangeFormatting', params, function(err, result)
        if err then
          vim.notify('Format failed: ' .. err.message, vim.log.levels.ERROR)
        else
          vim.lsp.util.apply_text_edits(result, 0, client.offset_encoding)
        end
      end)
    end
  end
end

return M
