 ( //transformation			{{{1
	 //line 245
	Song(\transform,[]).current;
	Song.condition=Condition.new;
( Song.infrastructure={
		FunctionList.new.array_([
			//~synthsLoaded.isNil.if{"/Users/michael/tank/super/song-Synthdefs.scd".load},
			{fork{
				try{~syn1.controller.loaded.not.if{~syn1=~synful2.()}}{~syn1=~synful2.()};
				try{~syn2.controller.loaded.not.if{~syn2=~synful2.()}}{~syn2=~synful2.()};
				~syn1.condition.wait;
				~syn2.condition.wait;
				Song.condition.test_(true).signal;
			}},
		]).value
	}.inEnvir;
);
	["(transformation!)","r",15].addLine;
	P(\transform,start:0,music:{ |p b e| 
		var dur = b.sum; 
			var pitches=~panNotes.("f#3 b- c4 e")+[0,12];
		s.bind{
			var chord=pitches.collect({|item index|  Synth(\trans,[\freq,item.midicps,\amp,0.1])});
			var chord2=pitches.collect({|item index|  Synth(\trans,[\freq,item.midicps,\amp,0.1])});
			//~xtreme.init;
			try{~fadeO.stop};
			//try{~syn1.controller.loaded.not.if{~syn1.init}}{~syn1=~synful.()};
			//try{~syn1.controller.loaded.not.if{~syn1.init}}{~syn1=~synful2.()};
			{dur.wait;chord.do{|i|i.release}}.fork;
			{dur.wait;chord2.do{|i|i.release}}.fork;
		};
		////cymbal
		(instrument:\cymbal,length:8).play;
		////strings
		try{~syn1.monitor.free;};~syn1.monitor=Monitor.new;~syn1.monitor.play(~syn1.bus.index,2,0,2,fadeTime:0.05);
		try{~syn2.monitor.free;};~syn2.monitor=Monitor.new;~syn2.monitor.play(~syn2.bus.index,2,2,2,fadeTime:0.05);
		//TODO these need to turn themselves off with DoneActions rather than routines
		{
			var v,w;
			v={var sig=In.ar(~syn1.bus);sig=FreeVerb.ar(sig,room:0.75,mix:0.55)*3;ReplaceOut.ar(~syn1.bus,sig)};v=v.play;
			w={var sig=In.ar(~syn2.bus);sig=PlateReverb.ar(sig,mix:0.55)*2;ReplaceOut.ar(~syn2.bus,sig)};w=w.play;
			{20.wait;v.free}.fork;
			{20.wait;w.free}.fork;
		};

		
		~syn1.setprog(3,5,0); ~syn1.setprog(4,5,1);
		//~syn2.setprog(3,5,0); ~syn2.setprog(4,5,1);
		~syn2.patch(\violas,\tremsulpont,0);
		~syn2.patch(\violins2,\tremsulpont,1);
		//FADE Synful
		{
			8.wait;"now!".postln;
			127.do(
				{|i|
					[~syn1,~syn2].do(_.expression((127-i),0));
					[~syn1,~syn2].do(_.expression((127-i),1));
					0.18.wait
				}
				);
		}.fork;
		//~syn2.expression(0,0)
		//~fade0

		s.bind{
			//(type:\midi,midiout:~syn1.controller.midi,\midinote:~panNotes.("f#3 b- c4 e").flatten-[0,12],dur:20).play;
			(type:\vst_midi,vst:~syn1.controller,\midinote:~panNotes.("f#3 b- c4 e").flatten-[0,12],dur:20).play;
			//(type:\vst_midi,vst:~syn1.controller,\channel:2,\midinote:~panNotes.("f#3 b-4 c4 e").flatten-24,dur:20).play;
			(type:\vst_midi,vst:~syn2.controller,\channel:2,\midinote:~panNotes.("f#3 b-4 c4 e").flatten-24,dur:20).play;
			~syn1.expression(127,0);
			~syn1.expression(127,1);
			~syn2.expression(127,0);
			~syn2.expression(127,1);
		};
		//tympani

		s.bind{{ |pitchScale=1.15 loss=0.99998 |
			var env=Env.linen(0,dur-5,8).kr(2,gate:1)*0.175;
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
) //}}}
