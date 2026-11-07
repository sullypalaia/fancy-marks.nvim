local M = {}

---get global marks (uppercase)
---@return vim.fn.getmarklist.ret.item[] marks
function M.get_global_marks()
  return vim.tbl_filter(function(mark)
    return mark.mark:match("^'[A-Z]$") ~= nil
  end, vim.fn.getmarklist())
end

---get marks local to specified buffer (lowercase)
---@param bufnr? integer Buffer number; defaults to the current buffer.
---@return vim.fn.getmarklist.ret.item[] marks
function M.get_local_marks(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  return vim.tbl_filter(function(mark)
    return mark.mark:match("^'[a-z]$") ~= nil
  end, vim.fn.getmarklist(bufnr))
end

---open a new popup with the global and local marks
function M.open()
  local Popup = require("nui.popup")
  local Layout = require("nui.layout")

  ---columns are created for both local and global marks separately
  ---@param title string
  ---@return NuiPopup
  local function create_column(title)
    return Popup({
      enter = false,
      focusable = true,
      border = {
        style = "rounded",
        text = {
          top = " " .. title .. " ",
          top_align = "center",
        },
      },
    })
  end

  local left = create_column("Global marks")
  local right = create_column("Local marks")

  local layout = Layout({
    relative = "editor",
    position = "50%",
    size = {
      width = "80%",
      height = "60%",
    },
  }, Layout.Box({
    Layout.Box(left, { size = "50%" }),
    Layout.Box(right, { size = "50%" }),
  }, { dir = "row" }))

  layout:mount()
  vim.api.nvim_set_current_win(left.winid)
end

---@param opts table: options for the fancy marks window
function M.setup(opts)
  local popup = require("nui.popup")

  local default_opts = {
    use_default_mappings = true
  }

  if default_opts then
    vim.keymap.set("n", "<Leader>mo", function() M.open() end, { desc = "open fancy marks window" })
  end
end

return M
