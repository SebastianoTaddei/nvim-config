-- Options
vim.g.mapleader = " "
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.confirm = true
vim.opt.termguicolors = true
vim.opt.ignorecase = true
vim.opt.swapfile = false
vim.opt.autoindent = true
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.shiftround = true
vim.opt.list = true
vim.opt.numberwidth = 2
vim.opt.wrap = false
vim.opt.cursorline = true
vim.opt.inccommand = "nosplit"
vim.opt.winborder = "rounded"
vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.opt.showmode = true
vim.opt.cmdheight = 0
vim.o.laststatus = 0

vim.diagnostic.config({
    virtual_text = {
        spacing = 2,
        prefix = "●",
    },
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
})

-- Colorscheme
vim.pack.add({
    { src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
})

require("catppuccin").setup({ flavour = "macchiato" })
vim.cmd.colorscheme("catppuccin-nvim")

-- LSP
vim.pack.add({
    { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
    { src = "https://github.com/neovim/nvim-lspconfig" },
    { src = "https://github.com/mason-org/mason.nvim" },
    { src = "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim" },
    { src = "https://github.com/saghen/blink.cmp", version = "v1.10.2" },
    { src = "https://github.com/stevearc/conform.nvim" },
})

require("mason").setup()
require("mason-tool-installer").setup({
    ensure_installed = {
        -- LSPs
        "pyright",
        "clangd",
        "lua-language-server",
        "yaml-language-server",
        "taplo",
        "gh-actions-language-server",
        "marksman",
        "neocmakelsp",

        -- Formatters & Linters
        "ruff",
        "stylua",
        "clang-format",
        "prettier",
        "gersemi",
    },
    run_on_start = true,
})
require("blink.cmp").setup({
    keymap = {
        preset = "enter",
        ["<Tab>"] = { "select_next", "fallback" },
        ["<S-Tab>"] = { "select_prev", "fallback" },
    },
    completion = {
        list = { selection = { preselect = false, auto_insert = false } },
        documentation = {
            auto_show = true,
            auto_show_delay_ms = 200,
        },
        ghost_text = {
            enabled = true,
        },
        menu = {
            draw = {
                treesitter = { "lsp" },
            },
        },
    },
    signature = {
        enabled = true,
        window = {
            border = "rounded",
        },
    },
})
require("conform").setup({
    formatters_by_ft = {
        python = { "ruff_format" },
        lua = { "stylua" },
        c = { "clang-format" },
        cpp = { "clang-format" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        toml = { "taplo" },
        cmake = { "gersemi" },
    },
})

-- Plugins
vim.pack.add({
    { src = "https://github.com/stevearc/oil.nvim" },
    { src = "https://github.com/nvim-mini/mini.icons" },
    { src = "https://github.com/nvim-tree/nvim-web-devicons" },
    { src = "https://github.com/folke/which-key.nvim" },
    { src = "https://github.com/folke/snacks.nvim" },
    { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
    { src = "https://github.com/MeanderingProgrammer/render-markdown.nvim" },
    { src = "https://github.com/danymat/neogen" },
    { src = "https://github.com/folke/todo-comments.nvim" },
})

require("nvim-web-devicons").setup()
require("mini.icons").setup()
require("oil").setup({ delete_to_trash = true, keymaps = { ["q"] = { "actions.close", mode = "n" } } })
require("which-key").setup()
require("snacks").setup({
    bigfile = { enabled = true },
    bufdelete = { enabled = true },
    image = { enabled = true },
    indent = { enabled = true },
    input = { enabled = true },
    lazygit = { enabled = true },
    notifier = { enabled = true },
    picker = { enabled = true },
    quickfile = { enabled = true },
    scope = { enabled = true },
    statuscolumn = { enabled = true },
})
require("render-markdown").setup({
    code = {
        sign = false,
        width = "block",
        right_pad = 1,
    },
    heading = {
        sign = false,
        icons = {},
    },
    checkbox = {
        enabled = true,
    },
})
require("neogen").setup({
    snippet_engine = "nvim",
    languages = {
        python = {
            template = {
                annotation_convention = "reST",
            },
        },
    },
})
require("todo-comments").setup()

-- Autocmds
vim.api.nvim_create_autocmd("User", {
    pattern = "MasonToolsUpdateCompleted",
    callback = function()
        vim.lsp.config("lua_ls", {
            settings = {
                Lua = {
                    diagnostics = {
                        globals = { "vim" },
                    },
                    workspace = {
                        library = {
                            vim.env.VIMRUNTIME,
                        },
                    },
                },
            },
        })

        vim.lsp.enable({
            "pyright",
            "ruff",
            "clangd",
            "lua_ls",
            "yamlls",
            "taplo",
            "gh_actions_ls",
            "marksman",
            "neocmake",
        })
    end,
})
vim.api.nvim_create_autocmd("BufWritePre", {
    callback = function()
        require("conform").format({ async = false, lsp_fallback = true })
    end,
})
vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function()
        vim.highlight.on_yank()
    end,
})

-- Keymaps
vim.keymap.set("n", "<Esc><Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "gd", vim.lsp.buf.definition)
vim.keymap.set("n", "gD", vim.lsp.buf.declaration)
require("which-key").add({
    {
        mode = "n",
        { "<leader>l", Snacks.lazygit.open, desc = "lazygit" },
        { "<leader>f", group = "file" },
        { "<leader>fe", "<cmd>Oil<cr>", desc = "file explorer" },
        { "<leader>ff", Snacks.picker.files, desc = "find files" },
        { "<leader>fb", Snacks.picker.buffers, desc = "find buffers" },
        { "<leader>g", group = "grep" },
        { "<leader>gf", Snacks.picker.grep, desc = "grep files" },
        { "<leader>gb", Snacks.picker.grep_buffers, desc = "grep buffers" },
        {
            "<leader>t",
            function()
                if vim.o.laststatus == 0 then
                    vim.o.laststatus = 3
                else
                    vim.o.laststatus = 0
                end
            end,
            desc = "toggle statusline",
        },
        {
            "<leader>c",
            desc = "code",
        },
        {
            "<leader>cn",
            desc = "neogen",
        },
        {
            "<leader>cnf",
            function()
                require("neogen").generate({
                    type = "func",
                })
            end,
            desc = "annotate function",
        },
        {
            "<leader>cnt",
            function()
                require("neogen").generate({
                    type = "type",
                })
            end,
            desc = "annotate type",
        },
        {
            "<leader>cnc",
            function()
                require("neogen").generate({
                    type = "class",
                })
            end,
            desc = "annotate class",
        },
        {
            "<leader>cnF",
            function()
                require("neogen").generate({
                    type = "file",
                })
            end,
            desc = "annotate file",
        },
    },
})
