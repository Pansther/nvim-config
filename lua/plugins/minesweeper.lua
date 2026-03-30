return {
  "Pansther/minesweeper.nvim",
  cmd = "Minesweeper",
  keys = {
    { "<leader>ms", "<cmd>Minesweeper<cr>", desc = "Play Minesweeper" },
  },
  config = function()
    require("minesweeper").setup()
  end,
}
