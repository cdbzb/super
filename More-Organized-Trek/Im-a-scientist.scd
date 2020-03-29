//s.reboot
p=PF.new

( //cool tinkling pattern
	[
		dur:0.5,
		degree:([4,6-7,1,3,5-7,1,3,5-7] ++[3,5-7,1,2,5-7,7-7,2,5-7,2]).q-1,
		legato:[3,3,3,3,3,3,2,2].q(2),
		pan:Pwhite(-1,1)
	].p
	=>Pn(_,2)
	//=>Effect.new(_,\phaserr2)=>_.play
	=>Pfx(_,\phaserr2)
	=>_.play
)
( //faster: Pdef(\keys)
	[ dur:0.5/2,
		degree:([4,6-7,1,3,5-7,1,3,5-7] ++[3,5-7,1,2,5-7,7-7,2,5-7,2]).q-1,
		legato:[3,3,3,3,3,3,2,2].q(2),
		pan:Pwhite(-1,1),
		amp:0.2,
		octave:[3,4]+2,
		root:11,
	].p
	=>Pn(_,39)
	//=>Effect.new(_,\phaserr2)=>_.play
	//=>Pfxb(_,\phaserr2)
	=>Pfx(_,\phaserr2)
	//=>_.play;
	=>Pdef(\keys,_);

	Pdef(\keys).play
)
	Pdef(\keys).play(t).quant=8;
	//Pdef(\keys).stop
(
	Pdef(\port,
		PmonoArtic(*[
			\sawSynth,
			legato:1,//[1,1,1,4].q,
			rel:8,
			att:1.5,
			dur:[1,1,1,4].q,
			degree:[5-7,1,5,4].q-1,
			root:11,
			amp:1
		])
);
	Pdef(\port).quant_(8).phase_(0) .play(t)

)
(// drummachine //		{{{1
	//	drums	{{{4
	~pat={|string perBar repeats| string.asDrumPat(perBar,repeats)};

	Pdef.new(\f,Pbind(*[
		instrument:\kick,
		amp:1,
		dur:~pat.("x0x0|x0x0|xx0x|xxxx",4,inf),
		//tempo:Pwhite(0.59,1.11,inf)
	]));
	SynthDef(\fb,
		{|out=1 |
			XOut.ar(out,0.3,
				FreeVerb.ar(In.ar(out,2),1.0,0.9)*1.2
			)
		}
	).add;
	SynthDef(\plate,
		{|out wet=1 |
			var in=In.ar(out);
			var sig = PlateReverb.ar(in);
			XOut.ar(out, wet, sig)
		}
	).add;
	SynthDef(\phaserr2,
		{| in out=0 rate=0.1 fb=0.3|
			var sig = Phaser2.ar(In.ar(in,2),rate:rate,fb:fb);
			XOut.ar(out, 1, sig)
		}
	).add;
	SynthDef(\phaserr,
		{|out rate=0.1 fb=0.3|
			var sig = Phaser2.ar(In.ar(out,2),rate:rate,fb:fb);
			XOut.ar(out, 1, sig)}
			).add;
			SynthDef(\dst,
				{|out gain=1.5|
					var in=In.ar(out);
					var sig = ( in*gain ).distort;
					XOut.ar(out, 1, sig!2)}
				).add;
				Pdef.new(\q,
					Pfxb(
						Pbind(*[
							instrument:\snare,
							dur:~pat.("0000x000|0000x000|0000x00x|0000x00x",8,inf),
							amp:0.2
						]),
						//\fb
						//\phaserr
						\dst
					));
					a=Pdef.new(\h,
						Pbind(*[
							instrument:\hihat,
							amp:Pseq([0.1,0.2],inf*Pwhite(1,1.2,inf)),
							//lag:Pseq([0,0.008],inf),
							dur:~pat.("xxxx",08,16)]));//.play
							a.quant=1;
							b=Pdef(\m,Pfxb(a,\phaserr,\fb,-0.99));
							c=Pseq([a,b],inf);

							// 'guitar-ish' //		{{{4

							~synthsLoaded ?? {"~/tank/super/song-Synthdefs.scd".standardizePath.load};
							~synthsLoaded=nil;

							SynthDef(\pluckD,{|freq=400 amp=1|
								var sig= Pluck.ar(
									WhiteNoise.ar(0.1),
									trig: \trig.tr(1),
									maxdelaytime: 0.2,
									delaytime: freq.reciprocal,
									decaytime: \del.kr(5),
									coef: \coef.kr(0.6)
								) ;
								sig=CrossoverDistortion.ar(sig,\drive.kr(0.9),\smooth.kr(0.1));
								sig=Phaser2.ar(sig,0.5,0.15,rq:1);
								Out.ar(\out.ir, sig*amp);
							}).add;

							Pdef(\a,Pfindur (16,Pmono(\pluckD,
								///or is the minor third better!!!
								\root,-1,
								\degree, 8.dup(8)++2.1.dup(4)++5.dup(4)=>_.flatten=>_.q(inf)-1,
								\octave,2,
								\out,[0,1],
								\smooth,Pwhite(0.2,0.3,inf),
								\del,Pwhite(0.5,1,inf),
								\dur,0.25,
								\coef,Pbrown(0.1,0.9,0.03),
								\lag,Pwhite(-0.01,0.01)
							)));
							//Pdef(\a).play

							[
								degree:[3,4,6,5,7,3,4,6,5,8].q-1,
								root:-1,
								dur: [1.dup(4)++4].flatten.q(12)/4,
								octave:4,
								amp:0.3
							].p
							=> Pdef (\lick,_);

							//.play;

							Pdef(\boodoo,Pbind(*[
								//instrument:\sawSynth,
								att:0,
								degree:Pseq([1,2,3,5,4,2,1],inf)-1,
								dur:Pseq([1,1,1,1,8,8,12]/4,inf),
								root:7,
								octave:2,
								amp:0.6
							])).quant([16,7])
							;
							//Pdef(\boodoo).play
							t=TempoClock.new.tempo_(88.bpm).permanent_(true);
							t.tempo_(45.bpm);

							//p=PF.new;
							Ptpar([ //		{{{4
								0,Pdef(\m),
								//2,Pdef(\lick),
								0,Pdef(\q),
								0,c,
								0,Pdef(\f),
								0,Pwrand([Pdef(\a),(note:Rest,dur:8)],[0.7,0.3],inf), //guitar
								//Pseq([(note:Rest,dur:7+16),Pdef(\boodoo)]),
							]
						)
						.play(t)
)

(
	~jank={ |degree=1 amp=1|
		var b= Bus.audio(s,1);
		var j=List.new;
		var e={
			In.ar(b.index,1)
			=>(CombN.ar(_,1,(t.tempo).reciprocal/1,4)
			+Gain.ar(_,1!2))
			* Env.cutoff(1).kr(2,gate:\gate.kr(1))*0.1*amp 
		}.play(s,[0,1].choose,addAction:\addToTail);

		//[3,6]
		[3,4] .do { |o| 
			j.add(Synth( \pluckD,
				[
					\out,b.index,
					\freq, [degree].degreescps(octave:o-1,root:-1) .flatten,
					\coef,0.8,
					\del,0.7,
					\smooth,0.25
				]
			))
		};
			t.sched(1.3,{j.do(_.free)});
			t.sched(4.2,{e.release});
			j;
	};
	//t.tempo
	//~jank.()
	
		//t ?? {t=TempoClock.new(queueSize:1024).tempo_(110.bpm).permanent_(true)};
		t ?? {t=Sequence.new};

		~lick = { r{
			var a;
			~notes= [3,4,6,5,7,3,4,6,5,11].degreescps(root:-1,octave:4);
			~durPat=[1,1,1,1,4];
			~durs=~durPat .q(inf).asStream;
			t.sched(~durPat.sum*2+1,
				{a.release});
				t.sched(~durPat[0..3].sum, 
				{a.set(\dmod,1)});
				a={          
					var gate=\gate.kr(1);
					var sink= Env.asr(0.1,1,5).kr(2,gate:gate);
					var pulse = [0,Env.perc(0.01,0.23).kr(0,gate:\pulse.tr(0))].choose;
					//'trigger rate'.help
					Saw.ar(\freq.kr(~notes[0],0.5),0.1)
					* (Env.asr(0.1,1,2).kr(0,gate:gate) + pulse) 
					=> (
						CombC.ar(_,1,
							\dmod.kr(0,3)*SinOsc.kr(2).range(-0.002,0.002)+0.2,
							decaytime:10
						)*0.4
						+ Gain.ar(_,0.8)
					)
					=> Splay.ar(_).distort
				}.play(s,0);
				s.sync;
				a.set(\gate,1);
				~notes.do{|i|a.set(\freq,i);a.set(\pulse,1);~durs.next.wait};
			}};

		{3.do{~lick.value.play(t);16.wait;}}.fork(t);
		r{3.do{4.wait;~jank.(7,amp:0.4);8.wait;~jank.(11,amp:0.4);4.wait}}.play(t);
)

(
	//t.tempo=(85.bpm)
	~tune=
	[
		(//0
			tune:[11,7,11,12,11,3],
			dur:[1,1/2,1/2,1,1/2,3/2],
		),(//1
			tune:[5,15,14,13],
			dur:[1,1,3,2],
		),(//2
			tune:[11,13,12],
			dur:[1,3,2]
		),(//3
			tune:[11,14,13],
			dur:[1,3,2]
		),(
			tune:[5,13,12],
			dur:[1,3,2]
		)
	].do{|i|i.dur=[1]++i.dur};
	//pad head with 1

	//play a tune
	~r={|startAt=10 tune amp| r{
		var synth;
		synth=Array.new(tune.tune.size+1);
		(startAt-tune.dur[1]).wait;
		tune.tune.do{|i x| 
			t.sched(
				tune.dur[0..(x)].sum,
				{synth.add(Synth(\default,[\amp,amp,\freq,[i].degreescps(root:11,octave:4)]))});
				t.sched(
					tune.dur[0..x].sum+tune.dur[x],
					{synth[x].release(2)});
				}
			}
		};

		//play the tunes
		[10,26,35,43,51].do{|i x|~r.(i,~tune[x],amp:0.15).play(t)};

		{~lick.value.play(t)}.sched([0,16],t);

		{
			{~jank.(11,amp:0.4)}.sched(12,clock:t);
			{~jank.(7,amp:0.4)}.sched(4,clock:t);
		}.sched(Array.series(2,0,16),t);

		{ Synth(\cymbal,[\amp,1,\length,4]) }.sched(28,t);

		{{Impulse.ar(t.tempo)*0.4=>MembraneHexagon.ar(_,0.2)}.play}.sched(28,t);
		{{Impulse.ar(t.tempo/2)=>Decay.ar(_)*PinkNoise.ar(0.08)=>MembraneHexagon.ar(_,0.0045)}.play(s,2)}.sched(28,t);

		SynthDef(\pluckD,{|freq=400 amp=1|
			var sig= Pluck.ar(
				WhiteNoise.ar(0.1),
				trig: \trig.tr(1),
				maxdelaytime: 0.2,
				delaytime: freq.reciprocal,
				decaytime: \del.kr(5),
				coef: \coef.kr(0.6)
			) ;
			sig=CrossoverDistortion.ar(sig,\drive.kr(0.9),\smooth.kr(0.1));
			sig=Phaser2.ar(sig,0.5,0.15,rq:1);
			Out.ar(\out.ir, sig*amp);
		}).add;
		SynthDef (\cymbal, {|amp=1 length=2| //{{{
			var sig=PinkNoise.ar(EnvGen.kr(Env.perc(0,length)))!2;
			sig=TwoTube.ar(RHPF.ar(sig,500,9),d1length:502,d2length:777,loss:0.99)*0.5;
			DetectSilence.ar(sig,doneAction:2);
			Out.ar(0,sig*amp)}
		).add; //}}}

		{
			var  a="..x.|..xx".asDrumPat(1,inf).asStream;
			{
				a.next.isNumber.if({Synth(\snare,[\amp,0.15])})
			}
			.sched(Array.series(60),t)
		}.sched(8,t);


		{
			[11,11,3,5].do{|i x| {~jank.(i,amp:0.4)}.sched(x*4+(0..3),t)}
		}.sched([28,44],t);
	)

	"~/tank/super/song-Synthdefs.scd".standardizePath.load;

	a=Synth.basicNew('',s,nodeID:( (a:1,dur:5).play.id[0]))
	a.set(\freq,900)
	// .synth method??
	(a:1).synth


	Synth(\default).dur(5)
	a=Object.new.dur(3)
	a=Object.new.dur(3)

	Part()

	a=Song.new(\default,["a","e5"]).setupDurs
	a.durs
	Song.songs[\default].durs[0].list
	~bars = 1.dup(4).dup(4)
	a.durs=Pseq(1!4)!4
	a.bar1=Part(start:0,music:(note:[1,2,3]))
	a.bar2=Part(start:1,music:(note:[1,2,3]+9))
	a.play
	TempoClock.queue
	t.tempo_(0.00001)
	t.beats
	t=TempoClock.new.tempo_(88.bpm)
	t.sched(100,{1.postln})
	t.beats_(-10)
	t.beats
	t.queue
	

