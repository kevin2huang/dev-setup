
return {
	{
		"nvim-pack/nvim-spectre",
		lazy = true,
		cmd = { "Spectre" },
		dependencies = {
			"nvim-lua/plenary.nvim",
			"loctvl842/monokai-pro.nvim",
		},
		config = function()
			-- Monokai Pro palette (background overridden to #272822)
			local red = "#ff6188"
			local green = "#a9dc76"
			local base = "#272822"

			vim.api.nvim_set_hl(0, "SpectreSearch", { bg = red, fg = base })
			vim.api.nvim_set_hl(0, "SpectreReplace", { bg = green, fg = base })

			require("spectre").setup({
				highlight = {
					search = "SpectreSearch",
					replace = "SpectreReplace",
				},
				mapping = {
					["send_to_qf"] = {
						map = "<C-q>",
						cmd = "<cmd>lua require('spectre.actions').send_to_qf()<CR>",
						desc = "send all items to quickfix",
					},
				},
				-- replace_engine = {
				-- 	sed = {
				-- 		cmd = "sed",
				-- 		args = {
				-- 			"-i",
				-- 			"",
				-- 			"-E",
				-- 		},
				-- 	},
				-- },
			})
		end,
	},
}
