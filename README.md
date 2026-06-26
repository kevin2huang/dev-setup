# nvim-setup

Personal Neovim configuration (`nvim/`) and Starship prompt (`starship.toml`).

Plugins are managed by [lazy.nvim](https://github.com/folke/lazy.nvim) and pinned
in `nvim/lazy-lock.json`.

## Setting up on a new machine

See **[SETUP.md](SETUP.md)** for prerequisites (Neovim ≥ 0.12, `tree-sitter-cli`,
node/yarn, etc.), how to symlink the config into `~/.config/nvim`, and first-launch
steps.

## Highlights

- Neovim **0.12+** config (treesitter `main` branch, native `vim.lsp.config` LSP API)
- LSP via Mason + `nvim-lspconfig`, formatting via `conform.nvim`
- Treesitter highlighting, indentation, and a custom incremental-selection module
- Markdown: in-buffer rendering (`render-markdown.nvim`) + browser preview (`markdown-preview.nvim`)
- Leader key: `<Space>`
