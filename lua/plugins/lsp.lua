-- ~/.config/nvim/lua/plugins/lsp.lua

return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      cssmodules_ls = {},
      tsserver = {},
      gdscript = {},
    },

    inlay_hints = { enabled = false },
  },
}
