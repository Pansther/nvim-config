if vim.g.loaded_codex_nvim then return end
vim.g.loaded_codex_nvim = 1
require("codex").setup()
