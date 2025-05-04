local set = vim.opt_local

vim.keymap.set("n", "<leader>nd", ":NotesDo<CR>", { buffer = 0 })
vim.keymap.set("v", "<leader>ns", ":NotesSortTasks<CR>", { buffer = 0 })
vim.keymap.set("n", "<CR>", ":NotesOpenLink<CR>", { buffer = 0 })
