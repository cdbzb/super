(
fork{
    loop{	
        var luacode = (
		"local r, c = unpack(vim.api.nvim_win_get_cursor(0))"
		"vim.api.nvim_buf_set_lines(0, r, r, false, {\"%\"})"
	).format("ttt") ;
        SCNvim.luaeval(luacode);
        1.wait;
    }
}
)
(
var string = (
	"vim.fn.setreg('a','fff')"
	"vim.api.nvim_buf_set_lines(0, 20, 20, false, { reg })"
);
SCNvim.luaeval(string)
)
luaeval
ppp
ppp
ppp
ppp
ppp
ppp
ppp
ppp
