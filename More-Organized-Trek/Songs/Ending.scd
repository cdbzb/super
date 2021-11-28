
/*
[Bridge]

(Uhura is screaming in terror before collapsing across her console. Chapel is standing rigid by the Captain's chair.) ,
[4,3,2.5,2,1,\_]

SPOCK: Must I make an example of you, too, Helm? 
(Kirk, Mulhall and McCoy enter.) SPOCK: Pain, Captain. And you, my dear? 
(As Kirk and Mulhall double over, McCoy dashes to Spock's side, ready to inject him.) 
SPOCK: Fortunately, Doctor, I know every thought of every mind around me. See? (to Chapel) Take the hypo from him. And inject him with it. 
(But she injects Spock/Henoch instead! He leaps from his seat.) 
SPOCK: Fools. I'll simply transfer to another place, another body. 
(He whirls around.) 
*/
(
Song(\ending,[]).current;
//Song.currentSong.synful1 = Synful();
//Song.currentSong.synful2 = Synful();
Song.resources.infrastructure=
{
	FunctionList.new.array_([
		{ Song.currentSong.synful1 = ~synful1 = Synful()},
		{  Song.currentSong.synful2 = ~synful2 = Synful()},
		{ fork {
			~synful2.condition.wait;
			Song.condition.test_(true).signal
		}}
	]).value
}.inEnvir;
["SPOCK: Sargon! No, Sargon, please. Let me. Let me transfer. ",[1,2,3].dm(\c)].addLine;
["(He falls to the floor and his victims are freed from their pain.) ","r"].addLine;
["KIRK: Spock. My friend Spock. If there'd only been another way. ","r"].addLine;
["SARGON [OC]: (boom) I could not allow your sacrifice of one so close to you. ",[1,13,12,14,13,12,11,7,6,5,4,3,2,4,3,2].dm(\c)].addLine;
//P.tune(\sacrifice);
	Song.voxSacrifice=VocalRPP(\sacrifice,\test);
P(\vox,start:\sacrifice,music:{|p b e| 
	e.resources.rpp=VocalRPP(\sacrifice,\test); // set rpp in the Part to the vocalRPP
	// TODO now make the relevant guide check to see if they should mute this!!
	Synth(\soundInMorph,[
		modulator: 13,
		carrier: 11,
		amp:0.32
	]);

	{ //carrier
		var tune = p.tune[e.start].list;
		var freqs = Demand.ar(
				TDuty.ar(b.dq,1,1),
				1,
				tune.asArray.midicps /.t [1,2,4,5,6,8] => _.dq
			);
		var car = Gendy1.arWidth(
			freq: freqs
			,
			width:1.10) =>Mix.ar(_)
			* Env.linen(3,5,6).kr(2,gate:1);
		var saw = Saw.ar(freqs) * 0.1
		=> RLPF.ar(_,100,2)
			* Env.linen(3,5,6).kr(2,gate:1);
		car => FreeVerb.ar(_,1,0.8)
		+saw
		/10
		=> {|i|i[[0, 2 ]]}//!3 * [1,0.1,0.1]
//		=>Mix.ar(_)
	}.play(s,11); // set this bus
	{ //modulator
		PlayBuf.ar( 1,p.voxSacrifice.buffer) 
		=> EchoNone.ar(_,1,0.4,2) * 2
		//=> MoogFF.ar(_,8000,1)
		=> LPF.ar(_,6000)
	*10 	=> SafetyLimiter.ar(_) /5
	}.play(s,13);
});
P(\bass,start:\sacrifice,music:{|p b e| 
	[
		instrument:\stringyy,
		freq: [11,6,4,2,5].df(\c,octave:3).q,
		dur: b.parse([[ 1,1/3 ],[2/3,1,1,1],2,4,2,1,1]).q,
		out:2,amp:0.2
	].pp
	
});
["(Lights dim and glow, then Chapel wobbles.) ","r",[10]].addLine;
	P(\transform,start:\wobbles,music:{ |p b e| 
		Synths(\transLinen,\sustain,b.sum,\freq,[1,3,11,13].df(\c),\amp,0.1,\out,1);
		Synths(\transLinen,\sustain,b.sum,\freq,[1,3,11,13].df(\g,scale:\minor),\amp,0.1,\out,2);
		Synths(\transLinen,\sustain,b.sum,\freq,[1,3,11,13].df('c#',scale:\minor),\amp,0.1,\out,3);
		Synths(\transLinen,\sustain,b.sum,\freq,[1,3,11,13].df('f#'),\amp,0.1,\out,4);
		//////////strings
		p.synful1.patch(\violas,\tremsulpont,0);
		p.synful2.patch(\violins2,\tremsulpont,0);
		(expression:100,freq:[1,3,5,6.5,11,13].df(\c),type:\synful,instance:p.synful1,dur:b.sum,amp:1).play;
		(expression:200,note:[1,3,5,6.5,11,13].df('f#'),type:\synful,instance:p.synful2,dur:b.sum,amp:2).play;
		p.synful1.syn.set(\out,Effect(FreeVerb.ar(_,0.75,0.55)).bus.index);
		p.synful2.syn.set(\out,Effect(PlateReverb.ar(_,mix:0.55),out:2).bus.index);
		////////timpani
		s.bind{{ |pitchScale=1.15 loss=0.99998 |
			var env=Env.linen(0,b.sum-5,8).kr(2,gate:1)*0.175;
			var numChannels=4;
			var exc = Dust.ar(2!numChannels)+Impulse.ar(0);
			var sig;
			exc = Decay.ar(exc,0.02);
			exc=Integrator.ar(exc,0.8,0.1);
			exc=PinkNoise.ar(exc);
			sig=MembraneCircle.ar(exc,[0.007,0.0073]*pitchScale,loss)*env;
			sig
		}.play;}
		
	});
["MCCOY: Jim. ","r"].addLine;
["(Spock stands up.) ","r"].addLine;
["KIRK: You're alive. ",[1,1,7].dm(\f,scale:\mixolydian)].addLine;
P.tune(\alive);
["MCCOY: There was enough poison in that hypo to kill ten Vulcans. ","r"].addLine;
["SARGON [OC]: No, Doctor. I allowed you to believe that to be true so that ","r"].addLine;
["Henoch would read your thoughts and believe it also. ","r"].addLine;
["MCCOY: Sargon. ","r"].addLine;
["SPOCK: It seems, Doctor, the injection was only enough to cause unconsciousness. ","r"].addLine;
["SARGON [OC]: But Henoch believed and fled the body. ","r"].addLine;
["He is destroyed. ","r"].addLine;
["KIRK: But your vessel was destroyed, too. Where was your consciousness kept? ","r"].addLine;
["SPOCK: The place Henoch would least suspect, Captain. ","r"].addLine;
["CHAPEL: That is why I was summoned into Sickbay, Doctor. ","r"].addLine;
["Mister Spock's consciousness was placed in me. ","r"].addLine;
["(boom boom) We shared consciousness (we shared consciousness... ) to",[-5,-5,3,2,4,3,2,1].dm('e-')++[3,2,4,3,2,1].dm( 'a-' )].addLine;
Song.quarters[\shared]=Song.parseBeats(\shared,[1,1,1,1,1,1,1,3,1,1,1,1,1,1]/2);
P.tune(\shared,Pset(\dur,Song.quarters[\shared].mean/2 * [1,1,1,1,1,1,1,3,1,1,1,1,1,1].q,_));
Song.sharedClock=TempoClock.new().permanent_(true);
P(\newVersion,start:\shared,music:{|p b e| 
	var tracks;
	var group = p.sharedGroup=Group.new;
	var clock = p.sharedClock.tempo_(p.quarters[\shared].mean.reciprocal/2);
	var shaker =	[time:[0.05,1,0.1].q(inf),amp:0.2,resonantFreq:60,dur:1/8,up:[1,0].q(inf),down:[0,1],q(inf)].pm(\shakeEnv);
	var bd =[instrument:\bd_808,amp:0.15].p;
	var hat =[instrument:\hat_808,amp:[[1].q([3,5,6].q(1)),0].q(inf)/10,dur:1/16,out:Pwhite(0,5,inf)].p;
	var bass = [freq:[1,4,6.5,12.5].df(\c,octave:[3,2]).q(inf).stutter(4),dur:0.25,legato:0.3,amp:0.15,out:Effect(DelayC.ar(_,0.1,SinOsc.ar(6).range(0,0.001)).tanh).bus.index].p;
	var yow = [instrument:\yowbass,freq:[1,4,6.5,12.5].df(\c,octave:[3,2]).q(inf).stutter(4),dur:0.25,legato:0.3,amp:0.015,out:2].p;
	var stringyy1 = [freq:[\r,3,2,4,3,2,1].df([\c,\f])++[3,2,4,3,2,1].df([\f,'b-'],octave:6)=>_.q(inf),dur:[2,1,1,1,1,1,3,1,1,1,1,1,1].q(inf)/4,instrument:\stringyy,out:[0,2]].p;
		var saw1 = [freq:[\r,5,13,12,\r].df(\c).q(inf),dur:[15,1,3,6,7].q(inf)/4,instrument:\sawSynthSustain,legato:1.1].p;
		//there's a better way to write these echoing lines!
		var saw2 = [freq:[\r,12,11,\r].df(\c).q(inf),out:3,amp:0.07,dur:[24,3,6,7].q(inf)/4,instrument:\sawSynthSustain,legato:1.1].p;
		var saw3 = [freq:[\r,11,6.5,\r].df(\c).q(inf),out:2,amp:0.06,dur:[32,3,6,7].q(inf)/4,instrument:\sawSynthSustain,legato:1.1].p;
		var saw4 = [freq:[\r,6.5,6,\r].df(\c).q(inf),out:2,amp:0.05,dur:[40,3,6,7].q(inf)/4,instrument:\sawSynthSustain,legato:1.1].p;
		var sn = [dur:"..xx..x.".asDrumPat(4,inf),amp:0.1,instrument:\sn_808].p;

		[shaker,bd,hat,yow].par.findur(4)
		+= saw1 => Pmul(\freq,9/10,_) 
		+= [4,[ shaker,bd,hat,yow=>Pmul(\freq,4/3,_) ].par.findur(4)]
		=>_.postln
	=>Pbindf(_,\group,p.sharedGroup) 
	=> _.play(p.sharedClock);

//fork{ 
//	b.sum*4 => _.wait;
//	p.sharedClock.clear(releaseNodes:true);
//	0.01.wait;
//	p.sharedGroup.release;
//	1.wait;
//	p.sharedClock.clear()}
});
//MUTED P(\lick,start:\shared,music:{|p b e| 
//MUTED 	[2,1, 6.5,5].dm(\c)
//MUTED });
//MUTED P(\kick,start:\shared,music:{|p b e| 
//MUTED 	{
//MUTED 		AnalogBassDrum.ar(
//MUTED 			trig: TDuty.kr(Song.quarters[\shared].mean/2*[1,1,1,1,1,1,1,1].dq(inf),0,[1,1,0,1,1,1,0,1].dq(2)) ,  
//MUTED 			infsustain: 0.0,  
//MUTED 			accent: Demand.kr(Impulse.kr(Song.quarters[\shared].mean/2),0,[0,1,0].dq(inf)),
//MUTED 			freq: 40,  
//MUTED 		tone: 0.2,  
//MUTED 			decay: 0.5,  
//MUTED 			attackfm: 0.5,  
//MUTED 			selffm: 0.25
//MUTED 		)
//MUTED 		=> {|i| [i,CombC.ar(i,1,Song.quarters[\shared].mean/4.02,3)] }
//MUTED 		*10
//MUTED 		++ ( AnalogSnareDrum.ar(
//MUTED 
//MUTED 			trig: TDuty.kr(Song.quarters[\shared].mean/2*[1,1,1,1,1,1,1,1].dq(inf),0,[0,0,1,1,0,0,1,0].dq(2),0) ,  
//MUTED 			infsustain:0,
//MUTED 			freq:166,
//MUTED 			decay:0.3,
//MUTED 			snappy:0.8
//MUTED 		) => FreeVerb.ar(_,0.5,0.8) )
//MUTED 
//MUTED 		=> Splay.ar(_)
//MUTED 		/2
//MUTED 	}.play;
//MUTED 	fork{
//MUTED 		var a;
//MUTED 		0.2.wait;
//MUTED 		a = Synth(\shake,[\out,2]);
//MUTED 		b.sum.wait;
//MUTED 		a.free
//MUTED 	}
//MUTED 
//MUTED });
//MUTED 	SynthDef(\shake,{
//MUTED 	StkInst.ar(Stk.at("Shakers"),3.midicps,
//MUTED 		VarSaw.ar(Song.quarters[\shared].mean.reciprocal*4,iphase:pi/2) => Decay.ar(_,0.5),1,0.5)
//MUTED 		=> Out.ar(\out.kr(0),_)
//MUTED 	}
//MUTED 	).add;
//MUTED P(\bass,start:\shared,lag:-0.01,music:{|p b e| 
//MUTED 	[
//MUTED 		dur:p.quarters[e.start].mean/2,
//MUTED 		freq:[-5,1,4,6.5].df('e-',octave:3).stutter(4).q,
//MUTED 		instrument:\sawSynth
//MUTED 
//MUTED 	].//pm(\sawSynthSustain).play
//MUTED 	pp
//MUTED });
["gether. ","r"].addLine;
Song.getherLines=VoiceLeading(
	[
		[12, 11, \_,  7,  \_, 6],
		[4,  3,  2.5, 2,  1,  \_],
		[6,  5,  \_,  \_, 3,  \_],
	],
	[1,1,1,1,1/2,1/2]
).df(\d);
P(\echos,start:\gether,music:{|p b e| 
	
[freq:[12,11,\r].df(\d).q,out:3,amp:0.07,dur:[3,6,7].q(inf)/4,instrument:\sawSynthSustain,legato:1.1].p.play();
[freq:[\r,11,6.5,\r].df(\d).q,out:2,amp:0.06,dur:[10,3,6,7].q(inf)/4,instrument:\sawSynthSustain,legato:1.1].p.play();
[freq:[\r,6.5,6,\r].df(\d).q,out:2,amp:0.05,dur:[20,3,6,7].q(inf)/4,instrument:\sawSynthSustain,legato:1.1].p.play();
});
P(\lines,start:\gether,music:{|p b e| 
	p.getherLines.p	=> Pbindf(_,
		\legato, 1.1
		)
		=> _.play
});
["SARGON [OC]: We now know we cannot permit ourselves to exist in your world, my children. ","r"].addLine;
["Thalassa and I must now also depart","r"].addLine;
["into oblivion. ","r"].addLine;
["KIRK: Is there any way we can help you, Sargon? ","r"].addLine;
["SARGON: Yes, my son. ","r"].addLine;
["You can allow Thalassa and me tp ","r"].addLine;
["(boom boom) share your bodies again. ","r"].addLine;
["A last moment together. ","r"].addLine;
["(Mulhall nods, and they go over to the science station for the light trick and voice change.) ","r"].addLine;
["MULHALL: Oblivion together does not frighten me, beloved. Promise we'll be together. ","r"].addLine;
["KIRK: I promise, beloved. ","r"].addLine;
["MULHALL: Together forever. ","r"].addLine;
["KIRK: Forever beloved. Forever. ","r"].addLine;
["(They embrace and kiss, and the light thing happens again during it.) ","r"].addLine;
["KIRK: Well, I'm sure that Sargon appreciated your co-operation, Doctor Mulhall. ","r"].addLine;
["MULHALL: Yes. I was happy to co-operate, Captain. ","r"].addLine;
["CHAPEL: It was beautiful.","r"].addLine;
)
