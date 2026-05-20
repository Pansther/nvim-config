-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("i", "jk", "<Esc>", { desc = "Exit Insert Mode" })
vim.keymap.set("i", "kj", "<Esc>", { desc = "Exit Insert Mode" })
vim.keymap.set("i", "<C-z>", "<C-o>u", { desc = "Undo in insert mode" })
vim.keymap.set("i", "<C-y>", "<C-o><C-r>", { desc = "Redo in insert mode" })
vim.keymap.set("i", "<C-h>", "<C-o>b", { desc = "Move cursor left by word" })
vim.keymap.set("i", "<C-l>", "<C-o>w", { desc = "Move cursor right by word" })

vim.keymap.set("v", "<C-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "<C-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

vim.keymap.set("v", "<leader>y", '"+y', { desc = "Yank to system clipboard" })
vim.keymap.set("n", "<leader>p", '"+p', { desc = "Paste from system clipboard" })
vim.keymap.set("i", "<C-v>", "<C-r>0", { desc = "Paste latest yank" })

vim.keymap.set("n", "K", function()
  if vim.lsp.get_clients() then
    vim.lsp.buf.hover()
  else
    vim.diagnostic.open_float({})
  end
end, { desc = "LSP/Diagnostic Hover/Float" })

vim.keymap.set("n", "<leader>cu", function()
  vim.lsp.buf.code_action({
    apply = true,
    context = { only = { "source.removeUnused.ts" }, diagnostics = {} },
  })
end, { desc = "Remove Unused Imports" })

vim.keymap.set("n", "<leader>r", ":source $MYVIMRC<CR>:lua print('Config Reloaded!')<CR>", { desc = "Reload Config" })

vim.keymap.set("n", "<leader>cv", function()
  vim.fn.system("code .")
  vim.notify("Opening VS Code in the current directory...", vim.log.levels.INFO, { title = "VS Code" })
end, { desc = "Open VS Code" })
