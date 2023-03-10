(
		[
//		freq:Pexprand(10,9000),
		degree: Prand ( Arpeggio([1,3,5,7],25),inf),
		root:[0].q(18)++[4].q(19)++[4].q(20)++[8].q(inf),
		octave:3,
		rel:9,
		dur:Pwhite(0.1,0.25),
		pan:Pwhite(-1,1),
		legato:8,
		instrument:\sawSynthSustain,
		test:Toggle.new.mapToXTouch(\f5),
		effect:Effect.new({|i|
			Vocoder.ar(i.tanh,
			Item(\iUnderstand).playbuf(loop:1)*1!4=>EchoNone.ar(_,0.3,0.3,2)
			,12,
			q:0.1,
			low:150,
			high:9000,
			hpfscal:0,
			outscal:20
		)
		=>DetectSilenceDry.ar(_,doneAction:2,time:3)
	},inputChannels:4).bus.index,
//		out:Pfunc{|i|( i.test.state==1 ).if{ i.effect }{0}},
out:Pfunc{|i|i.effect+3.rand},
		//out:Pkey(\effect)
	].p.fin(59) 
	.trace
	.play
)

(
		[
		degree: Prand ( Arpeggio([1,3,5,7],25),inf),
		root:[0].q(18)++[4].q(19)++[4].q(20)++[8].q(inf),
		octave:3,
		rel:9,
		dur:Pwhite(0.1,0.25),
		pan:Pwhite(-1,1),
		legato:8,
		instrument:\sawSynthSustain,
		test:Toggle.new.mapToXTouch(\f5),
		effect:Effect.new({|i|
			Vocoder.ar(i.tanh,
			Item(\iUnderstand).playbuf(loop:1)*1!4=>EchoNone.ar(_,0.3,0.3,2)
			,12,
			q:0.1,
			low:150,
			high:9000,
			hpfscal:0,
			outscal:20
		)
		=>DetectSilenceDry.ar(_,doneAction:2,time:3)
	},inputChannels:4).bus.index,
		out:Pfunc{|i|( i.test.state==1 ).if{ i.effect+3.rand }{0}},
//out:Pfunc{|i|i.effect+3.rand},
	].p.fin(59) 
	.play
)
(
	[
		freq:Pwhite(100,3000),
		dur:Pwhite(0.05,0.1),
		instrument:\sawSynthSustain,
		legato:18,
	].p
	=>
	//this could be encapsulated
	Pbindf(_,
		\effect,Effect.new({|i|
			Vocoder.ar(i.tanh,
			Item(\iUnderstand).playbuf(loop:1)*1!4=>EchoNone.ar(_,0.3,0.3,2)
			,12,
			q:0.1,
			low:150,
			high:9000,
			hpfscal:0,
			outscal:20
		)
		=>DetectSilenceDry.ar(_,doneAction:2,time:3)
	},inputChannels:4).bus.index,
		\out,Pkey(\effect)+Pwhite(0,2),
	)
	=> _.play

)

(
	[
		instrument:{
			var len=\len.ir(8);
			SawDPW.ar(\freq.kr(300))*0.12
			* Env.triangle(len).kr(0,gate:\gate.kr(1))
			=>EchoCubic.ar(_,1,SinOsc.kr(0.06).range(0.4,0.41+Rand(0.05)),8)

			=> Out.ar(\out.kr(0),_);
			Env.triangle(len+8).kr(2,gate:\gate.kr(1))
		}.asDefName,
		out:Pwhite(0,3),
		freq:Pwhite(100,1000),
		len:Pwhite(5,20),
		legato:Pkey(\len)+1,
	].pp
)
