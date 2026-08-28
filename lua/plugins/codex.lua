return {
  dir = vim.fn.stdpath("config") .. "/local/codex.nvim",
  name = "codex.nvim",
  opts = {
    command = "codex",
    width = 0.4,
    mappings = {
      toggle = "<leader>aa",
      mention = "<leader>ab",
    },
  },
}
