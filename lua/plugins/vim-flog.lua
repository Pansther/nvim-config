return {
  "rbong/vim-flog",
  lazy = true,
  cmd = { "Flog", "Flogsplit", "Floggit" },
  keys = {
    { "<leader>gG", "<cmd>Flog -all<cr>", desc = "Git Graph" },
  },
  dependencies = {
    "tpope/vim-fugitive",
  },
}
