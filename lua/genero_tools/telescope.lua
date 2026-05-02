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
  if file:sub(1, 2) == "./" then
    file = file:sub(3)
  end
  local root = vim.fn["genero_tools#codebase#get_root"]()
  if root and root ~= "" then
    local candidate = root .. "/" .. file
    if vim.fn.filereadable(candidate) == 1 then
      return candidate
    end
  end
  local candidate = vim.fn.getcwd() .. "/" .. file
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
  local lines = vim.fn.readfile(filepath, "", lnum)
  if lines and #lines >= lnum then
    return lines[lnum]
  end
  return ""
end

-- Detect module for current file (calls VimScript module detection)
-- Returns module name or empty string
local function detect_module()
  local file_path = vim.fn.expand("%:p")
  if file_path == "" then
    return ""
  end

  -- Use the same detection as autocomplete (cached per file)
  local ok, result = pcall(vim.fn["genero_tools#command#execute_shell"], "list-file-functions",
    { vim.fn["genero_tools#normalize_file_path"](file_path) })
  if not ok or not result or not result.success or type(result.data) ~= "table" or #result.data == 0 then
    return ""
  end

  local first_func = result.data[1]
  local func_name = type(first_func) == "table" and first_func.name or ""
  if func_name == "" then
    return ""
  end

  local mod_result = vim.fn["genero_tools#command#execute_shell"]("find-module-for-function", { func_name })
  if not mod_result or not mod_result.success or not mod_result.data then
    return ""
  end

  local mod_data = mod_result.data
  if type(mod_data) == "string" then
    return mod_data
  elseif type(mod_data) == "table" then
    if #mod_data == 1 then
      local item = mod_data[1]
      return type(item) == "table" and (item.name or item.module or "") or tostring(item)
    end
  end
  return ""
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
  local file_rel = vim.fn["genero_tools#normalize_file_path"](file_path)

  local result = vim.fn["genero_tools#command#execute_shell"]("list-file-functions", { file_rel })
  if not result or not result.success or type(result.data) ~= "table" or #result.data == 0 then
    vim.notify("No functions found in current file", vim.log.levels.WARN)
    return
  end

  -- Build vimgrep-style lines: file:lnum:col:text
  local vimgrep_lines = {}
  for _, func in ipairs(result.data) do
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

  local module_name = detect_module()
  if module_name == "" then
    vim.notify("Cannot determine module for current file (multi-module or unknown)", vim.log.levels.WARN)
    return
  end

  local result = vim.fn["genero_tools#command#execute_shell"]("find-functions-in-module", { module_name })
  if not result or not result.success or type(result.data) ~= "table" or #result.data == 0 then
    vim.notify("No functions found in module: " .. module_name, vim.log.levels.WARN)
    return
  end

  local vimgrep_lines = {}
  for _, func in ipairs(result.data) do
    local file = func.path or func.file_path or func.file or ""
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
    -- If filename is empty, try to get it from bufnr
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

  local module_name = detect_module()
  if module_name == "" then
    vim.notify("Cannot determine module for current file (multi-module or unknown)", vim.log.levels.WARN)
    return
  end

  local result = vim.fn["genero_tools#command#execute_shell"]("find-functions-in-module", { module_name })
  if not result or not result.success or type(result.data) ~= "table" or #result.data == 0 then
    vim.notify("No files found in module: " .. module_name, vim.log.levels.WARN)
    return
  end

  -- Collect unique file paths
  local seen = {}
  local files = {}
  local current_file = vim.fn.expand("%:p")

  for _, func in ipairs(result.data) do
    local file = func.path or func.file_path or func.file or ""
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
