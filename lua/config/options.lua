-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Autocmd เพื่อเปิด NeoTree อัตโนมัติ
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    -- ตรวจสอบว่าเปิดไฟล์โดยตรงหรือไม่ (ถ้าเปิด 'nvim' เฉยๆ โดยไม่มีชื่อไฟล์ตามหลัง)
    -- และไม่ใช่ buffer ที่ไม่มีชื่อ (หมายถึงหน้าจอเริ่มต้นของ NeoVim)
    if vim.fn.argc() == 0 and vim.api.nvim_buf_get_name(0) == "" then
      vim.cmd("Neotree filesystem reveal_force_cwd") -- คำสั่งสำหรับ NeoTree
    end
  end,
})
