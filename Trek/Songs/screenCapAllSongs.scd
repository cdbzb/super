Monitors.blackHole;
(
~songs = "~/tank/super/Trek/Songs/*".standardizePath.pathMatch.sort;
fork{
	~songs[4..6].do{|i|
			// Song.initClass;
			s.reboot;
			s.doWhenBooted{
				i.load;
				30.wait;
				"vim.cmd.edit(" ++ Song.loadedFrom.quote ++ ")" => SCNvim.luaeval(_);
				Song.recordOBS;
				Song.sections.collect{|i| Song.secDur[i]}.sum + 5 => _.wait;
				defer{ Window.closeAll; };
			}
	}
}
)

