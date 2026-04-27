return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    opts = {
      transparent_background = true,
      integrations = {
        cmp = true,
        native_lsp = {
          enabled = true,
          underlines = {
            errors = { "undercurl" },
            hints = { "undercurl" },
            warnings = { "undercurl" },
            information = { "undercurl" },
          },
        },
      },
      custom_highlights = function(colors)
        return {
          NormalFloat = { bg = "none" },
          FloatBorder = { bg = "none" },
          Pmenu = { bg = "none" },
          PmenuSel = { bg = colors.surface0, fg = "none" },
        }
      end,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin-nvim",
    },
  },
}
