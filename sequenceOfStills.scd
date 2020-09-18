Song.smallChamber ?? { "/Users/michael/tank/super/More-Organized-Trek/Songs/small-chamber.scd".load; };
~stills ??  {~stills=Stills("/Users/michael/tank/Trek/video for stills etc/media/return to tomorrow.mov")}; //{{{
	~stills.set('kirk-face',(38*60+2.81));
	~names = [\tick,\talk,\foo,\bar];
	~names.do({|i|~stills.set(i,600.rand)});
	~secs=Pxrand (Array.series(Song.smallChamber.sections,0),inf).asStream;
(
		~names.do({|i| { 
			var nextSection = {var i=~secs.next; ({ Song.smallChamber.at(i).isNil }).while{i=~secs.next};i}.value;
			nextSection.postln;
			~stills.preview(i,5.rand,5.rand,0);
			Song.smallChamber.playSection(nextSection) }.defer(15.rand)
		});
)
	Song.currentSong.at(12)
//				SystemClock.sched(4,{{~stills.preview('kirk-face',wait:0.51,fade:2,monitor:0,text:['Sargon here','' ])}.defer});

~stills.set('lungs1',(12*60+53+4.5))
~stills.set('lungs2',(13*60+19.5))
~stills.set(\lungs3,13*60+32.5)
~stills.preview('lungs3',wait:3,fade:5)
(
	~stills.preview('lungs3',wait:9,fade:5);
	~stills.preview('lungs1',wait:6,fade:2);
	~stills.preview('lungs2',wait:3,fade:2);
)
	~stills.preview('lungs3',fade:3)


( // panel2
	~stills ?? {~stills=Stills("/Users/michael/tank/Trek/video for stills etc/media/return to tomorrow.mov")}; //{{{
	~stills.set('kirk-face',(38*60+2.81));
	//	Song.panel2 ?! Song.panel2.playSection(7); ~stills.preview('kirk-face',wait:4,fade:8,text:[ 'Lungs full of Air','Again' ]);
	// Still could have a Song and a Section (number) and method to play wit sound!
)
