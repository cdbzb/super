(
Song(\trashme,[]).current;
["test it out",[1,3,5,4,3,4,2,3].dm(\c)].addLine;
P.tune(\test);

Song.currentSong.resources.put(\a,
	VocalRPP(\test,\firstTry)//.build
);
// P.put !!!!!
P(\string,start:\test,music:{|p b e| 
	[
		instrument:\stringyy,
		degree:Pwhite(1,20,inf),
		dur:Pwhite(0.1,1,inf),
		legato:4,
		amp:0.4,
		attack:3

	].p.fin(10).play
});
P(\junk,start:\test,music:
	{|p b e| 
		{
			//RPP
			PlayBuf.ar(1,p.a.buffer.bufnum,rate:1.01) 
			=> TwoTube.ar(
				_,
				loss:0.95,
				d1length:{ rrand(400,1600)}!2,
				d2length:555
			)
			=>HPF.ar(_,2200)
		}
		.play
	});
)
Song.currentSong.pts.select{|p| p.music.cs.contains("RPP")}
a.checkDursChanged
a=VocalRPP(\test,\firstTry)
a.open

Object.readArchive(a.mediaFolder +/+ a.key.asString ++"_durs")
Song.durs[\test].list
a.section
.list
a.writeReaperAction
a.copyPROXtowav
b=Buffer.read(s,a.wav);
Song.durs[\test].list
b.play
a.mediaFolder
a.buffer.play

File.mtime(a.wav) 
File.mtime(a.prox) 
