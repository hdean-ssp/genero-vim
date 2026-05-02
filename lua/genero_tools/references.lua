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

-- Read a single line from a file (for vimgrep-style display)
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

-- Show references using Telescope picker
-- Formats entries as vimgrep-style strings so the built-in grep previewer
-- natively handles scrolling to the correct line
function M.show_telescope(func_name, data)
  local ok_pickers, pickers = pcall(require, "telescope.pickers")
  local ok_finders, finders = pcall(require, "telescope.finders")
  local ok_conf, conf = pcall(require, "telescope.config")
  local ok_actions, actions = pcall(require, "telescope.actions")
  local ok_state, action_state = pcall(require, "telescope.actions.state")
  local ok_make_entry, make_entry = pcall(require, "telescope.make_entry")

  if not (ok_pickers and ok_finders and ok_conf and ok_actions and ok_state and ok_make_entry) then
    return false
  end

  -- Build vimgrep-style strings: "filepath:lnum:col:text"
  -- This is the format that Telescope's vimgrep entry maker and grep previewer expect
  local vimgrep_lines = {}
  for _, ref in ipairs(data) do
    local parsed = parse_ref(ref)
    local full_path = resolve_path(parsed.file)

    if full_path then
      local lnum = parsed.line > 0 and parsed.line or 1
      -- Read the actual line content from the file for display
      local line_text = read_line(full_path, lnum)
      if line_text == "" then
        line_text = parsed.name
      end
      -- Format: filepath:lnum:col:text
      local vimgrep_str = full_path .. ":" .. lnum .. ":1:" .. line_text
      table.insert(vimgrep_lines, vimgrep_str)
    end
  end

  if #vimgrep_lines == 0 then
    vim.notify("No references with valid file paths", vim.log.levels.WARN)
    return true
  end

  local count = #vimgrep_lines
  local title = count == 1
    and "1 reference to " .. func_name
    or count .. " references to " .. func_name

  pickers.new({}, {
    prompt_title = title,
    finder = finders.new_table({
      results = vimgrep_lines,
      entry_maker = make_entry.gen_from_vimgrep({}),
    }),
    sorter = conf.values.generic_sorter({}),
    previewer = conf.values.grep_previewer({}),
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
