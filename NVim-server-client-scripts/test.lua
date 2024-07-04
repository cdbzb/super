-- In the server instance
-- Start Neovim with: nvim --listen /tmp/nvim-server

-- In the client instance
vim.cmd([[
  let channel = sockconnect('pipe', '/tmp/nvim-server', {'rpc': v:true})
  let remote_bufnr = rpcrequest(channel, 'nvim_get_current_buf')
  let content = rpcrequest(channel, 'nvim_buf_get_lines', remote_bufnr, 0, -1, v:false)
  call setline(1, content)

  " function! SyncBuffer(bufnr, start, end, added, changes)
  "   let new_end = a:start + a:added
  "   let old_end = a:end + 1
  "   let new_lines = rpcrequest(channel, 'nvim_buf_get_lines', remote_bufnr, a:start, new_end, v:false)
  "   
  "   if a:added > 0
  "     " Lines were added
  "     call append(a:start, new_lines)
  "   elseif a:added < 0
  "     " Lines were removed
  "     execute (a:start + 1) . ',' . old_end . 'delete _'
  "   else
  "     " Lines were changed
  "     call setline(a:start + 1, new_lines)
  "   endif
  "   
  "   return v:true
  " endfunction

  " call rpcrequest(channel, 'nvim_buf_attach', remote_bufnr, v:false, {'on_lines': 'SyncBuffer'})
]])
