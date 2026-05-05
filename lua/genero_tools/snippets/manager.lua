-- Genero-Tools Snippet Manager
-- Handles loading, merging, and registering snippets with LuaSnip

local M = {}

-- Built-in snippets cache
local builtin_snippets = {}

-- Custom snippets cache
local custom_snippets = {}

-- File watcher timer
local watch_timer = nil

-- Load built-in Genero snippets
function M.load_builtin()
  if vim.tbl_count(builtin_snippets) > 0 then
    return builtin_snippets
  end

  -- Load snippets from templates/builtin/ directory
  -- Get the directory of this file (lua/genero_tools/snippets/manager.lua)
  -- Then go up to lua/ and construct the path to templates/builtin
  local this_file = debug.getinfo(1).source:sub(2)
  local this_dir = vim.fn.fnamemodify(this_file, ':h')  -- lua/genero_tools/snippets
  local snippet_dir = vim.fn.fnamemodify(this_dir, ':h:h') .. '/genero_tools/snippets/templates/builtin'

  -- Load all Lua files from builtin directory
  builtin_snippets = M.load_snippets_from_directory(snippet_dir)

  return builtin_snippets
end

-- Load custom snippets from user directory
function M.load_custom()
  if vim.tbl_count(custom_snippets) > 0 then
    return custom_snippets
  end

  -- Custom snippet directory for Neovim
  local custom_dir = vim.fn.expand('~/.config/nvim/genero-snippets')

  -- Create directory if it doesn't exist
  if vim.fn.isdirectory(custom_dir) == 0 then
    vim.fn.mkdir(custom_dir, 'p')
  end

  -- Load Lua files from custom directory
  custom_snippets = M.load_snippets_from_directory(custom_dir)

  return custom_snippets
end

-- Load snippets from a directory
function M.load_snippets_from_directory(dir)
  local snippets = {}

  if vim.fn.isdirectory(dir) == 0 then
    return snippets
  end

  -- Get list of Lua files in directory
  local files = vim.fn.glob(dir .. '/*.lua', false, true)

  for _, file in ipairs(files) do
    -- Skip .gitkeep and README files
    if file:match('%.gitkeep$') or file:match('README%.md$') then
      goto continue
    end

    local ok, loaded_snippets = pcall(function()
      -- Load Lua file and execute it
      local chunk = loadfile(file)
      if chunk then
        return chunk()
      end
      return {}
    end)

    if ok and type(loaded_snippets) == 'table' then
      -- Merge loaded snippets
      -- loaded_snippets is an array of snippet objects
      for _, snippet in ipairs(loaded_snippets) do
        if snippet.trigger then
          snippets[snippet.trigger] = snippet
        end
      end
    else
      vim.api.nvim_err_writeln('Genero-Tools Snippets: Error loading snippets from ' .. file)
    end

    ::continue::
  end

  return snippets
end

-- Register snippets with LuaSnip
function M.register_with_luasnip(snippets)
  local ok, luasnip = pcall(require, 'luasnip')
  if not ok then
    vim.api.nvim_err_writeln('Genero-Tools Snippets: LuaSnip not available')
    return
  end

  -- Create snippet objects using LuaSnip's Snippet class
  local ls = require('luasnip')
  local s = ls.snippet
  local t = ls.text_node
  local i = ls.insert_node
  
  local snippet_list = {}
  
  -- Convert our snippets to LuaSnip format
  for trigger, snippet_data in pairs(snippets) do
    if snippet_data.body then
      -- Parse the snippet body to create nodes with placeholder support
      local nodes = M.parse_snippet_nodes(snippet_data.body)
      if nodes and #nodes > 0 then
        local snippet_obj = s(trigger, nodes)
        table.insert(snippet_list, snippet_obj)
      end
    end
  end
  
  -- Register snippets for genero filetypes (4gl, fgl, per)
  if #snippet_list > 0 then
    ls.add_snippets('4gl', snippet_list)
    ls.add_snippets('fgl', snippet_list)
    ls.add_snippets('per', snippet_list)
  end
end

-- Parse snippet body and create LuaSnip nodes with placeholder support
function M.parse_snippet_nodes(body)
  local ls = require('luasnip')
  local t = ls.text_node
  local i = ls.insert_node
  
  if not body or body == '' then
    return { t('') }
  end

  local nodes = {}
  local pos = 1
  local pattern = '%$%{(%d+):([^}]*)%}'
  
  -- Parse the body and create nodes for text and placeholders
  while pos <= #body do
    local start, finish, num_str, label = body:find(pattern, pos)
    
    if not start then
      -- No more placeholders, add remaining text
      if pos <= #body then
        table.insert(nodes, t(body:sub(pos)))
      end
      break
    end
    
    -- Add text before placeholder
    if start > pos then
      table.insert(nodes, t(body:sub(pos, start - 1)))
    end
    
    -- Add placeholder as insert node with the label as default text
    local num = tonumber(num_str)
    table.insert(nodes, i(num, label))
    
    -- Move position past this placeholder
    pos = finish + 1
  end
  
  -- If no nodes were created, return the body as a single text node
  if #nodes == 0 then
    table.insert(nodes, t(body))
  end
  
  return nodes
end

-- Watch for snippet file changes and reload
function M.watch_files()
  -- Determine custom snippet directory
  local custom_dir = vim.fn.expand('~/.config/nvim/genero-snippets')

  -- Create autocommand group for file watching
  local group = vim.api.nvim_create_augroup('GeneroSnippetsWatch', { clear = true })

  -- Watch for file changes in custom snippet directory
  vim.api.nvim_create_autocmd('BufWritePost', {
    group = group,
    pattern = custom_dir .. '/*.lua',
    callback = function()
      -- Clear custom snippets cache
      custom_snippets = {}

      -- Reload custom snippets
      local new_custom = M.load_custom()

      -- Re-register with LuaSnip
      M.register_with_luasnip(new_custom)
    end,
  })
end

-- Get snippet by trigger
function M.get_snippet(trigger)
  -- Check custom snippets first
  if custom_snippets[trigger] then
    return custom_snippets[trigger]
  end

  -- Fall back to built-in snippets
  if builtin_snippets[trigger] then
    return builtin_snippets[trigger]
  end

  return nil
end

-- List all available snippets
function M.list_snippets()
  local all_snippets = {}

  -- Add built-in snippets
  for trigger, snippet in pairs(builtin_snippets) do
    all_snippets[trigger] = snippet
  end

  -- Add custom snippets (override built-in)
  for trigger, snippet in pairs(custom_snippets) do
    all_snippets[trigger] = snippet
  end

  return all_snippets
end

-- Get snippet count
function M.get_snippet_count()
  return vim.tbl_count(builtin_snippets) + vim.tbl_count(custom_snippets)
end

-- Clear snippet caches
function M.clear_caches()
  builtin_snippets = {}
  custom_snippets = {}
end

-- Reload all snippets
function M.reload_all()
  M.clear_caches()
  M.load_builtin()
  M.load_custom()
end

return M
