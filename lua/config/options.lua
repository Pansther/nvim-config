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

vim.diagnostic.config({
  float = {
    source = "always", -- แสดงชื่อ source (เช่น 'eslint', 'tsserver') เสมอ
    border = "rounded", -- รูปแบบของขอบ: 'single', 'double', 'rounded'
    focusable = false, -- ไม่ให้โฟกัสที่ floating window
    header = "", -- ข้อความ Header
  },
})

vim.api.nvim_create_autocmd("CursorHold", {
  callback = function()
    -- เปิด floating window แสดง diagnostic ที่ตำแหน่งเคอร์เซอร์
    vim.diagnostic.open_float({
      -- ให้แสดงเฉพาะ diagnostic ของบรรทัดปัจจุบัน
      scope = "cursor",
    })
  end,
  -- ให้ทำงานกับ buffer ที่เปิดใช้งาน LSP
  group = vim.api.nvim_create_augroup("DiagnosticFloat", { clear = true }),
})
