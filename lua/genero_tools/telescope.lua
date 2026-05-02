-- Genero-Tools Telescope Pickers
-- Provides Telescope integration for function navigation, module browsing,
-- compiler diagnostics, and module file switching

local M = {}

-- Lazy-load Telescope modules (returns nil if not available)
local function telescope_available()
  local ok_pickers, pickers = pcall(require, "telescope.pickers")
  local ok_finders, finders = pcall(require, "telescope.finders")
  local ok_conf, conf = pcall(require, "telescope.config")
  local ok_make_entry, make_entry = pcall(require, "telescope.make_entry")
  if not (ok_pickers and ok_finders and ok_conf and ok_make_entry) then
    return nil
  end
  return {
    pickers = pickers,
    finders = finders,
    conf = conf,
    make_entry = make_entry,
  }
end

-- Resolve a file path from query.sh output to an absolute path
local function resolve_path(file)
  if not file or file == "" then
    return nil
  end
  if file:sub(1, 1) == "/" then
    return file
  end
  -- Strip leading ./
  local clean = file
  if clean:sub(1, 2) == "./" then
    clean = clean:sub(3)
  end
  -- Try relative to codebase root
  local ok_root, root = pcall(vim.fn["genero_tools#codebase#get_root"])
  if ok_root and root and root ~= "" then
    local candidate = root .. "/" .. clean
    if vim.fn.filereadable(candidate) == 1 then
      return candidate
    end
  end
  -- Try relative to CWD
  local candidate = vim.fn.getcwd() .. "/" .. clean
  if vim.fn.filereadable(candidate) == 1 then
    return candidate
  end
  return file
end

-- Read a single line from a file
local function read_line(filepath, lnum)
  if not filepath or lnum < 1 then
    return ""
  end
  local ok, lines = pcall(vim.fn.readfile, filepath, "", lnum)
  if ok and lines and #lines >= lnum then
    return lines[lnum]
  end
  return ""
end

-- Safe call to a VimScript autoload function
local function vim_call(func_name, ...)
  local ok, result = pcall(vim.fn[func_name], ...)
  if not ok then
    return nil
  end
  return result
end

-- Check if data from VimScript is a non-empty list
local function is_nonempty_list(data)
  if type(data) ~= "table" then
    return false
  end
  -- VimScript empty dict {} and empty list [] both become Lua tables
  -- but lists have integer keys starting at 1
  if data[1] ~= nil then
    return true
  end
  return false
end

-- Get list-file-functions for a file path (handles path normalization)
local function get_file_functions(file_path)
  local rel = vim_call("genero_tools#normalize_file_path", file_path)
  if not rel or rel == "" then
    return nil
  end
  local result = vim_call("genero_tools#command#execute_shell", "list-file-functions", { rel })
  if not result or result.success ~= 1 or not is_nonempty_list(result.data) then
    return nil
  end
  return result.data
end

-- Detect module for a file (single-module only, returns nil for multi-module)
local function detect_module(file_path)
  local funcs = get_file_functions(file_path)
  if not funcs then
    return nil
  end

  local first = funcs[1]
  local func_name = type(first) == "table" and first.name or nil
  if not func_name or func_name == "" then
    return nil
  end

  local result = vim_call("genero_tools#command#execute_shell", "find-module-for-function", { func_name })
  if not result or result.success ~= 1 or not result.data then
    return nil
  end

  local data = result.data
  if type(data) == "string" and data ~= "" then
    return data
  elseif type(data) == "table" then
    -- Only accept single-module results
    if data[1] and not data[2] then
      local item = data[1]
      if type(item) == "table" then
        return item.name or item.module or nil
      elseif type(item) == "string" then
        return item
      end
    end
  end
  return nil
end

-- ============================================================================
-- #1: Function picker for current file
-- ============================================================================

function M.file_functions()
  local t = telescope_available()
  if not t then
    vim.cmd("GeneroListFunctions")
    return
  end

  local file_path = vim.fn.expand("%:p")
  local funcs = get_file_functions(file_path)

  if not funcs then
    vim.notify("No functions found in current file", vim.log.levels.WARN)
    return
  end

  -- Build vimgrep-style lines: file:lnum:col:text
  local vimgrep_lines = {}
  for _, func in ipairs(funcs) do
    local lnum = func.line_start or 1
    local line_text = read_line(file_path, lnum)
    if line_text == "" then
      line_text = "FUNCTION " .. (func.name or "?")
    end
    table.insert(vimgrep_lines, file_path .. ":" .. lnum .. ":1:" .. line_text)
  end

  t.pickers.new({}, {
    prompt_title = "Functions in " .. vim.fn.expand("%:t"),
    finder = t.finders.new_table({
      results = vimgrep_lines,
      entry_maker = t.make_entry.gen_from_vimgrep({}),
    }),
    sorter = t.conf.values.generic_sorter({}),
    previewer = t.conf.values.grep_previewer({}),
  }):find()
end

-- ============================================================================
-- #2: Function picker for current module (single-module only)
-- ============================================================================

function M.module_functions()
  local t = telescope_available()
  if not t then
    vim.notify("Telescope required for module function picker", vim.log.levels.WARN)
    return
  end

  local file_path = vim.fn.expand("%:p")
  local module_name = detect_module(file_path)
  if not module_name then
    vim.notify("Cannot determine module (multi-module or unknown)", vim.log.levels.WARN)
    return
  end

  local result = vim_call("genero_tools#command#execute_shell", "find-functions-in-module", { module_name })
  if not result or result.success ~= 1 or not is_nonempty_list(result.data) then
    vim.notify("No functions found in module: " .. module_name, vim.log.levels.WARN)
    return
  end

  local vimgrep_lines = {}
  for _, func in ipairs(result.data) do
    local file = func.path or func.file_path or ""
    local full_path = resolve_path(file)
    if full_path then
      local lnum = func.line_start or 1
      local line_text = read_line(full_path, lnum)
      if line_text == "" then
        line_text = "FUNCTION " .. (func.name or "?")
      end
      table.insert(vimgrep_lines, full_path .. ":" .. lnum .. ":1:" .. line_text)
    end
  end

  if #vimgrep_lines == 0 then
    vim.notify("No functions with valid paths in module: " .. module_name, vim.log.levels.WARN)
    return
  end

  t.pickers.new({}, {
    prompt_title = "Functions in module " .. module_name,
    finder = t.finders.new_table({
      results = vimgrep_lines,
      entry_maker = t.make_entry.gen_from_vimgrep({}),
    }),
    sorter = t.conf.values.generic_sorter({}),
    previewer = t.conf.values.grep_previewer({}),
  }):find()
end

-- ============================================================================
-- #5: Compiler errors/warnings through Telescope
-- ============================================================================

function M.diagnostics(filter)
  local t = telescope_available()
  if not t then
    vim.cmd("copen")
    return
  end

  filter = filter or "all"

  -- Get quickfix list (populated by compiler)
  local qf_list = vim.fn.getqflist()
  if #qf_list == 0 then
    vim.notify("No compiler diagnostics. Run :GeneroCompile first.", vim.log.levels.INFO)
    return
  end

  -- Filter by type if requested
  local filtered = {}
  for _, item in ipairs(qf_list) do
    local item_type = (item.type or ""):upper()
    if filter == "all" then
      table.insert(filtered, item)
    elseif filter == "errors" and item_type == "E" then
      table.insert(filtered, item)
    elseif filter == "warnings" and item_type == "W" then
      table.insert(filtered, item)
    end
  end

  if #filtered == 0 then
    vim.notify("No " .. filter .. " found", vim.log.levels.INFO)
    return
  end

  -- Build vimgrep-style lines from quickfix entries
  local vimgrep_lines = {}
  for _, item in ipairs(filtered) do
    local filename = item.filename or ""
    if filename == "" and item.bufnr and item.bufnr > 0 then
      filename = vim.api.nvim_buf_get_name(item.bufnr)
    end
    if filename ~= "" then
      local lnum = item.lnum or 1
      local col = item.col or 1
      local prefix = item.type == "E" and "[ERROR] " or item.type == "W" and "[WARN] " or ""
      local text = prefix .. (item.text or "")
      table.insert(vimgrep_lines, filename .. ":" .. lnum .. ":" .. col .. ":" .. text)
    end
  end

  if #vimgrep_lines == 0 then
    vim.notify("No diagnostics with valid file paths", vim.log.levels.WARN)
    return
  end

  local title_map = { all = "All Diagnostics", errors = "Errors", warnings = "Warnings" }
  local title = (title_map[filter] or "Diagnostics") .. " (" .. #vimgrep_lines .. ")"

  t.pickers.new({}, {
    prompt_title = title,
    finder = t.finders.new_table({
      results = vimgrep_lines,
      entry_maker = t.make_entry.gen_from_vimgrep({}),
    }),
    sorter = t.conf.values.generic_sorter({}),
    previewer = t.conf.values.grep_previewer({}),
  }):find()
end

-- ============================================================================
-- #10: Quick-switch between module sibling files (single-module only)
-- ============================================================================

function M.module_files()
  local t = telescope_available()
  if not t then
    vim.notify("Telescope required for module file switching", vim.log.levels.WARN)
    return
  end

  local file_path = vim.fn.expand("%:p")
  local module_name = detect_module(file_path)
  if not module_name then
    vim.notify("Cannot determine module (multi-module or unknown)", vim.log.levels.WARN)
    return
  end

  local result = vim_call("genero_tools#command#execute_shell", "find-functions-in-module", { module_name })
  if not result or result.success ~= 1 or not is_nonempty_list(result.data) then
    vim.notify("No files found in module: " .. module_name, vim.log.levels.WARN)
    return
  end

  -- Collect unique file paths
  local seen = {}
  local files = {}
  local current_file = file_path

  for _, func in ipairs(result.data) do
    local file = func.path or func.file_path or ""
    local full_path = resolve_path(file)
    if full_path and not seen[full_path] then
      seen[full_path] = true
      table.insert(files, full_path)
    end
  end

  if #files <= 1 then
    vim.notify("Only one file in module " .. module_name, vim.log.levels.INFO)
    return
  end

  local ok_actions, actions = pcall(require, "telescope.actions")
  local ok_state, action_state = pcall(require, "telescope.actions.state")

  t.pickers.new({}, {
    prompt_title = "Files in module " .. module_name .. " (" .. #files .. ")",
    finder = t.finders.new_table({
      results = files,
      entry_maker = function(filepath)
        local short = vim.fn.fnamemodify(filepath, ":t")
        local is_current = filepath == current_file
        local display = is_current and ("● " .. short) or ("  " .. short)
        return {
          value = filepath,
          display = display,
          ordinal = short,
          filename = filepath,
          lnum = 1,
        }
      end,
    }),
    sorter = t.conf.values.generic_sorter({}),
    previewer = t.conf.values.file_previewer({}),
    attach_mappings = function(prompt_bufnr, map)
      if ok_actions and ok_state then
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          if selection then
            vim.cmd("edit " .. vim.fn.fnameescape(selection.value))
          end
        end)
      end
      return true
    end,
  }):find()
end

return M
