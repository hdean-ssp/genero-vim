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

-- Breadcrumb: show module.m3  file.4gl  ƒ function_name
-- Powerline arrows () create seamless transitions between sections
-- Module and file always show when module is detected
-- Function name only shows when cursor is inside a function
-- Colors: dimmest (module) → medium (file) → brightest (function)
function M.breadcrumb()
  local module_name = M._get_cached_module()
  local file = vim.fn.expand('%:t')
  local func_name = M._find_enclosing_function()

  local has_module = module_name and module_name ~= ''
  local has_file = file ~= ''
  local has_func = func_name and func_name ~= ''

  if not has_file then
    return ''
  end

  local result = ''

  -- Module (dimmest)
  if has_module then
    local display_module = module_name
    if not display_module:match('%.m[34]$') then
      display_module = display_module .. '.m3'
    end
    result = result .. '%#GeneroLualineModule# ' .. display_module .. ' '

    -- Arrow: module bg → file bg
    result = result .. '%#GeneroSepModuleFile#%*'
  end

  -- File (medium) — always shown, with modified indicator
  local modified = vim.bo.modified and ' ●' or ''
  result = result .. '%#GeneroLualineFile# ' .. file .. modified .. ' '

  if has_func then
    -- Arrow: file bg → function bg
    result = result .. '%#GeneroSepFileFunc#%*'
  else
    -- Arrow: file bg → statusline bg
    result = result .. '%#GeneroSepFileEnd#%*'
  end

  -- Function (brightest) — only when cursor is inside a function
  if has_func then
    result = result .. '%#GeneroLualineFunctionName# ƒ ' .. func_name .. ' '

    -- Reference count (dimmer than function name, appended after it)
    local ref_count = M._get_refcount(func_name)
    if ref_count then
      result = result .. '%#GeneroSepFuncRef#%*'
      local ref_text = ref_count == 1 and '1 ref' or ref_count .. ' refs'
      result = result .. '%#GeneroLualineRefCount# ' .. ref_text .. ' '
      result = result .. '%#GeneroSepRefEnd#%*'
    else
      -- Arrow: function bg → statusline bg
      result = result .. '%#GeneroSepFuncEnd#%*'
    end
  end

  return result
end

-- Get reference count for a function from the refcount cache
-- If not cached, triggers an async fetch so it appears on next statusline refresh
-- Returns count (number) or nil if not available yet
function M._get_refcount(func_name)
  if not func_name or func_name == '' then
    return nil
  end
  local ok, cache = pcall(function()
    return vim.g.genero_tools_refcount_cache
  end)
  if not ok or not cache or type(cache) ~= 'table' then
    cache = {}
  end
  local count = cache[func_name]
  if count ~= nil then
    return tonumber(count)
  end

  -- Not cached — trigger async fetch via find-function-dependents
  -- Use a local guard to avoid duplicate fetches for the same function
  if M._refcount_pending and M._refcount_pending[func_name] then
    return nil
  end
  if not M._refcount_pending then
    M._refcount_pending = {}
  end
  M._refcount_pending[func_name] = true

  vim.schedule(function()
    local ok_path, tool_path = pcall(vim.fn['genero_tools#config#get'], 'genero_tools_path')
    if not ok_path or not tool_path or tool_path == '' then
      M._refcount_pending[func_name] = nil
      return
    end
    local ok_esc, escaped = pcall(vim.fn['genero_tools#command#escape_arg'], func_name)
    if not ok_esc or not escaped then
      M._refcount_pending[func_name] = nil
      return
    end
    local cmd = tool_path .. ' find-function-dependents ' .. escaped

    -- Use jobstart for async execution (non-blocking)
    local output_lines = {}
    vim.fn.jobstart(cmd, {
      stdout_buffered = true,
      on_stdout = function(_, data)
        if data then
          output_lines = data
        end
      end,
      on_exit = function(_, exit_code)
        M._refcount_pending[func_name] = nil
        if exit_code ~= 0 then
          return
        end
        local output = table.concat(output_lines, '\n')
        if output == '' then
          return
        end
        local decode_ok, data = pcall(vim.fn.json_decode, output)
        if decode_ok and type(data) == 'table' then
          local rc = vim.g.genero_tools_refcount_cache or {}
          rc[func_name] = #data
          vim.g.genero_tools_refcount_cache = rc
        end
      end,
    })
  end)

  return nil
end

-- Find the enclosing function name by scanning upward from cursor
-- Returns function name or nil if cursor is between/outside functions
function M._find_enclosing_function()
  local row = vim.api.nvim_win_get_cursor(0)[1]

  for i = row, 1, -1 do
    local line = vim.fn.getline(i)
    local trimmed = line:match('^%s*(.*)')
    if not trimmed then
      trimmed = ''
    end
    local upper = trimmed:upper()

    -- Hit END FUNCTION before finding opener = between functions
    if upper:match('^END%s+FUNCTION') or upper:match('^END%s+MAIN') or upper:match('^END%s+REPORT') then
      return nil
    end

    if upper:match('^FUNCTION%s') then
      return trimmed:match('^%w+%s+([%w_]+)')
    elseif upper:match('^MAIN') and not upper:match('^MAIN%s*%(') then
      return 'MAIN'
    elseif upper:match('^REPORT%s') then
      return trimmed:match('^%w+%s+([%w_]+)')
    end
  end

  return nil
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

  -- Schedule detection so it doesn't block statusline rendering
  -- First call returns empty, result populates on next lualine refresh (~1s)
  if not cached then
    module_cache[file_path] = { value = '', time = os.time() - module_cache_ttl + 5 }
    vim.schedule(function()
      -- Reuse telescope's detect_module which has the basename fallback
      local ok, telescope = pcall(require, 'genero_tools.telescope')
      if not ok then
        module_cache[file_path] = { value = '', time = os.time() }
        return
      end
      -- telescope.detect_module is local, so call module_functions' logic inline
      -- Step 1: get a function name from this file
      local basename = './' .. vim.fn.fnamemodify(file_path, ':t')
      local ok_rel, rel = pcall(vim.fn['genero_tools#normalize_file_path'], file_path)
      if not ok_rel then rel = basename end

      local funcs_result = nil
      -- Try normalized path first
      local ok1, r1 = pcall(vim.fn['genero_tools#command#execute_shell'], 'list-file-functions', { rel })
      if ok1 and r1 and r1.success == 1 and type(r1.data) == 'table' and r1.data[1] then
        funcs_result = r1
      else
        -- Fallback: basename only
        local ok2, r2 = pcall(vim.fn['genero_tools#command#execute_shell'], 'list-file-functions', { basename })
        if ok2 and r2 and r2.success == 1 and type(r2.data) == 'table' and r2.data[1] then
          funcs_result = r2
        end
      end

      if not funcs_result then
        module_cache[file_path] = { value = '', time = os.time() }
        return
      end

      local func_name = type(funcs_result.data[1]) == 'table' and funcs_result.data[1].name or ''
      if func_name == '' then
        module_cache[file_path] = { value = '', time = os.time() }
        return
      end

      -- Step 2: find module for this function
      local mod_ok, mod_result = pcall(vim.fn['genero_tools#command#execute_shell'],
        'find-module-for-function', { func_name })
      if not mod_ok or not mod_result or mod_result.success ~= 1 or not mod_result.data then
        module_cache[file_path] = { value = '', time = os.time() }
        return
      end

      local mod_data = mod_result.data
      local module_name = ''
      if type(mod_data) == 'string' and mod_data ~= '' then
        module_name = mod_data
      elseif type(mod_data) == 'table' then
        local count = 0
        for _ in pairs(mod_data) do count = count + 1 end
        if count == 1 and mod_data[1] then
          local item = mod_data[1]
          module_name = type(item) == 'table' and (item.name or item.module or '') or tostring(item)
        end
      end
      module_cache[file_path] = { value = module_name, time = os.time() }
    end)
    return ''
  end

  return cached.value
end

-- Helper: get a highlight group's fg or bg color as a hex string
local function get_hl_color(group, attr)
  local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
  if not ok or not hl then
    return nil
  end
  local val = hl[attr]
  if not val then
    return nil
  end
  return string.format('#%06x', val)
end

-- Helper: blend two hex colors (0.0 = color1, 1.0 = color2)
local function blend(hex1, hex2, factor)
  if not hex1 or not hex2 then
    return hex1 or hex2 or '#1a1a2e'
  end
  local r1, g1, b1 = hex1:match('#(%x%x)(%x%x)(%x%x)')
  local r2, g2, b2 = hex2:match('#(%x%x)(%x%x)(%x%x)')
  if not r1 or not r2 then
    return hex1
  end
  r1, g1, b1 = tonumber(r1, 16), tonumber(g1, 16), tonumber(b1, 16)
  r2, g2, b2 = tonumber(r2, 16), tonumber(g2, 16), tonumber(b2, 16)
  local r = math.floor(r1 + (r2 - r1) * factor)
  local g = math.floor(g1 + (g2 - g1) * factor)
  local b = math.floor(b1 + (b2 - b1) * factor)
  return string.format('#%02x%02x%02x', r, g, b)
end

-- Setup highlight groups for lualine
-- Derives breadcrumb colors from the active colorscheme so they adapt to any theme
function M.setup_highlights()
  -- Read base colors from the active theme
  local normal_bg = get_hl_color('Normal', 'bg') or '#1a1a2e'
  local normal_fg = get_hl_color('Normal', 'fg') or '#c0c0c0'
  local func_fg = get_hl_color('Function', 'fg') or normal_fg
  local comment_fg = get_hl_color('Comment', 'fg') or '#606060'
  local string_fg = get_hl_color('String', 'fg') or func_fg

  -- Build 4-level brightness gradient for breadcrumb sections:
  -- module (dimmest) → file → function (brightest) → refcount (subdued)
  local module_bg = blend(normal_bg, comment_fg, 0.08)
  local module_fg = blend(comment_fg, normal_fg, 0.15)
  local file_bg = blend(normal_bg, func_fg, 0.12)
  local file_fg = blend(comment_fg, normal_fg, 0.45)
  local func_bg = blend(normal_bg, func_fg, 0.20)
  local func_fg_color = blend(func_fg, normal_fg, 0.6)
  local ref_bg = blend(normal_bg, comment_fg, 0.05)
  local ref_fg = blend(comment_fg, normal_fg, 0.1)

  -- Error highlight: dark red background, light text
  vim.api.nvim_set_hl(0, 'GeneroLualineError', {
    bg = blend(normal_bg, '#ff0000', 0.3),
    fg = '#ffffff',
    bold = true,
  })

  -- Warning highlight: dark yellow background, light text
  vim.api.nvim_set_hl(0, 'GeneroLualineWarning', {
    bg = blend(normal_bg, '#ffff00', 0.25),
    fg = '#ffffff',
    bold = true,
  })

  -- Function signature highlight
  vim.api.nvim_set_hl(0, 'GeneroLualineSignature', {
    bg = blend(normal_bg, string_fg, 0.15),
    fg = blend(string_fg, normal_fg, 0.5),
    italic = true,
  })

  -- Breadcrumb sections: dim → bright
  vim.api.nvim_set_hl(0, 'GeneroLualineFunctionName', {
    bg = func_bg,
    fg = func_fg_color,
    bold = true,
  })

  vim.api.nvim_set_hl(0, 'GeneroLualineFile', {
    bg = file_bg,
    fg = file_fg,
  })

  vim.api.nvim_set_hl(0, 'GeneroLualineModule', {
    bg = module_bg,
    fg = module_fg,
    italic = true,
  })

  -- Powerline arrow separators (fg = prev bg, bg = next bg)
  vim.api.nvim_set_hl(0, 'GeneroSepModuleFile', { fg = module_bg, bg = file_bg })
  vim.api.nvim_set_hl(0, 'GeneroSepModuleFunc', { fg = module_bg, bg = func_bg })
  vim.api.nvim_set_hl(0, 'GeneroSepModuleEnd', { fg = module_bg, bg = 'NONE' })
  vim.api.nvim_set_hl(0, 'GeneroSepFileFunc', { fg = file_bg, bg = func_bg })
  vim.api.nvim_set_hl(0, 'GeneroSepFileEnd', { fg = file_bg, bg = 'NONE' })
  vim.api.nvim_set_hl(0, 'GeneroSepFuncEnd', { fg = func_bg, bg = 'NONE' })

  -- Reference count: subdued
  vim.api.nvim_set_hl(0, 'GeneroLualineRefCount', {
    bg = ref_bg,
    fg = ref_fg,
    italic = true,
  })
  vim.api.nvim_set_hl(0, 'GeneroSepFuncRef', { fg = func_bg, bg = ref_bg })
  vim.api.nvim_set_hl(0, 'GeneroSepRefEnd', { fg = ref_bg, bg = 'NONE' })

  -- SVN highlights: blend theme colors with semantic colors
  vim.api.nvim_set_hl(0, 'GeneroLualineSVNAdded', {
    bg = blend(normal_bg, '#00ff00', 0.15),
    fg = blend('#00ff00', normal_fg, 0.6),
    bold = true,
  })

  vim.api.nvim_set_hl(0, 'GeneroLualineSVNModified', {
    bg = blend(normal_bg, '#ffaa00', 0.15),
    fg = blend('#ffaa00', normal_fg, 0.6),
    bold = true,
  })

  vim.api.nvim_set_hl(0, 'GeneroLualineSVNDeleted', {
    bg = blend(normal_bg, '#ff0000', 0.15),
    fg = blend('#ff0000', normal_fg, 0.6),
    bold = true,
  })

  -- Cache stats: subtle
  vim.api.nvim_set_hl(0, 'GeneroLualineCache', {
    bg = blend(normal_bg, comment_fg, 0.1),
    fg = comment_fg,
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
  -- Initialize highlight groups from current theme
  M.setup_highlights()

  -- Re-derive colors when the colorscheme changes
  vim.api.nvim_create_autocmd('ColorScheme', {
    group = vim.api.nvim_create_augroup('GeneroLualineColors', { clear = true }),
    callback = function()
      M.setup_highlights()
    end,
  })
end

return M
