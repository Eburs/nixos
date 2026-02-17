-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.api.nvim_set_keymap("n", "gy", '"+y"', { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "gp", '"+p"', { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "gy", '"+y"', { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "gp", '"+p"', { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<F6>", ":setlocal spell! spelllang=de_de<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<F7>", ":setlocal spell! spelllang=en_us<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-3>", "<cmd>ToggleTerm<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "<C-3>", "<cmd>ToggleTerm<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("t", "<C-3>", "<cmd>ToggleTerm<CR>", { noremap = true, silent = true })

-- Define a function to (compile and) run C++, Rust, Python or Julia
-- Or any arbitrary jupyter notebook through jupynium
-- Or compile a markdown file through pandoc
function CompileAndRun()
  local filetype = vim.bo.filetype
  local filename = vim.fn.expand("%:p")
  local basename = vim.fn.expand("%:p:r")
  local cmd = ""

  if filename:match("%.ju%.*") then
    vim.cmd("JupyniumExecuteSelectedCells")
    return
  else
    if filetype == "cpp" then
      if vim.fn.glob("CMakeLists.txt") ~= "" then
        cmd = "cmake . && make && ./$(basename " .. basename .. ")"
      else
        cmd = "g++ " .. filename .. " -o " .. basename .. " -O3 && " .. basename
      end
    elseif filetype == "rust" then
      if vim.fn.glob("Cargo.toml") ~= "" then
        cmd = "cargo build --release && cargo run"
      else
        cmd = "rustc " .. filename .. " && " .. basename
      end
    elseif filetype == "python" then
      cmd = "python3 " .. filename
    elseif filetype == "julia" then
      cmd = "julia " .. filename
    elseif filetype == "markdown" then
      vim.cmd("write")
      cmd = "pandoc " .. filename .. " -o " .. basename .. ".pdf"
    else
      print("Filetype not supported!")
      return
    end
  end

  -- Run the command using jobstart
  vim.fn.jobstart(cmd, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      for _, line in ipairs(data) do
        print(line)
      end
    end,
    on_stderr = function(_, data)
      for _, line in ipairs(data) do
        print(line)
      end
    end,
  })
end

-- Set keybind to <leader>r
vim.api.nvim_set_keymap("n", "<leader>r", ":lua CompileAndRun()<CR>", { noremap = true, silent = false })
