(
	~iWanted=Song(\iWanted,[
		"I want- ed to be cer- tain there was no", "d-5 c d- f d- c b-4 a- b- e-5" , //0
		" e- rror, for- mu- la- is corr- " , "d5 f4 g a b g b", //1
		"ect don't be con- cerned- -- -- this is an ", "d5 c# e d f# g f# d e f#", //2
		"ex- ce- llent bo- dy","g# e d d c#", //3
		"there I feel be- tter al- rea- dy. In","c5 g4 a b  a b d5 c b4",//4
	]);
//~recorder.(~iWanted,4,2)
)


~iWanted.durs[0].list
~iWanted.play
~iWanted.pbind[0].play
~iWanted.guide0=Part(start:0,music:~iWanted.pbind[0])
~iWanted.play(\guide0)
s.latency=0.9
(
	~iWanted.bass1=Part(start:0, syl:7, music:
		(amp:0.4,degree:7,root:1,octave:[3,2],sus:2)
	);
	~iWanted.bass1=Part(start:0, syl:1, music:
		(amp:0.4,degree:0,root:1,octave:[3,2],sus:2)
	);
	
	~iWanted.bass2=Part(start:0, syl:2, music:
		(amp:0.4,degree:2,root:1,octave:[3,2],sus:2)
	);
	~iWanted.bass3=Part(start:0, syl:3, music:
		(amp:0.4,degree:3,root:1,octave:[3,2],sus:2)
	);
	~iWanted.bass4=Part(start:0, syl:4, music:
		(amp:0.4,degree:4,root:1,octave:[3,2],sus:2)
	);
	~iWanted.bass6=Part(start:0, syl:6, music:
		(amp:0.4,degree:6,root:1,octave:[3,2],sus:2)
	);
	~iWanted.bass5=Part(start:0, syl:5, music:
		(amp:0.4,degree:5,root:1,octave:[3,2],sus:2)
	);
	~iWanted.bass0=Part(start:0, syl:0, music:
		(amp:0.4,degree:0,root:1,octave:[3,2],sus:2)
	);
	~iWanted.syl=Part(start:0,music:[dur:~iWanted.durs[0],note:22].p);
~iWanted.play;
~iWanted.durTill(0,5);
~iWanted.durs[0].list[0..5].sum;
)
(

	SynthDef(\phph,{|in|
		var sig=In.ar(in);
		sig=Phaser2.ar(sig,rate:0.2);
		Out.ar(0,sig)
	}).add;

	~iWanted.chords0=Part(
		start:0,
		music:{
			var pat = ~iWanted.durs[0].list[..4].postln;
			var bus = Bus.audio;
			Synth(\phph,[in:bus.index]);
			Ppar(
				[
					[
						out:bus.index,
						dur:pat.q,
						root: 1,
						degree:[5,1]-1,
						octave:4
					].p,
					[
						out:bus.index,
						dur:pat.q,
						root:1,
						degree:[7,6,7,6,7].q,
						octave:4
					].p,
				]
			).play;
		}
	)
)

