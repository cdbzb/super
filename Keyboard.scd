( /// remove extraneous entries
	a=[3,2,4,5,6,r,3,4,5];
	a=a.do({|i x| i.isNumber.not.if({a.removeAt(x)})});
)
( ///// keyboard to noteName
	a= Array.fillNoteNames;
	b="zsxdcvgbhnjm,l.;/";
	c=Dictionary.new;
	a.do({|m i| c.add(b.[i].asUnicode->a[i])});
	c;
)
( //// keyboard to noteNumber

	a=Array.series(16,0);
	b="zsxdcvgbhnjm,l.;/";
	c=Dictionary.new;
	a.do({|m i| c.add(b.[i].asUnicode->a[i])});
	c;
)
(
w=Window.new;
w.front;
v=w.view;
p=~andThe.tune.asStream;
v.keyDownAction={var x=p.next(());x.play(AppClock)};
)
(
p=Pbind(\note,Pwhite(1,20,inf)).asStream;
~next ={var x=p.next(());x.play};
//p=~andThe.tune.asStream;
MIDIClient.init;
MIDIIn.connectAll;
MIDIdef.noteOn(\next,{1.postln;~next.()})
)

( // keypress walks through DemandPattern
	{
		var note = Demand.kr(KeyState.kr(38)-0.1,0, Dwhite.new(2.0,3.0,inf));
		var sig=SinOsc.ar(note*50+200,0,EnvGen.kr(Env.perc(0.1,1),gate:KeyState.kr(38)-0.1));
		Out.ar(1,sig);
	}.play
)
( // keypress walks through DemandPattern
	{
		var note = Demand.kr(KeyState.kr(38)-0.1,0, Dseq.new([1,2,3,4],inf));
		var sig=SinOsc.ar(note*50+200,0,EnvGen.kr(Env.perc(0.1,1),gate:KeyState.kr(38)-0.1));
		Out.ar(1,sig);
	}.play
)


( //place harp at arbitrary point in sequence
	SynthDef(\bass,{|freq=400 amp=0.1| Out.ar(1,BPF.ar(Saw.ar(freq,amp),200,2)*EnvGen.kr(Env.perc(0.5)))}).add;
	~andThe=(
		dur: [ 0.437, 0.489,   0.322, 0.305, 0.303, 0.322, 0.333,   0.900 ],
		lyric: {"and the bo- dy- fun- tions will rise".split($ )},
		lick: Pseq([0,2,9,7,9,2,9,7]),
		tune: {|self|Pbind( \dur,Pseq(self.dur),\degree,self.lick)},
		bass: {|self|Pbind( \instrument, \bass, \dur,Pseq(self.dur)+Pwhite(-0.01,0.01,inf),
		\note,self.lick-24,\amp,0.3)};
	);

		m= TwoWayIdentityDictionary.new;
		~andThe.lyric.do({|i x| m.add(x->i.asSymbol)});

		~durTill={|symbol| var pos = m.getID(symbol); ~andThe.dur[0..pos-1].sum};
		~durTill.(\rise);
		~andThe.bass.play;
		Pbind(\dur,Pseq(~andThe.dur),\note,~andThe.lick).play;
		(SystemClock.sched(~durTill.(\rise),{(note: [-1,4,7,11]-[0,12],strum:0.03,amp:0.2).play}));
)

( //construct event recorder

	~recorder= {|nextTune=#[1,3,2,4,3]|  

SynthDef(\stepper, { 
				var note = Demand.kr(KeyState.kr(38)-0.1,0, Dseq.new(nextTune,inf));
				var sig=SinOsc.ar(note*50+200,0,EnvGen.kr(Env.perc(0.1,1),gate:KeyState.kr(38)-0.1));
				Out.ar(1,sig);
			};
		).add;
		( // pseudo-object 
			time:Main.elapsedTime,
			item:List.new,
			//cue:Pbind(\dur,Pseq(event.dur),\note,event.lick),
			//cue:~sections.playem,
			tune:nextTune,
			captureLoop:{|self char| 
				Routine ({ 
					loop { 
						self.item = self.item.add(Main.elapsedTime-self.time); self.time=Main.elapsedTime; char = 0.yield; }
					}
				)},
			makeWindow: {|self| var w=Window.new.alwaysOnTop_(true).front.alwaysOnTop_(true);
				var b=Button.new(w.view,Rect(10,10,100,100))
					.states_(["1",Color.black,Color.white])
					.action = {self.doOver;"do over".postln};
				var c=Button.new(w.view,Rect(110,10,100,100))
					.states_(["1",Color.black,Color.white])
					.action = { var a = self.ret;a.postln};
				var v=w.view;
				v.keyDownAction={self.captureLoop.(b);"lll".postln };
				self.item=[];
				Synth(\stepper);
				//self.cue.play;
				~sections.playem;
			},
			doOver:{|self| self.item=[];self.cue.play},
			ret: {|self|
					var ret=();
					ret.dur=self.item.round(0.001)[1..(self.item.size-1)];
					ret.note=nextTune;
					currentEnvironment[\foo]=ret;
					~sections.sections.add(currentEnvironment[\foo])
				};
		)
	}
)

(
	a=~recorder.([7,5,4,7,5,4,2,0,-1]);
	a.makeWindow;
)
~theirNatural=a.ret;
a.ret;
	a.ret.postln;
	a.doOver;
)
~theirNatural
~manyTimes;
~foo;

(
	~andThe=(	dur: [ 0.437, 0.489,   0.322, 0.305, 0.303, 0.322, 0.333,   0.900 ], note: [0,2,9,7,9,2,9,7]);
	~manyTimes=(dur: [ 0.496, 0.509, 0.531, 0.513 ],note:[1,4,[-3, 4], 7, 5]);
)

(
	~sections=(
		sections:[~andThe,~manyTimes,~theirNatural],
		notes: {|self| self.sections.collect({|i| i.note}).flatten},
		playem: {|self|
			Pbind(
				\dur,Pseq( self.sections.collect({|i| i.dur}).flatten),
				\note,Pseq( self.sections.collect({|i| i.note}).flatten)
			).play
			}
	);

~sections.playem;
)

(
	~song=(
		song:[
			"the extreme power of the","g a b- d5 b-4 a g",
			"alien mind will make the -","e5 d c f e f g f",
			"r r r r heart action dangerousely", "g5 g g g c6 a5 f b- a g f ",
			//		" high and the body functions will",
			//		" race r r many time their natural me-",
			//		"tabolism so we're going to have to",
			//		" monitor this very",
			//		"carefully"
		],
		lyrics:{|self| self.song.copySeries(0,2,self.song.size)},
		notes:{|self| var array = self.song.copySeries(1,3,self.song.size);
				array.collect({|string| Panola.new(string).midinotePattern})},
		durs:[]
	)

)

Pbind(\midinote,~song.notes[0]-12).play;
~song.lyrics[0].postln;


