return {
  {
    "lervag/vimtex",
    lazy = false,
    init = function()
      vim.g.vimtex_view_method = "zathura"
      vim.g.latex_view_general_viewer = "zathura"
      vim.g.vimtex_compiler_method = "latexmk"
    end,
  },
  {
    "tpope/vim-fugitive",
    lazy = false,
  },
  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
    },
    keys = {
      { "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
      { "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
      { "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
      { "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
      { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
    },
  },
  {
    "vidocqh/data-viewer.nvim",
    opts = {},
    dependencies = {
      "nvim-lua/plenary.nvim",
      "kkharji/sqlite.lua", -- Optional, sqlite support
    },
  },
  {
    "neovim/nvim-lspconfig",
    ---@class PluginLspOpts
    opts = {
      ---@type lspconfig.options
      servers = {
        ltex = {
          settings = {
            ltex = {
              language = "en-US",
              enabled = { "latex", "tex", "bibtex", "markdown" },
              additionalLanguages = { "de-DE" },
              diagnosticSeverity = "information",
              sentenceCacheSize = 2000,
              additionalRules = {
                motherTongue = "de-DE",
              },
              trace = { server = "verbose" },
              dictionary = {},
              disabledRules = {},
              hiddenFalsePositives = {},
            },
          },
          filetypes = { "tex", "bib", "markdown", "md" }, -- Enable for .tex, .bib, .md files
        },
      },
    },
  },
  {
    "OXY2DEV/markview.nvim",
    lazy = true, -- Recommended false
    ft = "markdown", -- If you decide to lazy-load anyway

    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
  },
}
