a=Scale.new((0..8),pitchesPerOctave:9);
Scale.all.put(\nineNote,a)
a.semitones
[note:a.semitones.q+[0,3],legato:3].pp
(
b=Effect(FreeVerb.ar(_,0.9,1),out:1).bus.index;
b=Effect({|i|PlateReverb.ar(i,0.8,mix:Line.kr(0.5,1,30),decayTime:0.7*Gendy1.kr(minfreq:1/10,maxfreq:2).unipolar)[0]},inputChannels:2).bus.index;
	[
	degree:
	Ptuple([
	( 40..57 ).q(inf) + 5.rand
	,( 40..56 ).q(inf) + 5.rand, (40..60).q(inf) ])
	,
	root:[0,3,6],scale:a,dur:0.05,legato:1,
	out:b+Pwhite(0,1)
] .p.play;
[dur:0.3,scale:a,out:b,degree:( 0..8 ).q(inf),legato:[3,0.5,0.5].q(inf)*2.2].pp;
(degree:[0,2,4],scale:Scale.whole,root:9,dur:20).play
)

