local M = {}

local state = { buf = nil, win = nil, job = nil, cwd = nil }
local defaults = {
  executable = function(command) return vim.fn.executable(command) == 1 end,
  cwd = function() return vim.fn.getcwd() end,
  start_job = function(argv, opts) return vim.fn.jobstart(argv, opts) end,
  job_running = function(job) return vim.fn.jobwait({ job }, 0)[1] == -1 end,
  send = function(job, text) vim.fn.chansend(job, text) end,
  schedule = vim.schedule,
  notify = function(message, level) vim.notify(message, level, { title = "codex.nvim" }) end,
}
local runtime = defaults

local function command_argv(command, cwd)
  local argv = type(command) == "table" and vim.deepcopy(command) or { command }
  vim.list_extend(argv, { "-C", cwd })
  return argv
end

local function split_width(value)
  local requested = value <= 1 and math.floor(vim.o.columns * value) or math.floor(value)
  return math.max(20, math.min(requested, math.max(20, vim.o.columns - 10)))
end

local function valid_buf()
  return state.buf ~= nil and vim.api.nvim_buf_is_valid(state.buf)
end

local function valid_win()
  return state.win ~= nil and vim.api.nvim_win_is_valid(state.win)
end

local function clear_state()
  state.buf = nil
  state.win = nil
  state.job = nil
  state.cwd = nil
end

local function close_window()
  if valid_win() then pcall(vim.api.nvim_win_close, state.win, true) end
  state.win = nil
end

local function discard_terminal()
  close_window()
  if valid_buf() then pcall(vim.api.nvim_buf_delete, state.buf, { force = true }) end
  clear_state()
end

local function normalize_state()
  if state.buf ~= nil and not valid_buf() then
    discard_terminal()
    return
  end
  if state.win ~= nil and not valid_win() then state.win = nil end
end

local function open_window(width)
  vim.cmd("botright vsplit")
  state.win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(state.win, state.buf)
  vim.api.nvim_win_set_width(state.win, split_width(width))
  vim.api.nvim_set_current_win(state.win)
  vim.cmd("startinsert")
end

local function start_terminal(config)
  local cwd = runtime.cwd()
  local argv = command_argv(config.command, cwd)
  if not runtime.executable(argv[1]) then
    runtime.notify("codex executable not found: " .. argv[1], vim.log.levels.ERROR)
    return false
  end

  state.buf = vim.api.nvim_create_buf(false, true)
  vim.bo[state.buf].bufhidden = "hide"
  vim.bo[state.buf].swapfile = false
  state.cwd = cwd
  open_window(config.width)

  local job = runtime.start_job(argv, {
    term = true,
    cwd = cwd,
    on_exit = function() end,
  })
  if job <= 0 then
    discard_terminal()
    return false
  end
  state.job = job
  return true
end

function M.ensure(config)
  normalize_state()
  if valid_buf() and state.job and runtime.job_running(state.job) then
    if not valid_win() then open_window(config.width) end
    return true
  end
  if valid_buf() then discard_terminal() end
  return start_terminal(config)
end

function M.toggle(config)
  normalize_state()
  if valid_buf() and state.job and runtime.job_running(state.job) and valid_win() then
    close_window()
    return true
  end
  return M.ensure(config)
end

function M.send(config, text)
  if not M.ensure(config) then return false end
  runtime.schedule(function()
    if state.job and runtime.job_running(state.job) then runtime.send(state.job, text) end
  end)
  if valid_win() then vim.api.nvim_set_current_win(state.win) end
  return true
end

function M._set_runtime(fake)
  runtime = fake
end

function M._reset()
  discard_terminal()
  runtime = defaults
end

function M._state()
  return state
end

return M
