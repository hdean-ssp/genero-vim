-- Genero-Tools Snippets Module
-- Provides intelligent code snippet expansion for Genero patterns
-- Neovim-only feature using LuaSnip

local M = {}

-- Module dependencies
local Manager = require('genero_tools.snippets.manager')
local AsyncParams = require('genero_tools.snippets.async_params')

-- Initialize snippet system (Neovim only)
function M.setup()
  -- Check if LuaSnip is available
  local ok, luasnip = pcall(require, 'luasnip')
  if not ok then
    vim.api.nvim_err_writeln('Genero-Tools Snippets: LuaSnip not found. Install LuaSnip to use snippet features: https://github.com/L3MON4D3/LuaSnip')
    return
  end

  -- Load built-in snippets
  local builtin_snippets = Manager.load_builtin()
  
  -- Load custom snippets
  local custom_snippets = Manager.load_custom()

  -- Merge snippets (custom takes precedence)
  local all_snippets = M.merge_snippets(builtin_snippets, custom_snippets)

  -- Register with LuaSnip
  Manager.register_with_luasnip(all_snippets)

  -- Set up file watcher for hot-reload
  Manager.watch_files()

  -- Store reference for later use
  M.luasnip = luasnip
  M.snippets = all_snippets
end

-- Merge built-in and custom snippets
-- Custom snippets take precedence over built-in
function M.merge_snippets(builtin, custom)
  local merged = {}

  -- Add all built-in snippets
  for trigger, snippet in pairs(builtin) do
    merged[trigger] = snippet
  end

  -- Override with custom snippets
  for trigger, snippet in pairs(custom) do
    merged[trigger] = snippet
  end

  return merged
end

-- Get snippet by trigger
function M.get_snippet(trigger)
  if M.snippets then
    return M.snippets[trigger]
  end
  return Manager.get_snippet(trigger)
end

-- List all available snippets
function M.list_snippets()
  if M.snippets then
    return M.snippets
  end
  return Manager.list_snippets()
end

-- Expand snippet by trigger
function M.expand_snippet(trigger)
  if not M.luasnip then
    vim.api.nvim_err_writeln('Genero-Tools Snippets: LuaSnip not available')
    return false
  end

  local snippet = M.get_snippet(trigger)
  if not snippet then
    vim.api.nvim_err_writeln('Genero-Tools Snippets: Snippet not found: ' .. trigger)
    return false
  end

  -- Expand snippet using LuaSnip
  M.luasnip.snip_expand(snippet)
  return true
end

-- Populate function parameters asynchronously
function M.populate_function_params(function_name, callback)
  AsyncParams.query_signature(function_name, function(signature)
    if signature then
      callback(AsyncParams.populate_from_signature(nil, signature))
    else
      callback(AsyncParams.fallback_parameters(nil))
    end
  end)
end

-- Check if LuaSnip is available
function M.is_luasnip_available()
  return M.luasnip ~= nil
end

-- Get module version
function M.version()
  return '1.0.0'
end

-- Health check for snippets module
function M.health_check()
  local health = {
    version = M.version(),
    luasnip_available = M.is_luasnip_available(),
    snippets_loaded = M.snippets ~= nil,
    snippet_count = M.snippets and vim.tbl_count(M.snippets) or 0,
  }
  return health
end

-- List all available snippets in a formatted display
function M.list_snippets_display()
  if not M.snippets then
    vim.api.nvim_err_writeln('Genero-Tools Snippets: No snippets loaded')
    return
  end

  local lines = { 'Available Snippets:', '', 'Trigger | Name | Description' }
  table.insert(lines, string.rep('-', 80))

  -- Sort snippets by trigger for consistent display
  local sorted_triggers = {}
  for trigger, _ in pairs(M.snippets) do
    table.insert(sorted_triggers, trigger)
  end
  table.sort(sorted_triggers)

  -- Format each snippet
  for _, trigger in ipairs(sorted_triggers) do
    local snippet = M.snippets[trigger]
    local name = snippet.name or trigger
    local desc = snippet.description or ''

    -- Truncate long descriptions
    if #desc > 50 then
      desc = desc:sub(1, 47) .. '...'
    end

    local line = string.format('%-10s | %-30s | %s', trigger, name, desc)
    table.insert(lines, line)
  end

  table.insert(lines, '')
  table.insert(lines, 'Use :GeneroSnippetHelp <trigger> for more details')

  -- Display in floating window
  local UI = require('genero_tools.ui')
  UI.show_floating_window(lines, {
    title = 'Genero Snippets',
    width = 90,
    border = 'rounded',
  })
end

-- Display help for a specific snippet
function M.show_help(trigger)
  -- Handle case where trigger is passed as array from luaeval
  if type(trigger) == 'table' and trigger[1] then
    trigger = trigger[1]
  end
  
  if not M.snippets then
    vim.api.nvim_err_writeln('Genero-Tools Snippets: No snippets loaded')
    return
  end

  local snippet = M.snippets[trigger]
  if not snippet then
    vim.api.nvim_err_writeln('Genero-Tools Snippets: Snippet not found: ' .. trigger)
    return
  end

  local lines = {}

  -- Header
  table.insert(lines, 'Snippet: ' .. (snippet.name or trigger))
  table.insert(lines, '')

  -- Trigger
  table.insert(lines, 'Trigger: ' .. trigger)
  table.insert(lines, '')

  -- Description
  if snippet.description then
    table.insert(lines, 'Description:')
    table.insert(lines, snippet.description)
    table.insert(lines, '')
  end

  -- Body
  if snippet.body then
    table.insert(lines, 'Template:')
    table.insert(lines, '---')
    for line in snippet.body:gmatch('[^\n]+') do
      table.insert(lines, line)
    end
    table.insert(lines, '---')
    table.insert(lines, '')
  end

  -- Placeholders
  if snippet.placeholders then
    table.insert(lines, 'Placeholders:')
    for i, placeholder in ipairs(snippet.placeholders) do
      local label = placeholder.label or ('placeholder_' .. i)
      local ptype = placeholder.type or 'text'
      table.insert(lines, string.format('  ${%d:%s} - %s', i, label, ptype))
    end
    table.insert(lines, '')
  end

  -- Usage
  table.insert(lines, 'Usage:')
  table.insert(lines, '  Type "' .. trigger .. '" and press Tab to expand')
  table.insert(lines, '  Or use :GeneroSnippet ' .. trigger)

  -- Display in floating window
  local UI = require('genero_tools.ui')
  UI.show_floating_window(lines, {
    title = 'Snippet Help: ' .. trigger,
    width = 80,
    border = 'rounded',
  })
end

-- Expand a snippet by name/trigger
function M.expand_by_name(trigger)
  -- Handle case where trigger is passed as array from luaeval
  if type(trigger) == 'table' and trigger[1] then
    trigger = trigger[1]
  end
  
  -- Try to load LuaSnip if not already loaded
  if not M.luasnip then
    local ok, luasnip = pcall(require, 'luasnip')
    if not ok then
      vim.api.nvim_err_writeln('Genero-Tools Snippets: LuaSnip not available. Install LuaSnip to use snippet expansion.')
      return false
    end
    M.luasnip = luasnip
  end
  
  -- Try to load snippets if not already loaded
  if not M.snippets then
    M.setup()
  end
  
  if not M.snippets or vim.tbl_count(M.snippets) == 0 then
    vim.api.nvim_err_writeln('Genero-Tools Snippets: No snippets loaded')
    return false
  end

  local snippet = M.get_snippet(trigger)
  if not snippet then
    vim.api.nvim_err_writeln('Genero-Tools Snippets: Snippet not found: ' .. trigger)
    return false
  end

  if not snippet.body then
    vim.api.nvim_err_writeln('Genero-Tools Snippets: Snippet has no body: ' .. trigger)
    return false
  end

  -- Get current buffer and cursor position
  local buf = vim.api.nvim_get_current_buf()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))

  -- Parse snippet body to extract placeholders
  local body = snippet.body
  
  -- Remove leading/trailing whitespace from body
  body = body:gsub('^%s+', ''):gsub('%s+$', '')
  
  -- Split into lines
  local lines = vim.split(body, '\n')

  -- Remove leading/trailing empty lines
  while #lines > 0 and lines[1]:match('^%s*$') do
    table.remove(lines, 1)
  end
  while #lines > 0 and lines[#lines]:match('^%s*$') do
    table.remove(lines)
  end

  if #lines == 0 then
    vim.api.nvim_err_writeln('Genero-Tools Snippets: Snippet body is empty: ' .. trigger)
    return false
  end

  -- Insert lines at cursor
  vim.api.nvim_buf_set_lines(buf, row - 1, row - 1, false, lines)

  -- Create a temporary snippet with the body and expand it
  local ls = require('luasnip')
  local s = ls.snippet
  local t = ls.text_node
  
  -- Create snippet object with the body
  local temp_snippet = s(trigger, t(body))
  
  -- Position cursor at the start of inserted text
  vim.api.nvim_win_set_cursor(0, { row, col })
  
  -- Expand the snippet using LuaSnip
  pcall(function()
    ls.snip_expand(temp_snippet)
  end)

  return true
end

-- Get all snippets as array for VimScript
function M.get_all_snippets()
  if not M.snippets then
    M.setup()
  end
  
  if not M.snippets or vim.tbl_count(M.snippets) == 0 then
    return {}
  end
  
  local snippets_array = {}
  
  -- Convert snippets table to array format for VimScript
  for trigger, snippet in pairs(M.snippets) do
    local snippet_obj = {
      trigger = trigger,
      name = snippet.name or trigger,
      description = snippet.description or '',
      body = snippet.body or '',
    }
    table.insert(snippets_array, snippet_obj)
  end
  
  return snippets_array
end

-- Expand snippet with LuaSnip (with placeholder support)
function M.expand_with_luasnip(trigger)
  -- Handle case where trigger is passed as array from luaeval
  if type(trigger) == 'table' and trigger[1] then
    trigger = trigger[1]
  end
  
  -- Try to load LuaSnip if not already loaded
  if not M.luasnip then
    local ok, luasnip = pcall(require, 'luasnip')
    if not ok then
      vim.api.nvim_err_writeln('Genero-Tools Snippets: LuaSnip not available. Install LuaSnip to use snippet expansion.')
      return false
    end
    M.luasnip = luasnip
  end
  
  -- Try to load snippets if not already loaded
  if not M.snippets then
    M.setup()
  end
  
  if not M.snippets or vim.tbl_count(M.snippets) == 0 then
    vim.api.nvim_err_writeln('Genero-Tools Snippets: No snippets loaded')
    return false
  end

  local snippet = M.get_snippet(trigger)
  if not snippet then
    vim.api.nvim_err_writeln('Genero-Tools Snippets: Snippet not found: ' .. trigger)
    return false
  end

  if not snippet.body then
    vim.api.nvim_err_writeln('Genero-Tools Snippets: Snippet has no body: ' .. trigger)
    return false
  end

  -- Get current buffer and cursor position
  local buf = vim.api.nvim_get_current_buf()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))

  -- Parse snippet body
  local body = snippet.body
  body = body:gsub('^%s+', ''):gsub('%s+$', '')
  
  -- Split into lines
  local lines = vim.split(body, '\n')

  -- Remove leading/trailing empty lines
  while #lines > 0 and lines[1]:match('^%s*$') do
    table.remove(lines, 1)
  end
  while #lines > 0 and lines[#lines]:match('^%s*$') do
    table.remove(lines)
  end

  if #lines == 0 then
    vim.api.nvim_err_writeln('Genero-Tools Snippets: Snippet body is empty: ' .. trigger)
    return false
  end

  -- Insert lines at cursor
  vim.api.nvim_buf_set_lines(buf, row - 1, row - 1, false, lines)

  -- Create snippet with placeholder support
  local ls = require('luasnip')
  local s = ls.snippet
  local t = ls.text_node
  local i = ls.insert_node
  
  -- Parse body for placeholders (${1:label}, ${2:label}, etc.)
  local parsed_body = M.parse_snippet_body(body, snippet.placeholders)
  
  -- Create snippet object with parsed body
  local temp_snippet = s(trigger, parsed_body)
  
  -- Position cursor at the start of inserted text
  vim.api.nvim_win_set_cursor(0, { row, col })
  
  -- Expand the snippet using LuaSnip
  pcall(function()
    ls.snip_expand(temp_snippet)
  end)

  return true
end

-- Parse snippet body and create LuaSnip nodes with placeholder support
function M.parse_snippet_body(body, placeholders)
  local ls = require('luasnip')
  local t = ls.text_node
  local i = ls.insert_node
  
  local nodes = {}
  local placeholder_index = 1
  local last_pos = 1
  
  -- Find all ${N:label} patterns
  for match in body:gmatch('${(%d+):([^}]*)}') do
    local num = tonumber(match)
    if num then
      placeholder_index = math.max(placeholder_index, num + 1)
    end
  end
  
  -- For now, create a simple text node with the body
  -- Full placeholder parsing would require more complex logic
  table.insert(nodes, t(body))
  
  return nodes
end

-- Navigate to next placeholder in snippet
function M.next_placeholder()
  if not M.luasnip then
    return false
  end
  
  local ls = require('luasnip')
  if ls.jumpable(1) then
    ls.jump(1)
    return true
  end
  
  return false
end

-- Navigate to previous placeholder in snippet
function M.prev_placeholder()
  if not M.luasnip then
    return false
  end
  
  local ls = require('luasnip')
  if ls.jumpable(-1) then
    ls.jump(-1)
    return true
  end
  
  return false
end

return M
