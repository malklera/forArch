require("auto-session").setup({
	--   allowed_dirs = { "/some/dir/", "/projects/*", "~/work/**" },
	--   suppressed_dirs = { "/projects/secret" },
	-- * - Matches any characters in a single directory level (does not match /)
	-- Example: /projects/* matches /projects/foo but NOT /projects/foo/bar
	-- ** - Matches any characters including directory separators (matches across multiple levels)
	-- Example: /projects/** matches /projects/foo, /projects/foo/bar, /projects/foo/bar/baz, etc.
	-- ? - Matches exactly one character (excluding /)
	-- Example: /project? matches /project1 or /projecta but not /project12
	-- ~ - Expands to your home directory
	-- Example: ~/.config/* matches any direct child of your .config directory
})
vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
