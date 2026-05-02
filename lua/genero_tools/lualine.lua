-- Genero-Tools Lualine Integration
-- Provides custom statusline components for error/warning counts,
-- function signatures, SVN status, and cache statistics

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

-- Get SVN change counts for current buffer
local function get_svn_counts()
  local bufnr = vim.api.nvim_get_current_buf()
  local added = 0
  local modified = 0
  local deleted = 0

  local ok, signs = pcall(vim.fn.sign_getplaced, bufnr, { group = 'genero_svn' })

  if ok and signs and #signs > 0 and signs[1].signs then
    for _, sign in ipairs(signs[1].signs) do
      if sign.name == 'GeneroSVNAdded' then
        added = added + 1
      elseif sign.name == 'GeneroSVNModified' then
        modified = modified + 1
      elseif sign.name == 'GeneroSVNDeleted' then
        deleted = deleted + 1
      end
    end
  end

  return { added = added, modified = modified, deleted = deleted }
end

-- Get cache statistics from VimScript
local function get_cache_stats()
  local ok, stats = pcall(vim.fn['genero_tools#cache#stats'])
  if not ok or not stats then
    return nil
  end
  return stats
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

-- Breadcrumb: show module > file > function by scanning upward from cursor
-- Module detection is cached per file (no shell calls on every cursor move)
-- Respects END FUNCTION boundaries — returns empty if cursor is between functions
function M.breadcrumb()
  local row = vim.api.nvim_win_get_cursor(0)[1]

  -- Find enclosing function name
  local func_name = nil
  for i = row, 1, -1 do
    local line = vim.fn.getline(i)
    local trimmed = line:match('^%s*(.*)')
    if not trimmed then
      trimmed = ''
    end
    local upper = trimmed:upper()

    if upper:match('^END%s+FUNCTION') or upper:match('^END%s+MAIN') or upper:match('^END%s+REPORT') then
      break
    end

    if upper:match('^FUNCTION%s') then
      func_name = trimmed:match('^%w+%s+([%w_]+)')
      break
    elseif upper:match('^MAIN') and not upper:match('^MAIN%s*%(') then
      func_name = 'MAIN'
      break
    elseif upper:match('^REPORT%s') then
      func_name = trimmed:match('^%w+%s+([%w_]+)')
      break
    end
  end

  if not func_name then
    return ''
  end

  -- Build breadcrumb: module > file > function (module only if single-module)
  local file = vim.fn.expand('%:t')
  local module_name = M._get_cached_module()

  if module_name and module_name ~= '' then
    return '%#GeneroLualineCache# ' .. module_name .. ' %*'
      .. ' > %#Comment# ' .. file .. ' %*'
      .. ' > %#GeneroLualineFunctionName# ƒ ' .. func_name .. ' %*'
  else
    return '%#GeneroLualineFunctionName# ƒ ' .. func_name .. ' %*'
  end
end

-- Module cache for breadcrumb (avoids shell calls on every statusline refresh)
local module_cache = {}
local module_cache_ttl = 300  -- 5 minutes

function M._get_cached_module()
  local file_path = vim.fn.expand('%:p')
  if file_path == '' then
    return ''
  end

  local cached = module_cache[file_path]
  if cached and os.time() - cached.time < module_cache_ttl then
    return cached.value
  end

  -- Try to get from VimScript cache (populated by autocomplete module detection)
  local cache_key = 'file-module:' .. file_path
  local ok, vim_cached = pcall(vim.fn['genero_tools#cache#get'], cache_key)
  if ok and vim_cached and type(vim_cached) == 'table' and vim_cached.module then
    module_cache[file_path] = { value = vim_cached.module, time = os.time() }
    return vim_cached.module
  end

  -- Not yet detected — return empty (will populate when autocomplete runs)
  module_cache[file_path] = { value = '', time = os.time() }
  return ''
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

  -- SVN added highlight: green background
  vim.api.nvim_set_hl(0, 'GeneroLualineSVNAdded', {
    bg = '#1a4d2e',  -- Dark green
    fg = '#a7f3d0',  -- Light green text
    bold = true,
  })

  -- SVN modified highlight: yellow/amber background
  vim.api.nvim_set_hl(0, 'GeneroLualineSVNModified', {
    bg = '#78350f',  -- Dark amber
    fg = '#fde68a',  -- Light amber text
    bold = true,
  })

  -- SVN deleted highlight: red background
  vim.api.nvim_set_hl(0, 'GeneroLualineSVNDeleted', {
    bg = '#7f1d1d',  -- Dark red
    fg = '#fca5a5',  -- Light red text
    bold = true,
  })

  -- Cache stats highlight: gray background
  vim.api.nvim_set_hl(0, 'GeneroLualineCache', {
    bg = '#374151',  -- Dark gray
    fg = '#d1d5db',  -- Light gray text
  })
end

-- Display SVN change counts in statusline
-- Shows +added ~modified -deleted
function M.svn_status()
  local counts = get_svn_counts()

  if counts.added == 0 and counts.modified == 0 and counts.deleted == 0 then
    return ''
  end

  local parts = {}

  if counts.added > 0 then
    table.insert(parts, '%#GeneroLualineSVNAdded# +' .. counts.added .. ' %*')
  end

  if counts.modified > 0 then
    table.insert(parts, '%#GeneroLualineSVNModified# ~' .. counts.modified .. ' %*')
  end

  if counts.deleted > 0 then
    table.insert(parts, '%#GeneroLualineSVNDeleted# -' .. counts.deleted .. ' %*')
  end

  return table.concat(parts, '')
end

-- Display cache statistics in statusline
-- Shows cache size / max and hit rate
function M.cache_stats()
  local stats = get_cache_stats()
  if not stats then
    return ''
  end

  local size = stats.size or 0
  local max_size = stats.max_size or 0

  if size == 0 then
    return ''
  end

  return '%#GeneroLualineCache# C:' .. size .. '/' .. max_size .. ' %*'
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
