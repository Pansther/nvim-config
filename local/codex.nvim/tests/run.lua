local failures, total = {}, 0
local temporary_buffers = {}

local function new_buffer(listed, scratch)
  local buf = vim.api.nvim_create_buf(listed, scratch)
  vim.bo[buf].swapfile = false
  temporary_buffers[#temporary_buffers + 1] = buf
  return buf
end

local function cleanup()
  for _, lhs in ipairs({ "<leader>aa", "<leader>ab", "<leader>ca", "<leader>cb", "<leader>cc" }) do
    for _, mode in ipairs({ "n", "t" }) do
      pcall(vim.keymap.del, mode, lhs)
    end
  end
  pcall(vim.api.nvim_del_user_command, "CodexToggle")
  pcall(vim.api.nvim_del_user_command, "CodexMentionBuffer")
  for _, buf in ipairs(temporary_buffers) do
    if vim.api.nvim_buf_is_valid(buf) then pcall(vim.api.nvim_buf_delete, buf, { force = true }) end
  end
  temporary_buffers = {}
  package.loaded.codex = nil
end

local function eq(actual, expected, label)
  if not vim.deep_equal(actual, expected) then
    error((label or "values differ") .. "\nexpected: " .. vim.inspect(expected) .. "\nactual: " .. vim.inspect(actual))
  end
end

local function it(name, fn)
  total = total + 1
  local ok, err = pcall(fn)
  cleanup()
  if not ok then failures[#failures + 1] = name .. ": " .. err end
end

local function fake_runtime(overrides)
  local fake
  fake = {
    calls = { starts = {}, sends = {}, notifications = {} },
    executable = function() return true end,
    cwd = function() return "/tmp/codex project" end,
    start_job = function(argv, opts)
      fake.calls.starts[#fake.calls.starts + 1] = { argv = argv, opts = opts }
      return 41
    end,
    job_running = function(job) return job == 41 end,
    send = function(job, text) fake.calls.sends[#fake.calls.sends + 1] = { job = job, text = text } end,
    schedule = function(fn) fn() end,
    notify = function(message, level)
      fake.calls.notifications[#fake.calls.notifications + 1] = { message = message, level = level }
    end,
  }
  return vim.tbl_extend("force", fake, overrides or {})
end

local terminal = require("codex.terminal")

it("starts Codex with argv and captured cwd", function()
  local fake = fake_runtime()
  terminal._reset()
  terminal._set_runtime(fake)
  eq(terminal.toggle({ command = "codex", width = 0.4 }), true)
  eq(fake.calls.starts[1].argv, { "codex", "-C", "/tmp/codex project" })
  eq(fake.calls.starts[1].opts.term, true)
  eq(vim.api.nvim_win_get_width(terminal._state().win), 40)
end)

it("hides and restores one live job", function()
  local fake = fake_runtime()
  terminal._reset()
  terminal._set_runtime(fake)
  terminal.toggle({ command = "codex", width = 0.4 })
  local buffer = terminal._state().buf
  terminal.toggle({ command = "codex", width = 0.4 })
  eq(terminal._state().win, nil)
  terminal.toggle({ command = "codex", width = 0.4 })
  eq(terminal._state().buf, buffer)
  eq(#fake.calls.starts, 1)
end)

it("recreates an exited process", function()
  local running, next_job = true, 40
  local fake = fake_runtime({
    start_job = function() next_job = next_job + 1; return next_job end,
    job_running = function() return running end,
  })
  terminal._reset()
  terminal._set_runtime(fake)
  terminal.toggle({ command = "codex", width = 0.4 })
  terminal.toggle({ command = "codex", width = 0.4 })
  running = false
  terminal.toggle({ command = "codex", width = 0.4 })
  eq(terminal._state().job, 42)
end)

it("recreates a terminal buffer deleted externally", function()
  local next_job = 40
  local fake = fake_runtime({
    start_job = function() next_job = next_job + 1; return next_job end,
    job_running = function() return true end,
  })
  terminal._reset()
  terminal._set_runtime(fake)
  terminal.toggle({ command = "codex", width = 0.4 })
  vim.api.nvim_buf_delete(terminal._state().buf, { force = true })
  terminal.toggle({ command = "codex", width = 0.4 })
  eq(terminal._state().job, 42)
  eq(vim.api.nvim_buf_is_valid(terminal._state().buf), true)
end)

it("does not open a split when Codex is missing", function()
  local fake = fake_runtime({ executable = function() return false end })
  terminal._reset()
  terminal._set_runtime(fake)
  local windows = #vim.api.nvim_list_wins()
  eq(terminal.toggle({ command = "codex", width = 0.4 }), false)
  eq(#vim.api.nvim_list_wins(), windows)
  eq(fake.calls.notifications[1].level, vim.log.levels.ERROR)
end)

it("sends after scheduling even when the job exits", function()
  local running, scheduled = true, nil
  local fake = fake_runtime({
    job_running = function() return running end,
    schedule = function(fn) scheduled = fn end,
  })
  terminal._reset()
  terminal._set_runtime(fake)
  eq(terminal.send({ command = "codex", width = 0.4 }, "hello\n"), true)
  running = false
  scheduled()
  eq(#fake.calls.sends, 1)
  eq(fake.calls.sends[1], { job = 41, text = "hello\n" })
end)

local function with_notifications(fn)
  local previous, notices = vim.notify, {}
  vim.notify = function(message, level, opts)
    notices[#notices + 1] = { message = message, level = level, opts = opts }
  end
  local ok, err = pcall(fn, notices)
  vim.notify = previous
  if not ok then error(err) end
end

it("installs commands and approved mappings", function()
  package.loaded.codex = nil
  require("codex").setup()
  eq(vim.fn.exists(":CodexToggle"), 2)
  eq(vim.fn.exists(":CodexMentionBuffer"), 2)
  eq(vim.fn.maparg("<leader>aa", "n", false, true).desc, "Toggle Codex")
  eq(vim.fn.maparg("<leader>aa", "t", false, true).desc, "Toggle Codex")
  eq(vim.fn.maparg("<leader>ab", "n", false, true).desc, "Mention buffer in Codex")
end)

it("mentions the absolute current file path", function()
  local fake = fake_runtime()
  terminal._reset()
  terminal._set_runtime(fake)
  local buf = new_buffer(true, false)
  vim.api.nvim_buf_set_name(buf, "/tmp/codex project/source file.lua")
  vim.api.nvim_set_current_buf(buf)
  require("codex").setup({ mappings = { toggle = false, mention = false } })
  eq(require("codex").mention_buffer(), true)
  eq(fake.calls.sends[1], { job = 41, text = "/mention /tmp/codex project/source file.lua\r" })
end)

it("rejects unnamed special and newline buffers", function()
  local fake = fake_runtime()
  terminal._reset()
  terminal._set_runtime(fake)
  require("codex").setup({ mappings = { toggle = false, mention = false } })

  with_notifications(function(notices)
    local unnamed = new_buffer(true, false)
    vim.api.nvim_set_current_buf(unnamed)
    eq(require("codex").mention_buffer(), false)

    local special = new_buffer(false, true)
    vim.bo[special].buftype = "nofile"
    vim.api.nvim_buf_set_name(special, "scratch")
    vim.api.nvim_set_current_buf(special)
    eq(require("codex").mention_buffer(), false)

    local newline = new_buffer(true, false)
    vim.api.nvim_buf_set_name(newline, "/tmp/unsafe\nfile.lua")
    vim.api.nvim_set_current_buf(newline)
    eq(require("codex").mention_buffer(), false)
    eq(#fake.calls.sends, 0)
    eq(notices, {
      { message = "Current buffer has no file path", level = vim.log.levels.WARN, opts = { title = "codex.nvim" } },
      { message = "Current buffer is not a file", level = vim.log.levels.WARN, opts = { title = "codex.nvim" } },
      { message = "File paths containing newlines are not supported", level = vim.log.levels.WARN, opts = { title = "codex.nvim" } },
    })
  end)
end)

it("replaces plugin-owned mappings on repeated setup", function()
  local codex = require("codex")
  codex.setup({ mappings = { toggle = "<leader>ca", mention = "<leader>cb" } })
  codex.setup({ mappings = { toggle = false, mention = "<leader>cc" } })
  eq(vim.fn.maparg("<leader>ca", "n"), "")
  eq(vim.fn.maparg("<leader>cb", "n"), "")
  eq(vim.fn.maparg("<leader>cc", "n", false, true).desc, "Mention buffer in Codex")
end)

terminal._reset()
if #failures > 0 then error(table.concat(failures, "\n")) end
print(("ok - %d tests"):format(total))
