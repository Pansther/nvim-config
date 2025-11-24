return {
  -- (1) ตั้งค่า LSP ของ rust_analyzer
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        rust_analyzer = {
          -- การตั้งค่านี้จะถูกผสานเข้ากับการตั้งค่า rust_analyzer เริ่มต้นของ LazyVim
          on_attach = function(client, bufnr)
            -- โค้ดที่คุณต้องการเพิ่ม: เปิดใช้งาน Inlay Hints
            vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })

            -- ตรวจสอบว่ามีฟังก์ชัน on_attach ดั้งเดิมของ LazyVim อยู่หรือไม่
            local lazyvim_on_attach = require("lazyvim.plugins.lsp.defaults").on_attach
            if lazyvim_on_attach then
              -- เรียกใช้ on_attach ดั้งเดิมเพื่อรักษา Keymaps และฟีเจอร์อื่น ๆ
              lazyvim_on_attach(client, bufnr)
            end
          end,
        },
      },
    },
  },

  -- (2) แนะนำให้ติดตั้ง Rust Tools เพิ่มเติม (ถ้ายังไม่มี)
  -- ช่วยเพิ่มฟีเจอร์เช่น การรัน/ดีบักโค้ด, การดู crates
  {
    "simrat39/rust-tools.nvim",
    ft = { "rust" },
    opts = function()
      -- ใช้ require("lazyvim.util").opts แทน merge_tables
      return require("lazyvim.util").opts("rust-tools")
    end,
  },
}
