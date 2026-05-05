-- Genero-Tools nvim-cmp source
-- Wraps the existing VimScript autocomplete logic for unified completion UX

local source = {}

-- Create a new instance of the source
function source:new()
  return setmetatable({}, { __index = source })
end

-- Get the source name (used by cmp for identification)
function source:get_debug_name()
  return "genero"
end

-- Check if this source is available for the current buffer
function source:is_available()
  -- Only available in insert mode, not in command-line or other modes
  local mode = vim.api.nvim_get_mode().mode
  if mode ~= "i" and mode ~= "ic" then
    return false
  end
  
  local ft = vim.bo.filetype
  return ft == "4gl" or ft == "fgl" or ft == "per"
end

-- Get trigger characters (optional, cmp uses default word boundaries if not specified)
function source:get_trigger_characters()
  return { ".", "_" }
end

-- Main completion function
-- Called by cmp when completion is triggered
function source:complete(params, callback)
  -- Get the text before the cursor
  local line = params.context.cursor_before_line
  local col = params.context.cursor.col
  
  -- Find the start of the word being completed
  local word_start = col
  while word_start > 1 and line:sub(word_start - 1, word_start - 1):match("[a-zA-Z0-9_.]") do
    word_start = word_start - 1
  end
  
  -- Extract the base string (what the user has typed so far)
  local base = line:sub(word_start, col)
  
  -- Minimum 2 characters to trigger completion (avoid noise)
  if #base < 2 then
    callback({ items = {}, isIncomplete = false })
    return
  end
  
  -- Call the existing VimScript completion function
  local ok, completions = pcall(vim.fn["genero_tools#complete#get_completions"], base)
  
  if not ok or not completions or type(completions) ~= "table" then
    callback({ items = {}, isIncomplete = false })
    return
  end
  
  -- Convert VimScript completion items to cmp format
  local items = {}
  for _, item in ipairs(completions) do
    if type(item) == "table" then
      -- Map VimScript completion dict to cmp CompletionItem
      local cmp_item = {
        label = item.word or item.abbr or "",
        kind = self:_map_kind(item.kind),
        detail = item.menu or "",
        documentation = {
          kind = "markdown",
          value = item.info or "",
        },
        insertText = item.word or item.abbr or "",
        filterText = item.word or item.abbr or "",
        sortText = item.word or item.abbr or "",
        -- Store original item for resolve() if needed
        data = {
          original = item,
        },
      }
      table.insert(items, cmp_item)
    end
  end
  
  callback({
    items = items,
    isIncomplete = false,  -- We return all matches, no pagination
  })
end

-- Resolve additional details for a completion item (optional)
-- Called when an item is selected in the menu
function source:resolve(completion_item, callback)
  -- The VimScript completion already provides full info in the initial response,
  -- so we don't need to fetch anything additional here
  callback(completion_item)
end

-- Map VimScript completion kind to LSP CompletionItemKind
function source:_map_kind(vim_kind)
  local cmp = require("cmp")
  
  if not vim_kind or vim_kind == "" then
    return cmp.lsp.CompletionItemKind.Text
  end
  
  -- VimScript uses single-letter kinds: 'f' = function, 's' = snippet, etc.
  local kind_map = {
    f = cmp.lsp.CompletionItemKind.Function,
    s = cmp.lsp.CompletionItemKind.Snippet,
    v = cmp.lsp.CompletionItemKind.Variable,
    m = cmp.lsp.CompletionItemKind.Module,
    t = cmp.lsp.CompletionItemKind.Text,
  }
  
  return kind_map[vim_kind] or cmp.lsp.CompletionItemKind.Text
end

-- Register the source with nvim-cmp
local function register()
  local ok, cmp = pcall(require, "cmp")
  if not ok then
    return
  end
  
  cmp.register_source("genero", source:new())
end

-- Auto-register on module load
register()

return source
