-- Genero-Tools Snippet Integration
-- Provides integration with GeneroLookup and autocomplete features

local M = {}

-- Integration with GeneroLookup
-- Offers snippet expansion option after function lookup
function M.offer_snippet_after_lookup(function_name)
  if not function_name or function_name == '' then
    return
  end

  -- Check if snippets are enabled
  local config = vim.g.genero_tools_config or {}
  if not config.snippets_enabled then
    return
  end

  -- Get the snippets module
  local ok, snippets = pcall(require, 'genero_tools.snippets')
  if not ok then
    return
  end

  -- Offer to expand function call snippet
  local choice = vim.fn.confirm(
    'Expand function call snippet for ' .. function_name .. '?',
    '&Yes\n&No',
    2
  )

  if choice == 1 then
    -- Expand function call snippet with the looked-up function
    M.expand_function_call_snippet(function_name)
  end
end

-- Expand a function call snippet with the given function name
function M.expand_function_call_snippet(function_name)
  if not function_name or function_name == '' then
    vim.notify('No function name provided', vim.log.levels.WARN)
    return
  end

  -- Get the snippets module
  local ok, snippets = pcall(require, 'genero_tools.snippets')
  if not ok then
    vim.notify('Snippets module not available', vim.log.levels.ERROR)
    return
  end

  -- Get the async params module
  local ok_async, async_params = pcall(require, 'genero_tools.snippets.async_params')
  if not ok_async then
    vim.notify('Async params module not available', vim.log.levels.ERROR)
    return
  end

  -- Check if smart expansion is enabled
  local config = vim.g.genero_tools_config or {}
  local smart_expansion = config.snippet_smart_expansion ~= false

  if smart_expansion then
    -- Query function signature asynchronously
    async_params.query_signature(function_name, function(signature)
      if signature then
        -- Populate parameters from signature
        local param_context = async_params.populate_from_signature(nil, signature)
        -- Build function call snippet with populated parameters
        local snippet_body = async_params.build_function_call_snippet(function_name, signature)
        -- Insert the snippet
        M.insert_snippet_at_cursor(snippet_body)
      else
        -- Fallback to generic parameters
        local snippet_body = M.build_generic_function_call_snippet(function_name)
        M.insert_snippet_at_cursor(snippet_body)
      end
    end)
  else
    -- Use generic function call snippet
    local snippet_body = M.build_generic_function_call_snippet(function_name)
    M.insert_snippet_at_cursor(snippet_body)
  end
end

-- Build a generic function call snippet
function M.build_generic_function_call_snippet(function_name)
  return string.format(
    'CALL %s(${1:param1}, ${2:param2})',
    function_name
  )
end

-- Insert a snippet at the current cursor position
function M.insert_snippet_at_cursor(snippet_body)
  if not snippet_body or snippet_body == '' then
    vim.notify('Snippet body is empty', vim.log.levels.ERROR)
    return
  end

  -- Get current buffer and cursor position
  local buf = vim.api.nvim_get_current_buf()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))

  -- Split snippet body into lines
  local lines = vim.split(snippet_body, '\n')

  -- Remove leading/trailing empty lines
  while #lines > 0 and lines[1]:match('^%s*$') do
    table.remove(lines, 1)
  end
  while #lines > 0 and lines[#lines]:match('^%s*$') do
    table.remove(lines)
  end

  if #lines == 0 then
    vim.notify('Snippet body is empty after processing', vim.log.levels.ERROR)
    return
  end

  -- Insert lines at cursor
  vim.api.nvim_buf_set_lines(buf, row - 1, row - 1, false, lines)

  -- Try to expand with LuaSnip if available
  local ok, luasnip = pcall(require, 'luasnip')
  if ok and luasnip.expand then
    -- Position cursor at first placeholder
    vim.api.nvim_win_set_cursor(0, { row, col })
    -- Try to expand
    pcall(function()
      luasnip.expand()
    end)
  end
end

-- Integration with autocomplete
-- Offers snippet expansion option in autocomplete menu
function M.offer_snippet_in_autocomplete(function_name)
  if not function_name or function_name == '' then
    return
  end

  -- Check if snippets are enabled
  local config = vim.g.genero_tools_config or {}
  if not config.snippets_enabled then
    return
  end

  -- This would be called from autocomplete integration
  -- For now, just provide the function for future use
  return {
    action = 'expand_snippet',
    function_name = function_name,
  }
end

-- Get snippet configuration
function M.get_snippet_config()
  local config = vim.g.genero_tools_config or {}
  return {
    enabled = config.snippets_enabled ~= false,
    engine = config.snippet_engine or 'luasnip',
    smart_expansion = config.snippet_smart_expansion ~= false,
    custom_dir = config.snippet_custom_dir or vim.fn.expand('~/.config/nvim/genero-snippets'),
  }
end

-- Check if snippets are available
function M.snippets_available()
  local config = M.get_snippet_config()
  if not config.enabled then
    return false
  end

  -- Check if LuaSnip is available
  local ok, luasnip = pcall(require, 'luasnip')
  return ok and luasnip ~= nil
end

return M
