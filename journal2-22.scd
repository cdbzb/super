(
a={
	var vars=();
	vars.effect=Effect.lfo({[Pulse,SinOsc].choose.ar(\lfreq.kr(3)).range(200,300)});
	vars.offset=[150,200,300,350].choose;
	vars.synthName=rrand(100000,999999).asString;
	//do this without a name
	(

		a: SynthDef(vars.synthName,
			{ 
				Env.triangle(5).kr(2,gate:1)
				* SinOsc.ar(\freq.kr(1,0.3) + \mod.kr(0) , 0.1)
				=>Out.ar(\out.kr(1),_)}
			).add,
		pbind: [
			mod:vars.effect.pfunc,
			out:[0,1].choose,
			freq:[200,300,400].q(8)+vars.offset,
			lfreq:Pwhite(3,8,inf),
			llfreq:Pfunc({|e| vars.effect.set(\lfreq,e.lfreq)}),
			instrument:vars.synthName
		].p,
		play: {~pbind.play} 

	)
}.value;
//fork{6.do
//	{
//		a.value.play;
//		rrand(3,6).wait
//	}
//}
)
(
Song.new(\foo,[]).current;
["why?",[3],[9]].addLine;
a=P(\wibble,
	music: (
		//		expressions are evaluated on load
		synthName: SynthDef(
			rrand(10000,99999).asString,{ 
				Env.triangle(5).kr(2,gate:1)
				* 0.1
				* SinOsc.ar(\freq.kr(1,0.3) + \mod.kr(0) , 0.1)
				=>Out.ar(\out.kr(1),_)
			}
		).add.name ,
		//		anything that needs to be reevaluated *on each play* needs to
		//		be wrapped and .value called
		effect:{
			Effect.lfo({
				//Env.perc(2,2).kr(2,gate:\gate.kr(1)) 
				//*
				[Pulse,SinOsc].choose.ar(\lfreq.kr(3)).range(200,300)
			},dur:
			~b.sum+1
		)
		}
			,
		offset:[150,200,300,350].choose,
		play: {
			fork{
				var effect=~effect.value;
				s.sync;
				[ instrument:~synthName,	
					mod:effect.pfunc,
					out:[0,1].choose,
					freq:[200,300,400].q(8)+~offset,
					lfreq:Pwhite(3,8,inf),
					llfreq:Pfunc({|e|effect.set(\lfreq,e.lfreq)}),
				].p
				=> Pfindur(~b.sum,_) 
				=>_.play
			}
		},

	)
);
Song.currentSong.magic=Bus.audio;
P(\swoosh,music:(
	line:{var offset= 200.rand; Effect.lfo({Line.kr(200+offset,800+offset,~b.sum,doneAction:2)})},
	play:{
		var release = 4;
		[
			freq:~line.value.pfunc,
			dur:~b[0]/6,
			verb:Effect(FreeVerb.ar(_,1,1),out:2.rand).bus.index,
			out:Pkey(\verb)
		].p.fin(6).play;

		{In.ar(~p.magic.index)}.play(s,0)
		.dur(~b.sum,release);

		{ 
			Env.asr(5,1,4).kr(2,gate:\gate.kr(1))
			* Impulse.ar(60*Rand(0,4))
		}.play(s,~p.magic.index)
		.dur(~b.sum,release)
	}
));
["verbfun",[1].dm,[10]].addLine;
P(\verb ,start:'verbfun',music:(
	early: EarlyRef.ar(_,[1,Line.kr(0,3,~b.sum),1],[SinOsc.ar(3).range(1,3),2,2],[3,3,3]),
	verb: //I.d,
		DWGReverbC1C3.ar(_,mix:0.5),
	silence: DetectSilenceDry.ar(_,doneAction:2),
	line:{Effect.lfo({ Env.triangle(4).kr(2,gate:1) * 0.3  })},	
	play:{
		[
			note:Pbrown(0,21!2,0.8),
			dur:rrand(0.5,1),
			out: Effect({|i|~early.(i)=>Mix.ar(_)=>~verb+~early.(i)=>~silence}).bus.index,
			amp:~line.value.pfunc
		].pp;
		//defer{s.plotTree}

	}
)
);

)

Song.play; s.plotTree
Song.currentSong.wibble0.music.play;s.plotTree
s.latency_(0.1)
a.resources.synthName
Synth(a.synthName)
Song.currentSong.qqq=(Part(\opop,2,3,4))
Song.currentSong.qqq.parent
Part.play
a.music.p.sum
s.latency_(2)
a={|key months ...args| args.postln}
a.(\p,months:5)
a.x
a.resources
a.music
Song.play
Song.currentSong.wibble0.music.b
a.play

a=(q:{1.postln});
a.q
a=(q:[1,2].sum)
a=(def:{Impulse.ar(2)=>Out.ar(\out.kr(1),_)}.asDefName,play:{[\instrument,~def].pp})
a.play

