vim.cmd([[
  " Insert current datetime
  iabbrev <expr> ,d strftime('%m.%d.%Y %H:%M')

  " Insert todo item
  iabbrev =x - [ ]

  iabbrev =w fs_err::write("/tmp/some", data).expect("Unable to write file");
  iabbrev =r let data = fs_err::read_to_string("/tmp/some").expect("Unable to read file");
]])
