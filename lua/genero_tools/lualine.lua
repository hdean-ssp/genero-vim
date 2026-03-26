-- Genero-Tools Lualine Integration
-- Provides custom statusline components for error/warning counts and function signatures

local M = {}

-- Cache for function signatures (with TTL)
local signature_cache = {}
local cache_ttl = 3600  -- 1 hour in seconds

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

-- Get current function signature using concise format
-- Returns function signature or empty string if not found
local function get_current_function_signature()
  local bufnr = vim.api.nvim_get_current_buf()
  local row = vim.api.nvim_win_get_cursor(0)[1]
  
  -- Get the word under cursor
  local word = vim.fn.expand('<cword>')
  if not word or word == '' then
    return ''
  end
  
  -- Check cache first
  local cache_key = word .. ':' .. bufnr
  if signature_cache[cache_key] then
    local cached = signature_cache[cache_key]
    if os.time() - cached.time < cache_ttl then
      return cached.value
    else
      signature_cache[cache_key] = nil
    end
  end
  
  -- Try to get signature using Vim function call
  -- This calls genero_tools#get_function_concise() from Vim
  local ok, result = pcall(function()
    return vim.fn['genero_tools#get_function_concise'](word)
  end)
  
  if not ok or not result then
    return ''
  end
  
  -- Extract signature from result
  local signature = ''
  if type(result) == 'table' and result.data then
    if type(result.data) == 'string' then
      signature = vim.trim(result.data)
    elseif type(result.data) == 'table' and #result.data > 0 then
      signature = vim.trim(result.data[1])
    end
  elseif type(result) == 'string' then
    signature = vim.trim(result)
  end
  
  -- Cache the result
  if signature ~= '' then
    signature_cache[cache_key] = {
      value = signature,
      time = os.time()
    }
  end
  
  return signature
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

-- Display current function signature in statusline
-- Shows function signature with concise format (--format=vim)
function M.function_signature()
  local signature = get_current_function_signature()
  
  if signature == '' then
    return ''
  end
  
  -- Truncate if too long (max 50 chars)
  if #signature > 50 then
    signature = signature:sub(1, 47) .. '...'
  end
  
  return '%#GeneroLualineSignature# ' .. signature .. ' %*'
end

-- Display current function name (shorter version)
-- Shows just the function name without parameters
function M.function_name()
  local word = vim.fn.expand('<cword>')
  if not word or word == '' then
    return ''
  end
  
  return '%#GeneroLualineFunctionName# ' .. word .. ' %*'
end

-- Setup highlight groups for lualine
function M.setup_highlights()
  -- Error highlight: dark red background, light text
  vim.api.nvim_set_hl(0, 'GeneroLualineError', {
    bg = '#8b0000',  -- Dark red
    fg = '#ffffff',
    bold = true,
  })
  
  -- Warning highlight: dark yellow background, light text
  vim.api.nvim_set_hl(0, 'GeneroLualineWarning', {
    bg = '#8b8b00',  -- Dark yellow
    fg = '#ffffff',
    bold = true,
  })
  
  -- Function signature highlight: blue background
  vim.api.nvim_set_hl(0, 'GeneroLualineSignature', {
    bg = '#1e3a8a',  -- Dark blue
    fg = '#e0e7ff',  -- Light blue text
    italic = true,
  })
  
  -- Function name highlight: cyan background
  vim.api.nvim_set_hl(0, 'GeneroLualineFunctionName', {
    bg = '#0d3b66',  -- Dark cyan
    fg = '#90e0ef',  -- Light cyan text
    bold = true,
  })
end

-- Clear signature cache (useful for manual refresh)
function M.clear_cache()
  signature_cache = {}
end

-- Setup lualine integration
function M.setup()
  -- Initialize highlight groups
  M.setup_highlights()
end

return M
