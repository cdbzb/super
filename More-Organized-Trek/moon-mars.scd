a.dump
a.dump}
currentEnvironment
a.pop

Environment.pop
(
	fork{
		{| out=0 gate=1|
				Formants.ar(
					Vibrato.kr(\freq.kr(400,13),\rate.kr(rrand(6,7.0!5)),\depth.kr(0.02)),
					Vowel(\u,\soprano).blend(Vowel(\a,\soprano),VarLag.kr(\blend.kr(0),\lag.kr(0.5)))
				)
			=>Splay.ar(_)
			* Env.cutoff(3).kr(2,gate:gate)
			=>Out.ar(out,_)
		}
		=>SynthDef(\ooh,_)=>_.add;

		s.sync;

		~ooh=Synths(\ooh,
			\freq,[500,600,660,750]/2,
			\blend,0,
			\out,{
				~verbBus ?? {~verbBus=Bus.audio(s,2).index};
				~verbBus}.value
			);

			~verb={In.ar(~verbBus,2)/2=>FreeVerb.ar(_,0.6,0.9)}.play(s,0,addAction:\addToTail).dur(35);

			//s.plotTreeL;
			
		}
		)
		(
			{~ooh.set(\freq,[450,500,600,720]/2)}.sched(0);
			{~ooh.release(3)}.sched(2);
			//~ooh.set(\blend,[1,1,1,1],\lag,0.5!4)
		)
		(
			b=fork{9.do{~ooh.set(\blend,[0,0,0,1].scramble) ;1.wait}};
			{~ooh.set(\freq,[450,500,600,720]/2)}.sched(3);
			{~ooh.release(3)}.sched(4);
			{b.stop}.sched(7)

			//~ooh.set(\blend,[1,1,1,1],\lag,0.5!4)
		)
		
		~ooh.set(\freq,[500,600,660,750]/2)
		
		~synths.do(_.release(3));
		~synths.do(_.set(\blend,1,\lag,0.5));
		~synths.do(_.set(\blend,0));
		(instrument:\default,freq:[900,800]).play.id

		a={|array|Synth(\default,array)}.flop;
		a.([\freq,[400,500]])
		a.([\freq,400],[\freq,500]).play
		///!!!
		a=[\freq,[400,500],\amp,[0.8,0.1]].flop.do(Synth(\default,_))

        ///!!!
		[400,500].do({|i|Synth(\default,[\freq,i])})
		a[1].do{|i|Synth(\default,[a[0],i])}
		Synths(\default,[\freq,[400,600]])
		~synths={|def args| }
		flop
