	~captureVelocity={
		~velocity=List.new;
		MIDIFunc.noteOn({ |velocity note | ~velocity.add(velocity)})
	};
	~captureVelocity.();
	a=~velocity[0,2..];

( ~international =Song(\int,[
		'wake up ye victims of oppression for the',[5, 11,7,12,11,5,3,6,4,12,11].dm(),
		' tyrants fear your might dont cling',[7,7,6,5,5].dm() ++ [5].dm(\d),
		'cling so hard to your poseesions you have',[11,7,12,11,5,3,6,4,12,11].dm(\d),
		'nothing if not your rights',[7,7,12,14,7,11].dm(\d) ++ [12,11].dm(),
		'(not if not your rights)',[7,12,6,7,11].dm(),
		'(ding ding)',[15,21].dm()
	]).setupDurs;
	//cool things to do to day
	//make ex touch play item
	//it would be great if we could do interpret block but it cant
	//add lower and upper to vim arrows
	//sort out split and window movement
	//get recorder next working

	//	~recorder.(~international,0,1)
	~international.current;
	~international.bass0= Part(start:0, syl:0,music:[ //{{{
		freq:[1,3,4,3,2].df(octave:3).q,
		dur:
		~international.parse(0,[2,4,0.5,0.5,2],1).q
		,
	].p,);//}}}
	~international.bass1=(start:1,music:[
		freq:[7,6,5,4].df(\e,3).q,
		dur:~international.parse(1,[2,2,4/7,[3/7,1]]).q,
	].p);
	~international.bass2= Part(start:2, music:[ //{{{
		freq:[1,3,4,3,2,1].df(\d,octave:3).q,
		dur: ~international.parse(2,[2,4,0.5,0.5,1,1],0).q ,
	].p,);//}}}
	~international.echoBus=Bus.audio;
	~international.passingFigure1=(start:1,syl:3,music:[
		instrument:\tri,
		freq:[Rest()].q++[14,13,12,11].df(\d).q,
//		freq:[Rest()].q++[14,13,12,11].df(\d).q,
		dur:~international.parse(1,[2/7,2/7,2/7,[ 1/7,1 ]],4).q
			++~international.parse(2,[2]).q
		,
	].p);
	~international.passingFigureHarmony=(start:1,syl:3,music:[
		instrument:\tri,
		freq:[Rest()].q++[12,11,7,[3, 5 ]].df(\d).q,
		out:1,
		amp:0.05,
//		freq:[Rest()].q++[14,13,12,11].df(\d).q,
		dur:~international.parse(1,[2/7,2/7,2/7,[ 1/7,1 ]],4).q
			++~international.parse(2,[2]).q
		,
	].p);


	~international.eighthNotes=~international.parse(0,[1/3,1/3,1/3,1,1,1,1,1,1/4,1/4,1/4,1/4,1/2,1/2,1,1],1);
	~international.eighthNotes2=~international.parse(2,[1/3,1/3,1/3,1,1,1,1,1,1/4,1/4,1/4,1/4,1/2,1/2,1,1],0);
	~international.offbeats=~international.eighthNotes[1,3..];
	~international.shaker0=(start:0,syl:0,music:[
		dur:~international.eighthNotes.q,
		freq:[Rest(),Rest(),1.df,Rest()].q(inf),
		instrument:\timpany,
		amp:0.14,
		tension:0.1,
		//hexagon might be better
	].p);
	~international.finalLick4=(start:5,lag:-0.78,music:[
		freq:[5,11].df().q,
		instrument:\tri,
		portamentoTime:0,
		dur:~international.parse(5,[1,1]).q,
	].p);
	~international.arpeggio3=(start:3,syl:4,music:[
		instrument:\pluckD,
		drive:0,
		legato:3,
		amp:1.6,
		freq:[1,3,5].df(\d,scale:\minor).q,
		dur:
			~international.parse(3,[1],5).q(3)/3
//			~international.durs[3].list.do(_.postln)
	].p);
	~international.arpeggio4=(start:4,music:[
		instrument:\pluckD,
		drive:0,
		legato:3,
		amp:1.6,
		freq:[1,3,5].df(\g).q,
		dur:
			~international.parse(4,[2/3,[1/3,1],2]).q
//			~international.durs[3].list.do(_.postln)
	].p);
	~international.endingAllTune4=(start:4,music:[
		instrument:\stringyy,
		freq:[7,12,14,7,11].df().q,
		dur:~international.parse(4,[1,1,1,1,1]).q,
	].p);
	~international.bass4=(start:4,syl:3,music:[
		legato:[ 2.0,2.0,3.0 ],
		freq:[1,5,13].df(\c,3).q,
		dur:~international.parse(4,[1/4,1/4,1/4,1/4],4).q,
	].p);
	~international.bass3=(start:3,music:[
		freq:[[7, 6 ],5].df(\d,3,scale:\harmonicMinor).q
			++ [15].df(\c,2).q
		,
		dur:~international.parse(3,[5,3]).q
			++ ~international.parse(4,[4]).q
		,
	].p);
	~international.chords3=(start:3,music:[
		freq:[[ 6,7,12 ],[5,11,13]].df(\d,scale:\harmonicMinor).q 
		/2
		,
		dur:~international.parse(3,[5,1]).q,
		instrument:\stringyy,
	].p);
	~international.shaker2=(start:2,music:[
		out:1,
		amp:0.14,
		dur:~international.eighthNotes2.q,
		freq:[Rest(),Rest(),1.df,Rest()].q(inf),
		instrument:\timpany,
		tension:0.1 * 2.midiratio,
		//hexagon might be better
	].p);
	~international.drumAccent2=(start:2,music:(instrument:\timpany,tension:0.01*6/5 * 5/7,loss:0.99992,amp:0.05 ));
	SynthDef(\timpany,{ //{{{
		MembraneCircle.ar( PinkNoise.ar(0.1) * Env.perc().ar(0,gate:\tgate.tr(1)),\tension.kr(0.01),\loss.kr(0.9999) )
		=>LeakDC.ar(_)
		* Env.cutoff(5).kr(2,gate:\gate.kr(1))
		* \amp.kr(0.1)
		=>Out.ar(\out.kr(1),_)
	}).add;//}}}
	~international.addGuides("xxxxx.");
	~international.contains("guide").do{|i| i.music=Pbindf(i.music,\instrument,\sawzz,\out,[0,1]) };
	~international.chords1=(start:1,music:[ //{{{
		//	strum:0.07,
		freq:[ 
			[3,5,10].df(\b),[3,5,10].df(\a),[5,10,3].df(\e,scale:\minor),[1,3,5,7].df(\a,scale:\mixolydian) ,
			[5,10,13].df(\d)
		].q/4 ,
		dur:~international.parse(1,[2,2,4/7,[3/7,1]]).q ++ ~international.parse(2,[2]).q,
		instrument:\stringyy,
	].p.trace);//}}}

	~international.velocities0= List[ 46, 83, 63, 65, 72, 63, 51, 57, 73, 48, 64, 69 ];
//	[midinote:~international.tune[0],dur:~international.durs[0],amp:~international.velocities0.q/200].pp;

	//	~international.tune=(start:0,lag:-0.0,music: //{{{
	//		Pmono(*[
	//		//	instrument: 
	//			\stairs,
	//			amp:0.005,
	//			portamentoTime:1,
	//			step:0.25,
	//			out:[~international.echoBus.index, 1 ],
	//	//		tempo:0.6,
	//			freq:	~international.tune[0..3].q,
	//			dur: ~international.durs[0..3].q,
	//	//		TempoClock.tempo_(1)
	//		])
	//	);//}}}

	~international.echo=(start:0,music://{{{
		{
			{In.ar(~international.echoBus.index)=>CombN.ar(_,0.3,0.3,3)=>Out.ar(0,_)}.play(addAction:\addToTail);
		}
	);//}}}
	//~recorder.(~international,0,1);
	~international.current;
	{ //Dan Stowall Cymbals{{{
		var lodriver, locutoffenv, hidriver, hicutoffenv, freqs, res, thwack;
		locutoffenv = EnvGen.ar(Env.perc(0.5, 5)) * 20000 + 10;
		lodriver = LPF.ar(WhiteNoise.ar(0.1), locutoffenv);
		hicutoffenv = (EnvGen.ar(Env.perc(1, 3))).range(10000,1);
		hidriver = HPF.ar(WhiteNoise.ar(0.1), hicutoffenv)
		* EnvGen.ar(Env.perc(1, 1, 0.25));
		thwack = EnvGen.ar(Env.perc(\att.kr(0.001),0.0001,1));
		freqs  = {exprand(300, 20000)}.dup(30);
		res	= Ringz.ar(lodriver + hidriver + thwack, freqs).mean;
		((res * 1) + (lodriver * 2) + thwack).dup * \amp.kr(0.1)
		=> ( Out.ar(\out.ir,_) <! DetectSilence.ar(_,doneAction:2))
	}=>SynthDef(\cymbalsDS,_)=>_.add; //}}}
//	Synths(\tri,\freq, [1,3,5].df(octave:6) ).dur(2)

	SynthDef(\tri,{ //{{{
		var sig=DPW3Tri.ar(\freq.kr(300,\port.kr(0))) * \amp.kr(0.1).distort
		* Env.asr(\attack.kr( 0.05 ),1,2).kr(0,gate:\gate.kr(1))
		=> FreeVerb.ar(_,0.7,1);
		Out.ar (\out.kr(1),sig);
		DetectSilence.ar(sig,0.001,doneAction:2)
	}).add; //}}}
	SynthDef(\basepluck,{
		Pulse.ar(\freq.kr(400),\width.kr(0.2))
		* Env.perc(0,2.5,\amp.kr(0.1),curve:3).kr(2)
		=>MoogFF.ar(_,4000,2)
		=>Pan2.ar(_,0)
		=>Out.ar(\out.ir(0),_)
	}).add;
	SynthDef(\sawzz2,{ //{{{
		Saw.ar(\freq.kr(400,0.5)+( Rand(-4,4.0!2)++[0] ),\amp.kr(0.1))
		//Saw.ar(\freq.kr(400,0.5)+Rand(4.0!3),\amp.kr(0.1))
		=>MoogFF.ar(_,\cutoff.kr(800,\fLag.kr(1)),\res.kr(3))
		* Env.asr(\att.kr(0.2),1,3).kr(2,gate:\gate.kr(1))
		=> Splay.ar(_)
		=>Out.ar(\out.kr(0),_)
	}).add;
	SynthDef(\argybargy,{|freq=400 width=10 out=1| //{{{
		Gendy1.ar(minfreq:freq-width,maxfreq:freq+width)
		=>( CombN.ar(_,0.4,0.11,2)+Gain.ar(_,0 ) )
		* Env.asr(0.05,1,\rel.kr(1.5)).kr(2,gate:\gate.kr(1))
		* \amp.kr(0.1)
		=>Out.ar(out,_)
	}).add;
	SynthDef(\pluckD,{|freq=400 amp=1| //{{{
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
		sig=[sig,sig* Env.asr(0,1,2).kr(0,gate:\gate.kr(1)) => FreeVerb.ar(_,0.6,0.9)];
		sig=XFade2.ar(sig[0],sig[1],\blend.kr(0));  
		sig=DelayN.ar(sig,0.01,Rand(0.01));
		Out.ar(\out.ir, sig*amp);
		DetectSilence.ar(sig,doneAction:2)
	}).add;//}}}
	SynthDef(\ooh, {| out=0 gate=1| //{{{
		Formants.ar(
			Vibrato.kr(\freq.kr(400,13),\rate.kr(rrand(6,7.0!5)),\depth.kr(0.02)),
			Vowel(\u,\soprano).blend(Vowel(\a,\soprano),VarLag.kr(\blend.kr(0),\lag.kr(0.5)))
		)
		=>Splay.ar(_)
		* Env.cutoff(3).kr(2,gate:gate)
		* \amp.kr(0.1)
		=>Out.ar(out,_)
	} ).add; 
	SynthDef( \sawzz,//{{{
		{Saw.ar(\freq.kr(400,\port.kr(0.5)),0.1)
		* Env.asr(0.1,1,2).kr(2,gate:\gate.kr(1))
		* \amp.kr(0.1)
		=>(CombN.ar(_,1)+Gain.ar(_,3))
		=>Out.ar(\out.kr(0),_)}
	).add;
	~synthsLoaded.isNil.if{"/Users/michael/tank/super/song-Synthdefs.scd".load};
	SynthDef(\stairs, {	//{{{
		var frequency = \freq.kr(40,\portamentoTime.kr(2));
		var step = \step.kr(0.5);
		frequency = ( frequency / step ).floor * step;
		Pulse.ar(frequency.midicps,0.25,\amp.kr(0.1))
		* Env.cutoff(1).kr(2,gate:\gate.kr(1))
		=>Out.ar(\out.kr(0),_)
	}).add;
)
