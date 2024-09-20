Nvim {

    *send{|code|
        // Wrap like this to avoid problems when not using SCNvim
        if(\SCNvim.asClass.notNil, {
            \SCNvim.asClass.luaeval(code)
        });
    }

    /*
    Log levels are one of the values defined in `vim.log.levels`:

    vim.log.levels.DEBUG
    vim.log.levels.ERROR
    vim.log.levels.INFO
    vim.log.levels.TRACE
    vim.log.levels.WARN
    */

    *notify{|msg, log_level=3|
        var code = "vim.api.nvim_notify('%', %, {})".format(msg, log_level);
        this.send(code)
    }

    *create_buf{|listed=true, scratch=false|
        var code = "vim.api.nvim_create_buf(%, %)".format(listed, scratch);
        this.send(code)
    }

    // Paste text at cursor
    *paste{|text|
        var code = "vim.api.nvim_paste('%', true, 1)".format(text);
        this.send(code)
    }

	*replace {|text|
		var t = "local buf = vim.api.nvim_get_current_buf()"
			"local line = vim.api.nvim_win_get_cursor(0)[1]"
			"local text = {"
			"\"%\""
			"}"
			"vim.api.nvim_buf_set_lines(buf, line-1, line, false, text)"
		;
		SCNvim.luaeval(t.format(text))
	}
	*insert{|text|
		var t = "local buf = vim.api.nvim_get_current_buf()"
			"local text = {"
			"\"%\""
			"}"
			"vim.api.nvim_buf_set_lines(buf, -1, -1, false, text)"
		;
		SCNvim.luaeval(t.format(text))
	}

    *tabnew{|file|
        var code = "vim.cmd[[tabnew " ++ file ++ "]]";
        this.send(code.postln)
    }

    *cmd{|cmd|
        var code = "vim.cmd[[%]]".format(cmd);
        this.send(code)
    }

    *e{|file|
        var code = this.cmd("e " ++ file);
        this.send(code)
    }
}
