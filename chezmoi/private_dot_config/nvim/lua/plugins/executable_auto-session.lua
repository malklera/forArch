return {
    "rmagatti/auto-session",
    lazy = false,

    ---enables autocomplete for opts
    ---@module "auto-session"
    ---@type AutoSession.Config
    opts = {
        suppressed_dirs = { "/" },
        allowed_dirs = { "/home/malklera/study" },
        use_git_branch_name = true,
        auto_session_enable = true,
    },
}
