return {
	{
		"loctvl842/monokai-pro.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("monokai-pro").setup({
				-- "pro" is the default Monokai Pro palette, matching
				-- ~/Documents/themes/monokai_pro.json. Other filters: classic,
				-- octagon, machine, ristretto, spectrum.
				filter = "pro",
				-- Icons are provided by mini.icons (see mini-icons.lua), so the
				-- built-in nvim-web-devicons recolor integration is off.
				devicons = false,
				terminal_colors = true,
				-- Background overridden from Monokai Pro's #2d2a2e to #272822.
				override_palette = function(_)
					return {
						background = "#272822",
					}
				end,
				-- Italics matched to the VSCode token customizations: comments,
				-- keywords, class/type names, storage modifiers, the class keyword.
				styles = {
					comment = { italic = true },
					keyword = { italic = true },
					type = { italic = true },
					storageclass = { italic = true },
					structure = { italic = true },
					parameter = { italic = false },
					annotation = { italic = false },
					tag_attribute = { italic = true },
				},
			})

			vim.api.nvim_create_autocmd("ColorScheme", {
				pattern = "monokai-pro",
				callback = function()
					-- VSCode also italicizes "constant" (numbers, booleans, language
					-- constants like this/super). monokai-pro exposes no style key for
					-- these, so flip italic on the resolved groups (preserving color).
					local italic_groups = {
						"Constant",
						"Boolean",
						"Number",
						"Float",
						"@constant",
						"@constant.builtin",
						"@boolean",
						"@number",
						"@variable.builtin",
					}
					for _, g in ipairs(italic_groups) do
						local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = g, link = false })
						if ok and hl then
							hl.italic = true
							pcall(vim.api.nvim_set_hl, 0, g, hl)
						end
					end

					-- Replace any remaining #2d2a2e with #272822 across every group
					-- (catches floats/menus/plugin groups not driven by the palette).
					local OLD, NEW = 0x2d2a2e, 0x272822
					for name, _ in pairs(vim.api.nvim_get_hl(0, {})) do
						local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
						local changed = false
						if hl.bg == OLD then
							hl.bg = NEW
							changed = true
						end
						if hl.fg == OLD then
							hl.fg = NEW
							changed = true
						end
						if hl.sp == OLD then
							hl.sp = NEW
							changed = true
						end
						if changed then
							pcall(vim.api.nvim_set_hl, 0, name, hl)
						end
					end
				end,
			})

			vim.cmd.colorscheme("monokai-pro")
		end,
	},
}
