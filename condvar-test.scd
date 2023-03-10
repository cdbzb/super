(
s.waitForBoot{ Stills("/Users/michael/trek/BySection/media/return to tomorrow.mov").current;
//Line 239 The three volunteers are lying on beds, with the spheres on tables beside them. 
Song( \condVar,[]).current;
// Trek.synful; ~syn1 = ~synful1; ~syn2 = ~synful2;


Song.bassBuss=Bus.audio;
["double and rising, Doctor...r  Hel- ", "d5 b-4 c#5 g c# a-4 g r b"].addLine; //2
\NNOOWW.postln;
c = P.synthV(\ninezero, take:\lead,
	wait:1,start: \rising,
	pbind: {|p b| 
		var here = P.calcStart('mo- ni');
		[
			dur: b ++ Song.durs[here + 1].list[0] => _.flat => _.q,
			midinote: p.tune[here].list ++ p.tune[here+1].list[0] =>_.flat => _.q
		].p
	},
	params: {|p b| [
	lyrics: "r r r r r r r r Hello +",
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
// P.double(\ninezero, params: {|p b| [
// 		
// 	] }, music:{|p b e|
// 		{
// 			e.playbuf
// 			=> p.synthVTracks.at(e.key).()
// 		}.play
// 	});
P.tune('Hel-');
P(\bassnotes3,start:'Hel-',music:
	(note:-2-12,amp:0.1)
);
P(\bassnotes4,start:'Hel-',syl:2,music:
	(note:[7,-5],amp:0.1,sustain:2)
);
["lo. r r r"," c#5 d2 d d"].addLine; //3
P(\helloImage,start:'lo. ',music:
	p{
		{
			a=Image.open("/Users/michael/tank/super/Spock.png");
			w=a.plot(freeOnClose:true).alwaysOnTop_(true);
			//w.alwaysOnTop_(true);
		}.defer(s.latency);
		{
			5.wait;
			{w.close}.defer;
		}.fork
	}
);
P(\helloChord,start:'lo. ',music:
	(instrument:\test,midinote:~panNotes.("<d4 f# a c#>").flatten,strum:0.03,amp:0.4)
);
~helloTempo={1/Song.durs['lo. r'].list.mean};
~helloTemp2={1/(Song.durs['lovely female'].list[0..6].sum/5*2)};
P(\helloSequence,start:'lo. ',music: {
	{
		var bus,clock,monitor,
		kickPatterns,kickBar,snarePatterns,snareBar,synth,helloBass2,helloBass1,helloBeat;
		bus=Bus.audio;clock=TempoClock.new;

		kickPatterns=[[3/4,1/4],1];
		p=[0,0,0,0,1,1,1,0]++[1,0,1];   ///XTENDED
		kickBar=Pseq(p.collect{|i|kickPatterns[i]}.flatten);

		snarePatterns=[[Rest(3/4),1/4],[Rest(1)],[Rest(1/2),1/2],[Rest(1/2),1/4,1/4],[Rest(1/4),1/4,1/2]];
		p=[0,1,2,0, 0,3,0,4]++[0,4,4];   ///XTENDED
		snareBar=Pseq(p.collect{|i|snarePatterns[i]}.flatten);

		synth= Pbind( 
			\note,Pseq([2-24,2-12,-1-12,9-12])-12,
			\instrument,\sawSynth,
			\dur,2,\rel,5,
			\amp,0.2) ;

			helloBass1=Pbind(
				\note, Pseq([2,4],4)-24,
				\legato,Pseq([1,Pwhite(0.25,0.55,1)],4),
				\amp,0.5
			) ;

			helloBass2=Pbind(
				\note,Pseq([\r,2,0],8),
				\dur,Pseq([1/2,1/4,1/4],inf),
				\amp,0.04
			) ;

			helloBeat= {
				|synthamp=0.3 drumsamp=1 tempo1=(52/60) tempo2=(50/60)|
				Ppar([
					Pbind(
						\tempo,Pseq([tempo1,tempo2]),\dur,4,\note,\r
					),
					Pbind(
						\instrument,\kick1,
						\dur,kickBar,
						\amp,drumsamp*0.1
					),
					Pfin(
						42, Pn( ///XTENDED
							Pbind(
								\instrument,\hihat, //ffreq rel
								//\dur,Pseq([0.245,0.255],32),
								\dur,Pseq([0.245,0.255],32),
								\amp,Pseq([Pwhite(0.3,0.4,1),Pwhite(0.2,0.3,1)],32)*0.4*drumsamp,
								\lag, Pseq( (1!16++(-1!16)).scramble*0.003),
								\ffreq, Pwhite(6000,6500),
								\rel,0.15
							) ,2
						)
					),
					Pbind(
						\instrument,\snare,
						\dur,snareBar,
						\amp,drumsamp*0.1
					),
					Pfx(
						Pbind( \instrument,\sawSynth,
							\note,Pser(~panNotes.("d f# a c#5 e5").flatten-60,16),
							\dur,1/2,
							\att,0.5,
							\octave,Pser(4!5++(5!5)++(6!5)++(7!5),42),
							\amp, Pseq(( 0.1!5 )++(0.09!5)++(0.08!5)++Pseries(0.07,-0.005))
						).pad,
						\phase_verb2
					),
					//~helloBass1,
					//~helloBass2,
					Pset(\amp,synthamp,synth),
					//Pseq([(\type:\rest,dur:4),~complete.pbind[4]]);//remove
					//	Ptpar([
					//		0.15,~helloGtr1,
					//		0.15,~helloGtr2
					//	])
				],1   /// repeats!!
			)<>(out:bus)
		};
		'self bus '.post;bus.postln;
		Song.helloSequenceBus = bus;
		Song.helloSequenceMonitor = Monitor.new.play(bus.index,2,0);
		{ s.bind {helloBeat.(synthamp:0.1,drumsamp:0.7,tempo1:~helloTempo.(),tempo2:~helloTemp2.()).play(clock)} };
	}.play
});
["live. Unless the formula works, we can't risk it again.", [11.5,11,5,3,11,7,6,7].dm('e-') ++ [5,5,11,5,3,1].dm('f#',scale:\minor) ].addLine;
P.tune('risk it');
P.tune('risk it ',{|i| i.drop(1) => Pbindf(_,\instrument,\sawSynth,)=>Pmul(\freq,0.5,_)},syl:0);
P(\reedPedalRisk,start:'risk it',music:{|p b|

	[release:5,sustain:1,amp:0.01!2,out:3, freqLag:1,instrument:\reedy,
		freq:[ \r,[6, 11 ],[5,11],[5.5,7] ].df('b-',3).q,
		dur:p.parse('risk it',[4,3,3,4])+[0,0,0,5]=>_.q ].pm(\reedy).play
	}
);
//MUTEDP(\dingRisk,start:'risk it',syl:0,music: {|p b|
//MUTED{Array.fill(50,{500.pareto(2)})=>FSinOsc.ar(_,0,0.01* Env.perc(0,3).kr(2,gate:1))=>Mix.ar(_)}.play
//MUTED}
//MUTED);
P(\highChords,start:'risk it',music:{|p b|
	[
		freq: [[5,11,13].df('e',tuning:\sept1),[5,11,13].df('e-',tuning:\sept1),[11,13,15].df('b-',octave:4,tuning:\sept1),[3,5,11].df('f#',scale:\minor,tuning:\sept1)] .q,
		amp:0.06,
		dur:p.parse('risk it',[1,6,3,4]).q,
		freqLag:1,
		width:40,
		mix:0,

	].pm(\stringyy)
	.play
});

 })

