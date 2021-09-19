
"~/Desktop/test/*.RPP".standardizePath.unixCmd("open -a Reaper.app ")
// make this a method of Item !!!

Reaper.open2("/Users/michael/Desktop/test/test.RPP")
a="/Users/michael/Desktop/test/media/*PROX".pathMatch
Pipe("cp " + a[0] + a[0] ++ ".wav","w")
b=Buffer.read(s,a[0]++".wav")


"rpr " + ~wavFileName + "-saveas "
//use this to record the section guide!!
(
var path="/tmp/test.wav";
var section = 7;
fork{
	s.prepareForRecord(path);
	0.1.wait;
	Song.cursor_(section);Song.currentSong.play(Song.at(section));
	s.record(duration:10);
	10.wait;
	c=Buffer.read(s, path);
	//path => Reaper.open2(_)
	Reaper.openAndSaveas(path++".RPP")
};

d=Buffer.read(s, "/tmp/media/*PROX".pathMatch[0]);
d.play;Song.play
/*
c.play
*/
//need to add the saveas
Reaper.open2("/tmp/test.wav.RPP")
)







fork{
	6.do{
		{PlayBuf.ar(1,b.bufnum,rate:rrand(0.9,1.1)) => Pan2.ar(_,Gendy4.kr(0.11).range(-1,1))}.play;
		0.1.rand.wait;
	}
}
