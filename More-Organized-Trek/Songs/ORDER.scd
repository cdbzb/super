"/Users/michael/tank/super/More-Organized-Trek/Songs/*".pathMatch.do(_.load)
(
fork{
	"/Users/michael/tank/super/More-Organized-Trek/Songs/*".pathMatch.do(
		{|i| 
			'LOAD'.post;i.postln;
			try{
				i.load;

			};
			2.wait;
		}
	)
}
)
"/Users/michael/tank/super/More-Organized-Trek/Songs/*".pathMatch.do(_.postln)
s.reboot
~listSongs.() 
Song.songs.keys.do(_.postln )

(
a=Order();
[
	'chamber',222,
	'complete',246,
	'displeased',444,
	'medical',555,
	'sickBay',666,
	'silverLake',777,
	'smallChamber',888,
	'song',239,
	'this formnula',999,
	'three',555,
	'unnecessary',5,
	'transform',245
].pairsDo({|i j| a.put(j,i)})
)
a.doRange(_.postln,0,3)
