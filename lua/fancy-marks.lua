local M = {}


---open a new popup with the global and local marks
function M.open()
  local global_marks = vim.tbl_filter(function(mark)
    return mark.mark:match("^'[A-Z]$") ~= nil
  end, vim.fn.getmarklist())

  local buf = vim.api.nvim_get_current_buf()

  local local_marks = vim.tbl_filter(function(mark)
    return mark.mark:match("^'[a-z]$") ~= nil
  end, vim.fn.getmarklist(buf))

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

  local function buf_draw_marks(bufnr, marks)
    for _, mark in ipairs(marks) do
      vim.api.nvim_buf_set_lines(bufnr, _ - 1, _, false, { mark.mark })
    end
  end

  --draw local marks
  buf_draw_marks(left.bufnr, global_marks)

  --draw global marks
  buf_draw_marks(right.bufnr, local_marks)

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
