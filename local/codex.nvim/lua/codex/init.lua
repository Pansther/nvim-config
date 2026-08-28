local terminal = require("codex.terminal")
local M = {}
local defaults = {
  command = "codex",
  width = 0.4,
  mappings = { toggle = "<leader>aa", mention = "<leader>ab" },
}
local config = vim.deepcopy(defaults)
local installed_maps = {}

local function notify(message)
  vim.notify(message, vim.log.levels.WARN, { title = "codex.nvim" })
end

local function validate(value)
  if type(value.width) ~= "number" or value.width <= 0 then
    error("codex.nvim: width must be positive")
  end
  if type(value.command) == "string" then
    if value.command == "" then error("codex.nvim: command must not be empty") end
    return
  end
  if type(value.command) ~= "table" or not vim.islist(value.command) or #value.command == 0 then
    error("codex.nvim: command must be a non-empty string or list")
  end
  for _, part in ipairs(value.command) do
    if type(part) ~= "string" or part == "" then
      error("codex.nvim: command must be a non-empty string or list")
    end
  end
end

local function clear_maps()
  for _, map in ipairs(installed_maps) do
    pcall(vim.keymap.del, map.mode, map.lhs)
  end
  installed_maps = {}
end

local function install_map(modes, lhs, callback, desc)
  if lhs == false then return end
  for _, mode in ipairs(modes) do
    vim.keymap.set(mode, lhs, callback, { desc = desc })
    installed_maps[#installed_maps + 1] = { mode = mode, lhs = lhs }
  end
end

function M.setup(opts)
  config = vim.tbl_deep_extend("force", vim.deepcopy(defaults), opts or {})
  validate(config)
  clear_maps()
  install_map({ "n", "t" }, config.mappings.toggle, M.toggle, "Toggle Codex")
  install_map({ "n" }, config.mappings.mention, M.mention_buffer, "Mention buffer in Codex")
  vim.api.nvim_create_user_command("CodexToggle", M.toggle, { force = true })
  vim.api.nvim_create_user_command("CodexMentionBuffer", M.mention_buffer, { force = true })
end

function M.toggle()
  return terminal.toggle(config)
end

function M.mention_buffer()
  local buffer = vim.api.nvim_get_current_buf()
  if vim.bo[buffer].buftype ~= "" then
    notify("Current buffer is not a file")
    return false
  end
  local name = vim.api.nvim_buf_get_name(buffer)
  if name == "" then
    notify("Current buffer has no file path")
    return false
  end
  if name:find("[\n\r]") then
    notify("File paths containing newlines are not supported")
    return false
  end
  local path = vim.fn.fnamemodify(name, ":p")
  return terminal.send(config, "/mention " .. path .. "\r")
end

return M
