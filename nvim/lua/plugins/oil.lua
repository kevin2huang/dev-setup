vim.api.nvim_create_autocmd("FileType", {
	pattern = "oil",
	callback = function()
		vim.opt_local.colorcolumn = ""
	end,
})

-- Oil float appearance. Re-applied on ColorScheme since `:colorscheme` clears
-- user highlight groups.
local function set_oil_highlights()
	-- Visible border (it otherwise blends with the background).
	-- Monokai Pro grays: #c1c0c0 dimmed1 · #939293 dimmed2 · #727072 dimmed3 · #5b595c dimmed4.
	vim.api.nvim_set_hl(0, "OilFloatBorder", { fg = "#939293", bg = "#272822" })
	-- Folders otherwise show a #221f22 highlight box; match the float background.
	vim.api.nvim_set_hl(0, "OilDir", { fg = "#727072", bg = "#272822" })
	vim.api.nvim_set_hl(0, "OilDirIcon", { fg = "#727072", bg = "#272822" })
end
set_oil_highlights()
vim.api.nvim_create_autocmd("ColorScheme", { callback = set_oil_highlights })

return {
	{
		"stevearc/oil.nvim",
		opts = {},
		-- Optional dependencies
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("oil").setup({
				-- use_default_keymaps = false,
				keymaps = {
					["<C-_>"] = { "actions.select", opts = { vertical = true } },
				},
				view_options = {
					show_hidden = true,
				},
				-- Make the floating file tree use the editor background (#272822)
				-- instead of the theme's grey float background.
				float = {
					border = "rounded",
					win_options = {
						winblend = 0,
						winhighlight = "Normal:Normal,NormalFloat:Normal,FloatBorder:OilFloatBorder",
					},
				},
			})
		end,
	},
}
