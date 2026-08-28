local failures, total = {}, 0

local function eq(actual, expected, label)
  if not vim.deep_equal(actual, expected) then
    error((label or "values differ") .. "\nexpected: " .. vim.inspect(expected) .. "\nactual: " .. vim.inspect(actual))
  end
end

local function it(name, fn)
  total = total + 1
  local ok, err = pcall(fn)
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

terminal._reset()
if #failures > 0 then error(table.concat(failures, "\n")) end
print(("ok - %d tests"):format(total))
