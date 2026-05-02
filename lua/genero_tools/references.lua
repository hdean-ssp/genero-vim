-- Genero-Tools References - Telescope Integration
-- Shows function references in a Telescope picker with file preview
-- Falls back to VimScript floating window if Telescope is not available

local M = {}

-- Resolve a file path from query.sh output to an absolute path
local function resolve_path(file)
  if not file or file == "" then
    return nil
  end

  -- Already absolute
  if file:sub(1, 1) == "/" then
    return file
  end

  -- Strip leading ./
  if file:sub(1, 2) == "./" then
    file = file:sub(3)
  end

  -- Try relative to codebase root
  local root = vim.fn["genero_tools#codebase#get_root"]()
  if root and root ~= "" then
    local candidate = root .. "/" .. file
    if vim.fn.filereadable(candidate) == 1 then
      return candidate
    end
  end

  -- Try relative to CWD
  local candidate = vim.fn.getcwd() .. "/" .. file
  if vim.fn.filereadable(candidate) == 1 then
    return candidate
  end

  return file
end

-- Extract fields from a reference entry (handles varying JSON shapes from query.sh)
local function parse_ref(ref)
  local name = ref.name or ref["function"] or ref.caller or "?"
  local file = ref.file or ref.file_path or ref.path or ""
  local line = ref.line or ref.line_start or 0
  local module = ref.module or ""

  -- Handle line as table {start, end}
  if type(line) == "table" then
    line = line.start or 0
  end

  return {
    name = name,
    file = file,
    line = tonumber(line) or 0,
    module = module,
  }
end

-- Show references using Telescope picker
function M.show_telescope(func_name, data)
  local ok_pickers, pickers = pcall(require, "telescope.pickers")
  local ok_finders, finders = pcall(require, "telescope.finders")
  local ok_conf, conf = pcall(require, "telescope.config")
  local ok_actions, actions = pcall(require, "telescope.actions")
  local ok_state, action_state = pcall(require, "telescope.actions.state")
  local ok_previewers, previewers = pcall(require, "telescope.previewers")

  if not (ok_pickers and ok_finders and ok_conf and ok_actions and ok_state and ok_previewers) then
    return false
  end

  -- Build entries with resolved paths
  local entries = {}
  for _, ref in ipairs(data) do
    local parsed = parse_ref(ref)
    local full_path = resolve_path(parsed.file)

    if full_path then
      local display = parsed.name
      local short_file = vim.fn.fnamemodify(full_path, ":t")
      if short_file ~= "" then
        display = display .. "  " .. short_file
        if parsed.line > 0 then
          display = display .. ":" .. parsed.line
        end
      end
      if parsed.module ~= "" then
        display = display .. "  [" .. parsed.module .. "]"
      end

      table.insert(entries, {
        display = display,
        ordinal = parsed.name .. " " .. short_file,
        filename = full_path,
        lnum = parsed.line > 0 and parsed.line or 1,
        col = 1,
        name = parsed.name,
      })
    end
  end

  if #entries == 0 then
    vim.notify("No references with valid file paths", vim.log.levels.WARN)
    return true
  end

  local count = #entries
  local title = count == 1
    and "1 reference to " .. func_name
    or count .. " references to " .. func_name

  -- Custom previewer that positions the view at the function definition line
  -- Shows ~10 lines of context above the FUNCTION line (often comments/docs)
  local ref_previewer = previewers.new_buffer_previewer({
    title = "Reference",
    define_preview = function(self, entry, status)
      local filepath = entry.filename
      if not filepath or vim.fn.filereadable(filepath) ~= 1 then
        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, { "  File not found: " .. (filepath or "?") })
        return
      end

      -- Read file content
      local lines = vim.fn.readfile(filepath)
      if not lines or #lines == 0 then
        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, { "  Empty file" })
        return
      end

      vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)

      -- Set filetype for syntax highlighting
      local ext = vim.fn.fnamemodify(filepath, ":e")
      local ft_map = { ["4gl"] = "fgl", per = "fgl", m3 = "make", m4 = "make" }
      local ft = ft_map[ext] or ext
      pcall(vim.api.nvim_buf_set_option, self.state.bufnr, "filetype", ft)

      -- Position view: show 10 lines before the function line for context
      local target_line = entry.lnum or 1
      local context_above = 10
      local scroll_to = math.max(1, target_line - context_above)

      -- Schedule the scroll so the preview window is ready
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(self.state.bufnr) and self.state.winid and vim.api.nvim_win_is_valid(self.state.winid) then
          -- Set cursor to the function line
          local line_count = vim.api.nvim_buf_line_count(self.state.bufnr)
          local cursor_line = math.min(target_line, line_count)
          pcall(vim.api.nvim_win_set_cursor, self.state.winid, { cursor_line, 0 })
          -- Scroll so context_above lines are visible above
          vim.api.nvim_win_call(self.state.winid, function()
            vim.cmd("normal! zt")
            if scroll_to < target_line then
              vim.cmd("normal! " .. context_above .. "k" .. context_above .. "j")
            end
          end)
        end
      end)
    end,
  })

  pickers.new({}, {
    prompt_title = title,
    finder = finders.new_table({
      results = entries,
      entry_maker = function(entry)
        return {
          value = entry,
          display = entry.display,
          ordinal = entry.ordinal,
          filename = entry.filename,
          lnum = entry.lnum,
          col = entry.col,
        }
      end,
    }),
    sorter = conf.values.generic_sorter({}),
    previewer = ref_previewer,
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection then
          -- Push to jumplist
          vim.cmd("normal! m'")
          vim.cmd("edit " .. vim.fn.fnameescape(selection.filename))
          if selection.lnum > 0 then
            vim.api.nvim_win_set_cursor(0, { selection.lnum, 0 })
            vim.cmd("normal! zz")
          end
        end
      end)
      return true
    end,
  }):find()

  return true
end

-- Entry point called from VimScript
-- Tries Telescope first, returns 1 if handled, 0 to fall back to floating window
function M.find(func_name, data_json)
  if not func_name or func_name == "" then
    return 0
  end

  -- Parse JSON data from VimScript
  local ok, data = pcall(vim.fn.json_decode, data_json)
  if not ok or type(data) ~= "table" or #data == 0 then
    return 0
  end

  -- Try Telescope
  local telescope_ok = pcall(function()
    return M.show_telescope(func_name, data)
  end)

  if telescope_ok then
    return 1
  end

  return 0
end

return M
