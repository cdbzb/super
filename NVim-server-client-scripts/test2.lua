vim.cmd([[
  let channel = sockconnect('pipe', '/tmp/nvim-server', {'rpc': v:true})
  let remote_bufnr = rpcrequest(channel, 'nvim_get_current_buf')
  let content = rpcrequest(channel, 'nvim_buf_get_lines', remote_bufnr, 0, -1, v:false)
  call setline(1, content)
  
  function! SyncBuffer(timer)
    let content = rpcrequest(channel, 'nvim_buf_get_lines', remote_bufnr, 0, -1, v:false)
    call setline(1, content)
  endfunction
  
  call timer_start(1000, 'SyncBuffer', {'repeat': -1})
]])
