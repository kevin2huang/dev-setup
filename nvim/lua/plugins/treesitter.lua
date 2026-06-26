-- nvim-treesitter `main` branch (required for Neovim 0.12+).
-- The old `master` branch is frozen and only supports Neovim 0.10/0.11.
-- This is a full rewrite with a different API:
--   * no lazy-loading (lazy = false)
--   * parsers installed via require("nvim-treesitter").install{...}
--   * highlighting comes from Neovim core (vim.treesitter.start()), not a `highlight` table
--   * indentation is via indentexpr (experimental)
--   * incremental_selection no longer exists on `main`
local parsers = {
	"bash",
	"css",
	"gleam",
	"go",
	"html",
	"javascript",
	"json",
	"lua",
	"markdown",
	"markdown_inline",
	"ocaml",
	"ocaml_interface",
	"rust",
	"svelte",
	"terraform",
	"tsx",
	"typescript",
	"vimdoc",
	"yaml",
}

return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false, -- `main` does not support lazy-loading
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter").install(parsers)

			-- Enable treesitter highlighting + indentation per buffer.
			-- vim.treesitter.start() is provided by Neovim core; it replaces
			-- the old `highlight = { enable = true }` option.
			vim.api.nvim_create_autocmd("FileType", {
				callback = function(args)
					local buf = args.buf
					local ft = vim.bo[buf].filetype
					local lang = vim.treesitter.language.get_lang(ft)
					if not lang then
						return
					end

					-- Only start if a parser is actually available (installs are async).
					if not pcall(vim.treesitter.start, buf, lang) then
						return
					end

					-- Experimental treesitter indentation (ocaml excluded, matching prior config).
					if lang ~= "ocaml" and lang ~= "ocaml_interface" then
						vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
					end
				end,
			})

			-- Incremental selection (removed from `main`; reimplemented locally).
			-- Mirrors the previous master-branch keymaps.
			local isel = require("khuang.ts_incremental_selection")
			vim.keymap.set("n", "<c-space>", isel.init_selection, { desc = "TS: init selection" })
			vim.keymap.set("x", "<c-space>", isel.node_incremental, { desc = "TS: expand selection" })
			vim.keymap.set("x", "<c-s>", isel.scope_incremental, { desc = "TS: expand to scope" })
			vim.keymap.set("x", "<c-backspace>", isel.node_decremental, { desc = "TS: shrink selection" })
		end,
	},
	{
		-- Additional text objects for treesitter (`main` branch API).
		"nvim-treesitter/nvim-treesitter-textobjects",
		branch = "main",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = function()
			require("nvim-treesitter-textobjects").setup({
				select = {
					lookahead = true, -- jump forward to textobj, similar to targets.vim
				},
				move = {
					set_jumps = true, -- store movements in the jumplist
				},
			})

			local select = require("nvim-treesitter-textobjects.select")
			local move = require("nvim-treesitter-textobjects.move")

			-- select (preserves: aa/ia parameter, af/if function, ac/ic class)
			local selects = {
				aa = "@parameter.outer",
				ia = "@parameter.inner",
				af = "@function.outer",
				["if"] = "@function.inner",
				ac = "@class.outer",
				ic = "@class.inner",
			}
			for key, query in pairs(selects) do
				vim.keymap.set({ "x", "o" }, key, function()
					select.select_textobject(query, "textobjects")
				end, { desc = "Select " .. query })
			end

			-- move (preserves: ]m ]] / ]M ][ / [m [[ / [M [])
			local moves = {
				goto_next_start = { ["]m"] = "@function.outer", ["]]"] = "@class.outer" },
				goto_next_end = { ["]M"] = "@function.outer", ["]["] = "@class.outer" },
				goto_previous_start = { ["[m"] = "@function.outer", ["[["] = "@class.outer" },
				goto_previous_end = { ["[M"] = "@function.outer", ["[]"] = "@class.outer" },
			}
			for fn, maps in pairs(moves) do
				for key, query in pairs(maps) do
					vim.keymap.set({ "n", "x", "o" }, key, function()
						move[fn](query, "textobjects")
					end, { desc = fn .. " " .. query })
				end
			end
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-context",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = function()
			local tsc = require("treesitter-context")

			tsc.setup({
				enable = false,
				max_lines = 1,
				trim_scope = "inner",
			})
		end,
	},
}
