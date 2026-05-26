return {
  "ibhagwan/fzf-lua",
  keys = {
    {
      "<leader>fh",
      function()
        require("fzf-lua").files({
          cmd = "fd --type f --hidden --no-ignore --exclude node_modules --exclude .git",
          prompt = "Find Files (with Hidden) ✏️  ",
        })
      end,
      desc = "Find hidden files",
    },
  },
}
