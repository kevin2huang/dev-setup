return {
	{
		"echasnovski/mini.icons",
		version = false,
		lazy = false,
		-- Load after the colorscheme (priority 1000) but before the lazy-loaded UI
		-- plugins, so the nvim-web-devicons mock is in place when they ask for icons.
		priority = 900,
		config = function()
			local gleam_star = vim.fn.nr2char(0xf005)

			require("mini.icons").setup({
				-- Preserve the custom pink Gleam star (was an nvim-web-devicons override).
				extension = {
					gleam = { glyph = gleam_star, hl = "MiniIconsGleam" },
				},
				filetype = {
					gleam = { glyph = gleam_star, hl = "MiniIconsGleam" },
				},
			})

			-- Custom highlight for the Gleam icon (#ffaff3). Re-applied on colorscheme
			-- changes since `:colorscheme` clears user highlight groups.
			local function set_gleam_hl()
				vim.api.nvim_set_hl(0, "MiniIconsGleam", { fg = "#ffaff3" })
			end
			set_gleam_hl()
			vim.api.nvim_create_autocmd("ColorScheme", { callback = set_gleam_hl })

			-- Plugins that ask for nvim-web-devicons (oil, telescope, lualine, …)
			-- transparently use mini.icons instead.
			MiniIcons.mock_nvim_web_devicons()
		end,
	},
}
