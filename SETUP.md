# Setting up this Neovim config on a new machine

This repo holds a personal Neovim configuration (`nvim/`) plus a Starship prompt
(`starship.toml`). Plugins are managed by [lazy.nvim](https://github.com/folke/lazy.nvim),
which bootstraps itself on first launch — you only need to install the external
tools below and symlink the config into place.

## 1. Prerequisites

Install these with your system package manager (examples use Homebrew on macOS):

| Tool | Why it's needed | Install |
| --- | --- | --- |
| **Neovim ≥ 0.12** | Required by the `nvim-treesitter` **`main`** branch and the native `vim.lsp.config` LSP API used here. 0.11 and older will break. | `brew install neovim` |
| **git** | lazy.nvim clones plugins; treesitter/lspconfig fetch sources. | `brew install git` |
| **A C compiler** | Treesitter parsers are compiled locally. | macOS: `xcode-select --install` |
| **tree-sitter CLI ≥ 0.26.1** | The treesitter `main` branch compiles parsers with the `tree-sitter` binary. **Must be the real CLI**, not the npm package and not the `tree-sitter` library-only formula. | `brew install tree-sitter-cli` |
| **Node.js + yarn** | `markdown-preview.nvim` builds its preview server with yarn. | `brew install node yarn` (or use nvm) |
| **curl, tar** | Treesitter parser downloads. | Preinstalled on macOS |
| **ripgrep, fd** | Telescope live-grep / find-files. | `brew install ripgrep fd` |
| **Starship** (optional) | Shell prompt configured by `starship.toml`. | `brew install starship` |

> **Important — tree-sitter CLI gotcha:** Homebrew's `tree-sitter` formula installs
> only the C *library* (no `tree-sitter` binary on PATH). The treesitter `main`
> branch needs the actual CLI, which lives in the separate **`tree-sitter-cli`**
> formula. After installing, confirm `tree-sitter --version` works in your shell.

## 2. Clone and symlink

Neovim reads from `~/.config/nvim`. This repo keeps the config under `nvim/`, so
symlink that subdirectory:

```bash
git clone git@github.com:kevin2huang/nvim-setup.git ~/Documents/Github/nvim-setup

# Back up an existing config first, if any:
[ -e ~/.config/nvim ] && mv ~/.config/nvim ~/.config/nvim.bak

ln -s ~/Documents/Github/nvim-setup/nvim ~/.config/nvim
```

Optionally link the Starship config:

```bash
ln -s ~/Documents/Github/nvim-setup/starship.toml ~/.config/starship.toml
```

## 3. First launch

```bash
nvim
```

On first start, lazy.nvim self-installs, then installs every plugin pinned in
`nvim/lazy-lock.json`. Let it finish, then:

1. **Install treesitter parsers** — run `:TSUpdate` (parsers compile into
   `~/.local/share/nvim/site/parser/`). If markdown/code highlighting throws a
   `treesitter` error on a fresh install, it's usually because parsers haven't
   compiled yet — re-run `:TSUpdate` and restart.
2. **Let Mason install LSP servers/formatters** — these install automatically on
   startup (via `mason-tool-installer`). Watch the bottom-right progress; or run
   `:Mason` to check. A few servers are expected to be installed *manually*
   (not via Mason): `ocamllsp`, `gleam`, `rust_analyzer`.
3. **Build the markdown preview** — if `:MarkdownPreview` errors, run
   `:Lazy build markdown-preview.nvim` (or `cd ~/.local/share/nvim/lazy/markdown-preview.nvim/app && yarn install`).

## 4. Verify

```vim
:checkhealth
```

Open a markdown file and confirm it renders without errors, then try
`:MarkdownPreview` (browser preview) and `<c-space>` in a code file (treesitter
incremental selection). Open a `.ts`/`.js` file and confirm LSP attaches
(`:LspInfo`).

## Reproducing exact plugin versions

`nvim/lazy-lock.json` pins every plugin to a specific commit. To match this
machine exactly, run `:Lazy restore` after the first launch (restores the locked
commits rather than pulling latest). To intentionally update everything later,
use `:Lazy sync` / `:Lazy update`.

## Notes / gotchas baked into this config

- **nvim-treesitter uses the `main` branch** (not `master`). `master` is frozen
  and only supports Neovim ≤ 0.11. See `lua/plugins/treesitter.lua`.
- **LSP uses the native `vim.lsp.config` / `vim.lsp.enable` API**, not the
  deprecated `require("lspconfig")[name].setup{}` framework (removed in
  lspconfig v3.0.0). See `lua/plugins/lsp.lua`.
- **mason-lspconfig has `automatic_enable = false`** so this config controls
  exactly which servers start. In particular **eslint is configured but not
  auto-enabled** (`autostart = false`) — start it manually with
  `:LspStart eslint` when you want it.
- **Treesitter incremental selection** is a local reimplementation
  (`lua/khuang/ts_incremental_selection.lua`) because the `main` branch dropped
  the built-in module. Keys: `<c-space>` init/expand, `<c-s>` scope expand,
  `<c-backspace>` shrink.
- Leader key is `<Space>`.
