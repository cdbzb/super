OBS {
	classvar cli;  // resolved absolute path to obs-cli, cached on first use

	// .unixCmd runs under a minimal /bin/sh with no ~/.bash_profile PATH,
	// so bare "obs-cli" isn't found. Resolve it once via a bash login shell
	// (which sources ~/.bash_profile, where the Python-bin PATH lives), and
	// cache. Survives the binary moving as long as .bash_profile points at it.
	*cliPath {
		cli ?? {
			cli = "/bin/bash -lc 'command -v obs-cli' 2>/dev/null".unixCmdGetStdOut.stripWhiteSpace;
			cli.isEmpty.if { "OBS: obs-cli not found on login-shell PATH".warn };
		};
		^cli;
	}

	*record {
		(this.cliPath + "--password Where4obs record start").unixCmd;
	}
	*stop {
		(this.cliPath + "--password Where4obs record stop").unixCmd;
	}
	*status {
		^(this.cliPath + "--password Where4obs record status").unixCmdGetStdOut.stripWhiteSpace;
	}
}
