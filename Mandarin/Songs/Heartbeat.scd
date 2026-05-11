(
Song(\another, []).current;
["短 短 短 短 长", "3 2 1 -7 5".dm(\f, 4), "e e e e eeee".beats].addLine;
P.synthV(\an, take: \lead, params: {|p b| [
	lyrics: " 微 风 轻 轻 吹， ",
	pitchTake: 1,
	legato: [1, 1 ,1, 1, 0.8],
	language: \Mandarin
] }, music:{|p b e|
	{
		e.playbuf
		// => p.synthVTracks.at(e.key).()
	}.play
});
["line2 ","6 5 3 4 11 12".dm(\f, 4), "e e e e eee e".beats].addLine;
P.synthV(\an, take: \lead, 
	pbind: Song.enlarge(5),
	params: {|p b| [
	lyrics: "你 眼 神 在 徘 徊 星 光 洒 下 来 ",
	lag: [0.02, 0, 0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ],
	pitchTake: 3,
	language: \Mandarin
] }, music:{|p b e|
	{
		e.playbuf
		// => p.synthVTracks.at(e.key).()
	}.play
});
["Line 3", "13 12 11 7 6.7".dm(\f, 4), "e e e e eeee".beats].addLine;
P.synthV(\an, take: \lead, params: {|p b| [
	lyrics: "星 光 洒 下 来 ",
	pitchTake: 1, 
	language: \Mandarin
] }, music:{|p b e|
	{
		e.playbuf
		// => p.synthVTracks.at(e.key).()
	}//.play
});

)
