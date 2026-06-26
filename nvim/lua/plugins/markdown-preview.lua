-- Live markdown preview in the browser (synced scrolling, auto-refresh).
-- Commands: :MarkdownPreview, :MarkdownPreviewStop, :MarkdownPreviewToggle
return {
	{
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		ft = { "markdown" },
		-- Build the bundled preview server from source via yarn (already on PATH).
		-- Using the shell form (not mkdp#util#install) so it works in headless
		-- `:Lazy build` runs where the plugin's autoload fns aren't loaded.
		build = "cd app && yarn install",
		init = function()
			-- Don't auto-open the browser on entering a markdown buffer.
			vim.g.mkdp_auto_start = 0
			-- Keep the preview open when switching away from the markdown buffer.
			vim.g.mkdp_auto_close = 0
		end,
		config = function()
			-- Buffer-local keymaps, markdown only, so they don't touch the global
			-- <leader>m (MaximizerToggle) outside markdown buffers.
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "markdown",
				callback = function(args)
					vim.keymap.set(
						"n",
						"<leader>mp",
						"<cmd>MarkdownPreviewToggle<cr>",
						{ buffer = args.buf, desc = "[M]arkdown [P]review toggle" }
					)
					vim.keymap.set(
						"n",
						"<leader>ms",
						"<cmd>MarkdownPreviewStop<cr>",
						{ buffer = args.buf, desc = "[M]arkdown preview [S]top" }
					)
				end,
			})
		end,
	},
}
