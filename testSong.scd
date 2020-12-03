(
Song.new(\foo,[]);
Song.foo.current;
["pokj na n nmn","d e d",[1,1,1]/4].addLine;
P(\tune2,start:'pokj',music:Song.pbind[ 'pokj']
);
["interstice","r",[5,4,3]/3].addLine;
P(\chords_int,start:\interstice,music:[
	freq: [[1,3,4,6,11],[1,4,5,7,12],[1,2,4.5,11,13]].df('b').q,
	dur: Song.durs[\inters],
	legato: [1,1,3].q
].p
);
["number2","r",[20]].addLine;
P(\boigle,start:'number',music: {
	{(SinOsc.ar(3.rand+1*[300,400,450]*Pulse.kr(LFBrownNoise1.kr(1).range(1,2.12)))*1000)>>Saw.ar(Saw.kr([0.1,0.11]).range(100>>Pulse.kr(1/5).unipolar,1000)).range(0,6)/1000=>CombC.ar(_,1,1,5)*Env.linen(0,17,5,0.2).kr(1,2)}.play(s,0)
}
);
["as as as","c d e"].addLine;
P(\tune,start:'as as',music: Song.pbind[ 'as as' ]);

)
Song.durs[0].list
Song.currentSong.hasDursButNotLyricsToDurs.if{1}
Archive.at(\fooOuter).isNil.if{1}

Archive.at(\fooOuter)[Song.sections]
(
Song.new(\fooOuter,[]);
Song.fooOuter.current;
["chatter mm ","r",[7]].addLine;
P(\racket,start:\chatter,music:{
	{
		var dur=Song.secDur[\chatter];
		n= NodeProxy.audio(s,2).fadeTime_(6).source_({PinkNoise.ar(0.1)});
		n.play(1);
		5.do{ TempoClock.sched(10.0.rand,{n.source_({{[WhiteNoise.ar(0.1)=>HPF(_,1000),BrownNoise.ar(0.01),PinkNoise.ar(0.1)].choose}})}) };
		fork{dur.wait;n.free(fadeTime:10)};
	}.value
});
["insert","r",Song.foo.secDur.array].addLine;
P(\songgg,start:\insert,music:{Song.foo.current;Song.foo.play});
["more noise","r"].addLine;
P(\reprise,start:'more noise',music:{Song.fooOuter.current;
	Song.fooOuter.resources.racket.play;
	8.do{(note:rrand(0,1.0),dur:3).play}
})
)
Song.secDur.array
Song.foo.current;Song.secDur.array
a=Song.secDur[ "chatter" ]
Song.fooOuter.secDur.song.key
Song.foo.secDur.song.key
Song.foo.secDur.array
Song.fooOuter.secDur.array
Song.foo.current;
[\insert]
Song.fooOuter.secDur[\insert]
Song.foo.lyrics
Song.fooOuter.lyrics
secDur.array
Song.fooOuter.secDur.array
Song.foo
Song.play
8>>1
Song.durs[\inters]
~recorder.(Song.currentSong,[1],1)
Song.tune
Song.currentSong.areThereDursButNotLyricsToDurs
Song.pbind
Song.lyricsToDurs
Archive.at(\foolyricsToDurs)
Song.foo.areThereDursButNotLyricsToDurs
Song.durs[..1].collect{|i|i}

Song.durs.copySeries(0,1,1)
Song.durs[0].list
Song.durs[1].list
Song.secDur[0..1]

