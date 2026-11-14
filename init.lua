vim.g.mapleader = " "

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.clipboard = "unnamedplus"
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = "yes"

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  local out = vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath,
  })
  if vim.v.shell_error ~= 0 then
    error("Не удалось клонировать lazy.nvim:\n" .. out)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup()
      -- clangd ставится системным пакетом (apt install clangd clang-format)
      vim.lsp.enable({ "bashls", "yamlls", "clangd" })
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = {
        "bash-language-server",
        "shfmt",
        "shellcheck",
        "ruff",
        "yaml-language-server",
        "prettier",
        "yamllint",
      },
      run_on_start = true,
      auto_update = false,
    },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        sh = { "shfmt" },
        python = { "ruff_format" },
        yaml = { "prettier" },
        cpp = { "clang-format" },
        c = { "clang-format" },
      },
      formatters = {
        shfmt = { prepend_args = { "-i", "2", "-ci", "-bn" } },
        prettier = { prepend_args = { "--tab-width", "2" } },
      },
      format_on_save = { timeout_ms = 500, lsp_format = "fallback" },
    },
  },
  {
    "mfussenegger/nvim-lint",
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = {
        sh = { "shellcheck" },
        yaml = { "yamllint" },
      }
      vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter" }, {
        callback = function()
          -- Линтер может быть ещё не установлен (Mason ставит его асинхронно),
          -- тогда try_lint кидает ENOENT на каждом BufEnter. Пропускаем молча.
          for _, name in ipairs(lint.linters_by_ft[vim.bo.filetype] or {}) do
            local linter = lint.linters[name]
            if linter and vim.fn.executable(linter.cmd) == 1 then
              lint.try_lint(name)
            end
          end
        end,
      })
    end,
  },
}, {
  rocks = { enabled = false },
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"
    vim.keymap.set("i", "<C-Space>", "<C-x><C-o>", { buffer = ev.buf })
  end,
})