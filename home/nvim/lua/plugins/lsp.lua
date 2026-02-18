return {
  {
    "neovim/nvim-lspconfig",
    ---@class PluginLspOpts
    opts = {
      ---@type lspconfig.options
      servers = {
        ruff = { mason = false },
        pyright = { mason = false },
      },
    },
  },
}
