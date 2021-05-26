~record = { | name, length |
	g = Group.after(1);
	b = Buffer.alloc(s, 65536, 2);
	b.write("~/tank/Maura-PCS/SC".standardizePath +/+ name.asString, "wav", "int24", 0, 0, true);
	// create the diskout node; making sure it comes after the source
	d = Synth.tail(g, "diskout2", [\bufnum, b]);
	fork{ 
		length.wait ;
		d.free; 
	b.close;
	b.free;
	}
	
};

(
~addBus={|...args| var bus=Bus.audio; var synth=Synth(*args); synth.set(\out,bus.index);[synth,bus]}
~addBus.(\default,[\freq,[300,400,500]])
 { SinOsc.ar(440.rand,\phase.kr(0)) } => _.play(s,1) => _.mapLfo(\phase,{SinOsc.kr(Line.kr(400,200,8))})
 =>_.play

 a=NodeProxy.new(s,\audio,2).play.fadeTime_(1);
 a.fadeTime_(2);
 a.source_(
	 "genderstra.wav".default.record(bus:0,numChannels:2,length:60);
	 {var scale=2.8.rand;Gendy4.ar(0.1,0.1,durscale:0.0009,minfreq:[ 300,420,500,640 ]*.x scale,maxfreq:310*scale) *0.06 =>Pan2.ar(_,LFBrownNoise2.kr(0.3))}.play(s,Effect(MoogFF.ar(_,SinOsc.kr(\sweepRate.kr(0.1)).range(700,3000)),inputChannels:2).bus.index)
	 (note:[1,4,8,12],instrument:\stringyy,dur:200,amp:0.3).play
)

(//nice stringyy variant
	// sequencing could be done with Demand Rate UGens instead could be all one synthdef
	//do a few of these

	a={
		Gendy4.ar(0.1,0.1,durscale:0.0009,minfreq:\min.kr([ 300,420,500,640 ],3),
		//maxfreq:[310,430,520,660]
		maxfreq:310
	) 
		*0.06 
		=> Mix.ar(_)
		=>Pan2.ar(_,LFBrownNoise2.kr(0.3))
	}.play(s,Effect(
		MoogFF.ar(_,SinOsc.kr(\sweepRate.kr(0.1)).range(700,3000)),inputChannels:2).bus.index
	);
	fork{
		loop{
			rrand(1,5.0).wait;
			a.set(\min,[500,400,300,360].scramble);
		}
	}

)
(
// make this a method of File!!
"~/tank/super/Journal4-2.scd".version
"~/tank/super/Journal4-2.scd".unversion
"~/tank/super/Journal4-2.scd-bak".pathMatch.sort
GARBAGE
)
