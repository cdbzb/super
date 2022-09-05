+Date {
	*insertStamp{
		var luacode = 
		"local pos = vim.api.nvim_win_get_cursor(0);"
		"vim.api.nvim_buf_set_text(0,pos[1]-1,pos[2],pos[1]-1,pos[2],{ [[%]]})".format(Date.getDate.stamp);
		SCNvim.luaeval(luacode)
	}
}
