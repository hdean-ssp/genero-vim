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

-- Format diagnostics for lualine display
function M.diagnostics()
  local counts = get_diagnostic_counts()
  local parts = {}

  if counts.errors > 0 then
    table.insert(parts, { 'E' .. counts.errors, 'lualine_diagnostics_error' })
  end

  if counts.warnings > 0 then
    table.insert(parts, { 'W' .. counts.warnings, 'lualine_diagnostics_warn' })
  end

  if #parts == 0 then
    return ''
  end

  -- Format as a single string with color codes
  local result = ''
  for i, part in ipairs(parts) do
    if i > 1 then
      result = result .. ' '
    end
    result = result .. part[1]
  end

  return result
end

-- Setup lualine integration
function M.setup()
  -- This function is called from the lualine config
  -- It registers the custom component
end

return M
