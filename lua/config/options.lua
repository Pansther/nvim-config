-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Autocmd เพื่อเปิด NeoTree อัตโนมัติ
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.fn.argc() == 0 then -- Only load if no files are opened on startup
      vim.defer_fn(function()
        require("persistence").load()
        vim.cmd("Neotree filesystem reveal_force_cwd")
      end, 100)
    end
  end,
})
