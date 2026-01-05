-- cloning lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({
        "git",
	    "clone",
	    "--filter=blob:none",
	    "--branch=stable",
	    lazyrepo,
	    lazypath
    })
    if vim.v.shell_error ~= 0 then
	    vim.api.nvim_echo({
            {
                "Failed to clone lazy.nvim:\n",
    	        "ErrorMsg"
	        },{
                out,
		        "WarningMsg"
    	    },{
                "\nPress any key to exit..."
	        }
	    },
        true,
	    {})
	    vim.fn.getchar()
	    os.exit(1)
    end
end

-- settings
vim.opt.rtp:prepend(lazypath)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.g.disable_background = false
vim.g.nord_italic = false
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.number = true
vim.opt.whichwrap:append("<,>,[,]")
vim.opt.undofile = true
vim.opt.mousemoveevent = true
vim.opt.completeopt = {
    "menu",
    "menuone",
    "noinsert"
}
vim.opt.guicursor = {
    "n-v-c-i-r-cr:hor20"
}
vim.filetype.add({
    extension = {
        CPP = "cpp"
    }
})

-- lazy setup & plugins
require("lazy").setup({
    spec = {
        {
            "windwp/nvim-autopairs",
            event = "InsertEnter",
            opts = {}
        },{
            "shaunsingh/nord.nvim",
            config = function()
                vim.cmd.colorscheme("nord")
            end
        },{
            "nvim-lualine/lualine.nvim",
            dependencies = {
                "nvim-tree/nvim-web-devicons"
            },
            opts = {}
        },{
            "nvim-treesitter/nvim-treesitter",
            lazy = false,
            build = ":TSUpdate",
            opts = {
                ensure_installed = {
                    "c",
                    "cpp",
                    "python",
                    "lua",
                    "bash"
                },
                highlight = {
                    enable = true,
                    additional_vim_regex_highlighting = false
                },
                indent = {
                    enable = true
                }
            }
        },{
            "neovim/nvim-lspconfig"
        },{
            "nvim-treesitter/nvim-treesitter-context",
            dependencies = {
                "nvim-treesitter/nvim-treesitter"
            },
            opts = {
                mode = "topline"
            }
        },{
            "lukas-reineke/indent-blankline.nvim",
            main = "ibl",
            ---@module "ibl"
            ---@type ibl.config
            opts = {}
        },{
            "j-hui/fidget.nvim",
            opts = {}
        },{
            "nvim-tree/nvim-tree.lua",
            version = "*",
            lazy = false,
            dependencies = {
                "nvim-tree/nvim-web-devicons"
            },
            opts = {}
        },{
            "akinsho/bufferline.nvim",
            dependencies = {
                "nvim-tree/nvim-web-devicons"
            }
        },{
            "L3MON4D3/LuaSnip",
            dependencies = {
                "rafamadriz/friendly-snippets"
            }
        }
    },
    install = {
        colorscheme = {
            "nord"
 	    }
    },
    checker = {
        enabled = true
    }
})

-- lsp setup
vim.lsp.config("pyright", {})
vim.lsp.config("clangd", {})
vim.lsp.config("lua_ls", {
    settings = {
        Lua = {
            runtime = {
                version = "LuaJIT"
            },
            diagnostics = {
                globals = {
                    "vim"
                }
            },
            workspace = {
                library = vim.api.nvim_get_runtime_file("", true),
                checkThirdParty = false,
            },
            telemetry = {
                enable = false
            }
        }
    }
})
vim.lsp.enable({
    "pyright",
    "clangd",
    "lua_ls"
})

-- bufferline setup
local bufferline = require("bufferline")
bufferline.setup({
    options = {
        hover = {
            enabled = true,
            delay = 0,
            reveal = {
                "close"
            }
        },
        diagnostics = "nvim_lsp",
        max_name_length = 18,
        style_preset = bufferline.style_preset.no_italic
    }
})

-- luasnip setup
require("luasnip.loaders.from_vscode").lazy_load()
require("luasnip.loaders.from_lua").load({
    paths = "/home/tr43212/.config/nvim/snippets"
})

-- builtin cmp
vim.api.nvim_create_autocmd("InsertCharPre", {
    callback = function()
        if vim.fn.pumvisible() == 1 then
            return
        end
        if #vim.lsp.get_clients({
            bufnr = 0
        }) == 0 then
            return
        end
        vim.api.nvim_feedkeys(
            vim.api.nvim_replace_termcodes("<C-x><C-o>", true, false, true),
            "n",
            true
        )
    end
})

-- keymaps
-- cmp
vim.keymap.set("i", "<Tab>", function()
    if vim.fn.pumvisible() == 1 then
        return vim.keycode("<C-y>")
    else
        return vim.keycode("<Tab>")
    end
end, {
    expr = true
})
vim.keymap.set("i", "<Esc>", function()
    if vim.fn.pumvisible() == 1 then
        return vim.keycode("<C-e>")
    else
        return vim.keycode("<Esc>")
    end
end, {
    expr = true
})

-- line wrap
vim.keymap.set({
    "i",
    "n",
    "v"
}, "<Up>", function()
    local line = vim.api.nvim_win_get_cursor(0)[1]
    if line == 1 then
            if vim.fn.pumvisible() == 1 then
                return "<Up>"
            else
                return "<Home>"
            end
    else
        return "<Up>"
    end
end, {
    expr = true
})
vim.keymap.set({
    "i",
    "n",
    "v"
}, "<Down>", function()
    local line = vim.api.nvim_win_get_cursor(0)[1]
    local last = vim.api.nvim_buf_line_count(0)
    if line == last then
        if vim.fn.pumvisible() == 1 then
            return "<Down>"
        else
            return "<End>"
        end
    else
        return "<Down>"
    end
end, {
    expr = true
})

-- select all
vim.keymap.set({
    "n",
    "v"
}, "<C-a>", "ggVG")
vim.keymap.set("i", "<C-a>", "<C-o>gg<C-o>VG")

-- copy
vim.keymap.set({
    "n",
    "v"
}, "<C-c>", '"+y')

-- paste
vim.keymap.set("i", "<C-v>", '<C-o>"+p', {
    noremap = true
})
vim.keymap.set({
    "n",
    "v"
}, "<C-v>", '"+p', {
    noremap = true
})

-- undo
vim.keymap.set("i", "<C-z>", "<C-o>u")
vim.keymap.set({
    "n",
    "v"
}, "<C-z>", "u")

-- redo
vim.keymap.set("i", "<C-x>", "<C-o><C-r>")
vim.keymap.set({
    "n",
    "v"
}, "<C-x>", "<C-r>")

-- visual mode bs
vim.keymap.set("v", "<BS>", "<Del>")

-- bufferline controls
vim.keymap.set("i", "<C-Tab>", "<C-o>:bn<CR>")
vim.keymap.set({
    "n",
    "v"
}, "<C-Tab>", ":bn<CR>")
vim.keymap.set("i", "<C-w>", "<C-o>:bdelete<CR><C-o>:bn<CR>")
vim.keymap.set({
    "n",
    "v"
}, "<C-w>", ":bdelete<CR>:bn<CR>")

-- save
vim.keymap.set("i", "<C-s>", "<C-o>:w<CR>")
vim.keymap.set({
    "n",
    "v"
}, "<C-s>", ":w<CR>")

-- enable diagnostics
vim.diagnostic.config({
    virtual_text = true,
    signs = true,
    underline = true,
    update_in_insert = true
})

-- open file panel
vim.api.nvim_cmd({
    cmd = "NvimTreeFocus",
    args = {}
}, {})
