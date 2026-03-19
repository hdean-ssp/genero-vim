-- Genero-Tools Lualine Integration
-- Provides custom statusline components for error/warning counts

local M = {}

-- Get error and warning counts for current buffer
local function get_diagnostic_counts()
  local bufnr = vim.api.nvim_get_current_buf()
  local errors = 0
  local warnings = 0

  -- Get all signs in the current buffer for compiler group
  local ok, signs = pcall(vim.fn.sign_getplaced, bufnr, { group = 'genero_compiler' })

  if ok and signs and #signs > 0 and signs[1].signs then
    for _, sign in ipairs(signs[1].signs) do
      if sign.name == 'GeneroCompilerError' then
        errors = errors + 1
      elseif sign.name == 'GeneroCompilerWarning' then
        warnings = warnings + 1
      end
    end
  end

  return { errors = errors, warnings = warnings }
end

-- Format diagnostics for lualine display with background colors
function M.diagnostics()
  local counts = get_diagnostic_counts()
  
  if counts.errors == 0 and counts.warnings == 0 then
    return ''
  end

  -- Build display string with color codes
  local parts = {}
  
  if counts.errors > 0 then
    table.insert(parts, '%#GeneroLualineError# E' .. counts.errors .. ' %*')
  end

  if counts.warnings > 0 then
    table.insert(parts, '%#GeneroLualineWarning# W' .. counts.warnings .. ' %*')
  end

  return table.concat(parts, '')
end

-- Setup highlight groups for lualine
function M.setup_highlights()
  -- Error highlight: dark red background, light text
  vim.api.nvim_set_hl(0, 'GeneroLualineError', {
    bg = '#8b0000',  -- Dark red
    fg = '#ffffff',
    bold = true,
  })
  
  -- Warning highlight: dark orange background, light text
  vim.api.nvim_set_hl(0, 'GeneroLualineWarning', {
    bg = '#cc6600',  -- Dark orange
    fg = '#ffffff',
    bold = true,
  })
end

-- Setup lualine integration
function M.setup()
  -- Initialize highlight groups
  M.setup_highlights()
end

return M
