(
s.waitForBoot{
	Stills("/Users/michael/trek/BySection/media/return to tomorrow.mov").current;

	Song(\vidTest,[]).current;
	["firstLine","r"].addLine;
	P('note',start:\firstLine,music: {|p b e|
		().play
	});
	
	[ "test!","r",[1,1] ].addLine;
	P.still(\ok,\test,syl:0,timecode:88,music:{ |p b e|
		e.still.value(
			wait:1
		);
	});
	P('note',start:\test,syl:0,music: {|p b e|
		().play
	});
	["another line","r"].addLine
}

)
