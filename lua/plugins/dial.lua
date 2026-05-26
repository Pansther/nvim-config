return {
  "monaqa/dial.nvim",
  keys = {
    { "g<C-a>", false, mode = { "n", "x" } },
    { "g<C-x>", false, mode = { "n", "x" } },
  },
  opts = function(_, opts)
    local augend = require("dial.augend")
    vim.list_extend(opts.groups.default, {
      augend.integer.alias.binary,
      augend.date.alias["%Y-%m-%d"],
      augend.date.alias["%H:%M"],
      augend.constant.new({ elements = { "===", "!==" }, word = false, cyclic = true }),
    })
    return opts
  end,
}
