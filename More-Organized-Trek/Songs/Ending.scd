
/*
[Bridge]

(Uhura is screaming in terror before collapsing across her console. Chapel is standing rigid by the Captain's chair.) 

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
P(\lick,start:\shared,music:{|p b e| 
	[2,1, 6.5,5].dm(\c)
});
P(\kick,start:\shared,music:{|p b e| 
	{
		AnalogBassDrum.ar(
			trig: TDuty.kr(Song.quarters[\shared].mean/2*[1,1,1,1,1,1,1,1].dq(inf),0,[1,1,0,1,1,1,0,1].dq(2)) ,  
			infsustain: 0.0,  
			accent: Demand.kr(Impulse.kr(Song.quarters[\shared].mean/2),0,[0,1,0].dq(inf)),
			freq: 40,  
		tone: 0.2,  
			decay: 0.5,  
			attackfm: 0.5,  
			selffm: 0.25
		)
		=> {|i| [i,CombC.ar(i,1,Song.quarters[\shared].mean/4.02,3)] }
		*10
		++ ( AnalogSnareDrum.ar(

			trig: TDuty.kr(Song.quarters[\shared].mean/2*[1,1,1,1,1,1,1,1].dq(inf),0,[0,0,1,1,0,0,1,0].dq(2),0) ,  
			infsustain:0,
			freq:166,
			decay:0.3,
			snappy:0.8
		) => FreeVerb.ar(_,0.5,0.8) )

		=> Splay.ar(_)
		/2
	}.play;
	fork{
		var a;
		0.2.wait;
		a = Synth(\shake,[\out,2]);
		b.sum.wait;
		a.free
	}

});
	SynthDef(\shake,{
	StkInst.ar(Stk.at("Shakers"),3.midicps,
		VarSaw.ar(Song.quarters[\shared].mean.reciprocal*4,iphase:pi/2) => Decay.ar(_,0.5),1,0.5)
		=> Out.ar(\out.kr(0),_)
	}
	).add;
P(\bass,start:\shared,lag:-0.01,music:{|p b e| 
	[
		dur:p.quarters[e.start].mean/2,
		freq:[-5,1,4,6.5].df('e-',octave:3).stutter(4).q,
		instrument:\sawSynth

	].//pm(\sawSynthSustain).play
	pp
});
["gether. ","r"].addLine;
["SARGON [OC]: We now know we cannot permit ourselves to exist in your world, my children. ","r"].addLine;
["Thalassa and I must now also depart into oblivion. ","r"].addLine;
["KIRK: Is there any way we can help you, Sargon? ","r"].addLine;
["SARGON: Yes, my son. ","r"].addLine;
["You can allow Thalassa and me ","r"].addLine;
["to share your bodies again. ","r"].addLine;
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
