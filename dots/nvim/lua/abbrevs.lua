vim.cmd([[
  iabbrev <expr> ;d strftime('%m.%d.%Y %H:%M')
  iabbrev ;p println!("{:?}",);<Left><Left>
  iabbrev ;x - [ ]
]])
