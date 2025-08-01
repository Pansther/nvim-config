-- ~/.config/nvim/lua/plugins/lsp.lua

return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      cssmodules_ls = {},
      tsserver = {},
    },

    inlay_hints = { enabled = false },
  },
}
