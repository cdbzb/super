NvimRemote : Nvim {
	classvar <>file = "/tmp/nvim-server";

	*send {|keys|
		"nvim --server '%' --remote-send '%' ".format(file, keys).unixCmd
	}
	*findLineAndCenter {|string file|
		this.send("/" ++ string ++ "<CR>" ++ "z.", "/tmp/nvim-server")
	}

	*edit {|file|
		"nvim --server /tmp/nvim-server --remote %".format(file)
		.unixCmd
	}
}
