return {
    'nvim-telescope/telescope.nvim', tag = '0.1.8',
    dependencies = { 'nvim-lua/plenary.nvim' },
    init = function()
        local builtin = require('telescope.builtin')

        vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
        vim.keymap.set('n', '<C-p>', builtin.git_files, {})
        vim.keymap.set('n', '<leader>pws', function()
            local word = vim.fn.expand("<cword>")
            builtin.grep_string({ search = word })
        end)
        vim.keymap.set('n', '<leader>pWs', function()
            local word = vim.fn.expand("<cWORD>")
            builtin.grep_string({ search = word })
        end)
        vim.keymap.set('n', '<leader>ps', function()
            builtin.grep_string({ search = vim.fn.input("Grep > ") })
        end)
        vim.keymap.set('n', '<leader>vh', builtin.help_tags, {})
        vim.keymap.set('n', '<leader>pb', builtin.buffers, {})
    end,
    config = function()
        local telescope = require('telescope')

        telescope.setup {
            defaults = {
                layout_config = {
                    prompt_position = 'top',
                    horizontal = {
                        mirror = false,
                        preview_cutoff = 100,
                        preview_width = 0.5
                    },
                    vertical = {
                        mirror = false,
                        preview_cutoff = 0.4
                    }
                }
            }
        }
    end
}
