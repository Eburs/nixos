return {
  {
    "mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = {}
    end,
  },
  {
    "mason-lspconfig.nvim",
    enabled = false,
  },
}
