( //load long from disk
Archive.read("/Users/michael/tank/super/theExtreme2");
~a=Archive.at(\song);
~song.durs=~a.durs;
)
( // the song event
	~song=(
		song:[
			"the extreme power of the","g a b- d5 b-4 a g",
			"alien mind will make the -","e5 d c f e f g f",
			"r r r r heart action dan ger ous ly high- ", "r r r r  c6 a5 f b- a g f g ",
			" - and the body functions will", "a5 c d a g a d a ", 
			" race r r many times their natural me-", "g5 r r  e5 g5 a4 g5 f e g ",
//			"tabolism so we're going to have to", " f5 e d c r g#4 a b c5 d e "
//			" mo- ni- tor this very", "d5 c4 a4 f f5 e "
//			"carefully","e5 d b4 r r r"
		],
		sections: {|self|self.song.size/2},
		cursor:0,
		lyrics:{|self| self.song.copySeries(0,2,self.song.size)},
		tune:{|self| var array = self.song.copySeries(1,3,self.song.size);
				array.collect({|string| Panola.new(string).midinotePattern})},
		durs:Pseq([1])!5,
		pbind:{|self | (0..self.sections-1).collect{|i| Pbind(\dur,self.durs[i],\midinote,self.tune[i])}},
		secDur:{|self | (0..self.sections-1).collect{|i| self.durs[i].list.sum} },
		secLoc:{|self| [0]++self.sections.asInt.collect({|i| self.secDur[0..i].sum}) },
		durTill:{|self sec till | self.durs[sec].list[0..till].sum},
		pbindFrom:{|self from=3| var list=self.pbind[from.asInt..(self.sections-1).asInt].postln;Pseq(list).postln},
		when: {|self| self.secDur[self.start]}, //for sections
		p:{|self|(self.start<self.cursor).not.if{
			TempoClock.sched(
				(self.secLoc[self.start]-self.secLoc[self.cursor]),
				{self.music.play})};self}, //for sections
	)
)
~song.secLoc[3];
~song.secDur[0..3].sum;
~song.pbindFrom.(3).play;
~song.pbind[0].play;
s.boot;
~song.sections;
~song.pbind[3..(~song.sections-1)];
var till=~song.sections-1;~song.pbind[3..till.asInt];
~song.pbind[3..6];
~song.sections-1;



( //construct event recorder
~recorder= {|song  range=#[0,1] cueSecs=1 |  
	//var range=Array.series((to-from),from);
	var from=range[0];
	//var seq = cueSecs.collect({|i| song.tune[from-i].list-60}).flatten;
	var seq = range.collect({|i|song.tune[i].list}).flatten;
	seq.postln;
	~stepper={ |seq|
		SynthDef(\stepper, { 
			var note = Demand.kr(KeyState.kr(38)-0.1,0, Dseq.new(seq.midicps));
			var sig=SinOsc.ar(note,0,EnvGen.kr(Env.perc(0.1,1),gate:KeyState.kr(38)-0.1));
			Out.ar(1,sig);
		};
	);
};
 	~stepper.(seq).add;
		( // pseudo-object 
			range:range,
			time:Main.elapsedTime,
			item:List.new,
			cue:{|self| 
				var range=(self.range[0]-(cueSecs-1)-1..self.range[0]-1);
				("range"++range).postln;
				(self.range[0]>0).if(
					{var seq = range.collect({|i|song.pbind[i]});
					Pseq(seq);},
					//{song.pbind[nextTune-1]},
					(type:\rest)
			)},
			captureLoop:{|self char| 
				Routine ({ 
					loop { 
						self.item = self.item.add(Main.elapsedTime-self.time); self.time=Main.elapsedTime; char = 0.yield; }
					}
				)},
			window:nil,
			makeWindow: {|self| var w=Window.new.alwaysOnTop_(true).front.alwaysOnTop_(true);
				var b=Button.new(w.view,Rect(60,10,100,100))
					.states_(["1",Color.black,Color.white])
					.action = {self.doOver;"do over".postln};
				var c=Button.new(w.view,Rect(160,10,100,100))
					.states_(["1",Color.black,Color.white])
					.action = { var a = self.ret;a.postln};
				var d=Button.new(w.view,Rect(260,10,100,100))
					.states_(["1",Color.black,Color.white])
					.action = {self.nextt;"next".postln};
				var v=w.view;
				self.window=w;
				StaticText(b,Rect(0,0,100,100)).string_("Do over").align_(\center);
				StaticText(c,Rect(0,0,100,100)).string_("Return").align_(\center);
				StaticText(d,Rect(0,0,100,100)).string_("next").align_(\center);
				EZText.new(v,Rect(0,110,300,50	),label:"range",initVal:self.range,);
				v.keyDownAction={self.captureLoop.(b);"lll".postln };
				self.item=[];
				t=Synth(\stepper);
				self.cue.play ;
				self.range.do({|i|song.lyrics[i].postln})
			},
			doOver:{|self| self.item=[];self.cue.play;t.free;t=Synth(\stepper)},
			nextt:{|self| self.range=(self.range+(self.range[1]-self.range[0]+1));
					self.range.do({|i x| (i>(song.sections-1)).if {self.range[x]=(song.sections-1).asInt}}); // check if range too high
					(self.range++" "++song.sections).postln;
					self.window.close;
				{
					var newSeq=self.range.collect({|i|song.tune[i].list}).flatten;
					~stepper.(newSeq).add;
					s.sync;
					t.free;self.makeWindow
				}.fork(AppClock)
			},
			ret: {|self|
				var recorded =self.item.round(0.001)[1..(self.item.size)];
				recorded.postln;
				self.range.do({|i|
					var returnChunk=List.new;
					var elements=~song.tune[i].list.size;
					elements.do(
						{|i| 
							if(recorded.size>0)
							{returnChunk.add(recorded.removeAt(0)) }
						}
					);
					(returnChunk[0].isNil.not).if{~song.durs[i]=Pseq(returnChunk)} ;
				});
				//~song.durs[nextTune]= Pseq(recorded);
			};
		)
	};
a=~recorder.(~song,[0,1],2);
a.makeWindow;
)

( //// moving onward
	SynthDef(\test,{|freq|Out.ar(1,RLPF.ar(Saw.ar(freq.lag(1),0.1*EnvGen.kr(Env.linen(0.05,0.5,2))),freq*2+1500,2))}).add;

		~song.sections.do{|i| ~song.lyrics[i].postln};
		SystemClock.sched(0.5+~song.durTill(0,2),{(\note:[-5,-3,-2,2,5,7],\strum:0.03,\sustain:2).play});
		Ptpar([

			0,Pseq([ //bass notes
				(note: -24-5,amp:3, sustain:0.5+~song.durs[0].list.sum+~song.durs[1].list.sum,\dur:~song.secDur[0]+0.5),
				(note: -12-5,amp:3, sustain:~song.secDur[1]),
			]),
			0.52,Pseq([
				~song.pbind[0],
				Ptpar([ //sec1
					0,~song.pbind[1], //tune 
					~song.durTill(1,2)+(~song.durs[1].list[3]/2), //make durAt method
					Pseq([(\note:[-5,-2,0,4,7],\strum:0.03,\dur:1,sustain:2)])
				]),
				Ppar([ //sec2
					~song.pbind[2], //tune
					Prout.new({//bassnotes
							Pbind(\dur, ~song.durs[2]++Pseq([1.0]), 
							\note, Pseq([-2,-2,-2,0,-7,\r,\r,-2,-2,-2, 0,\r,-10])-24,\amp,2,
							\legato,Pseq([1 ,1, 1,1, 1.5,1,1, 1, 1, 1, 2, 1, 1])
						).play}
					)
				]),
				Ppar([ //sec3
					~song.pbind[3], 
					Prout({ var notes=~song.tune[3].list, width=0.01;
						Pbind(\dur,~song.durs[3]++Pseq([1]), \instrument,\test,
						\lag,Pwhite(-1*width,width),
						\midinote,Pseq([\r]++notes.copyRange(1,notes.size)++[79])-24).play})
					]),
				Ppar([ //sec4
					~song.pbind[4],
					Pbindf(Panola.new("r c#2 e a1\\pdur[2.2]").asPbind,\dur,~song.durs[4],\tempo,1,\amp,0.8)
				]),
			]);
		]).play
	
)
TempoClock.tempo=1
( //scheduling
	var sec={|sec| ~song.secDur[0..sec].sum};
	{
		c=TempoClock.new(seconds:-0.5);
		(note: -24-5,amp:3, sustain:0.5+~song.durs[0].list.sum+~song.durs[1].list.sum,\dur:~song.secDur[0]+0.5).play;
		0.4.wait;
		c.sched(0,				{~song.pbind[0].play});
		c.sched(~song.secDur[0],{~song.pbind[1].play});
		c.sched(sec.(1),		{
								~song.pbind[2].play; 
								Pbind(\dur, ~song.durs[2]++Pseq([1.7]), \note, Pseq([-2,-2,-2,0,-7,\r,\r,-2,-2,-2, 0, \r, -10])-24,\amp,2,\legato,Pseq(1!10++[1.9,1,1])).play;
		});
		c.sched(sec.(2),		{
			~song.pbind[3].play;
			Pbind(\dur,~song.durs[3]++Pseq([1]),\instrument,\test,\lag,Pwhite(-0.01,0.01),\midinote,Pseq([\r]++~song.tune[3].list.copyRange(1,~song.tune[3].list.size)++[79])-24).play;
		});
		c.sched(sec.(3),		{~song.pbind[4].play});
	}.fork
)


(//how to make overlapping sections: wrap in an event!
	c=TempoClock.new;
	Pseq([
		(play: {
			Pbind(\note,Pseq([1,3,2,4,5],5),\dur,Pwhite(0.2,1)).play(c)
		},\dur:3),
		(play:{
			Pbind(\dur,Pseq([1,1,0.5],3)).play(c)
		},dur:3)
		,
		Ppar([
			Pbind(\note,Pseq([9,8,7,6,5]),\dur,1,\sustain,6),
		(play:{c.tempo=0.3})
	])
	]).play(c)
)
c.tempo;



( //redo with keys
	a=List.newClear(8);
	a[0]=(
		f:{Pbind(\dur,Pwhite(0.2,1.0),\note,Pwhite(1,3.0),\amp,(Pwhite(0.2,0.5))).play},
		when:2,
		play:{ TempoClock.sched(~when,~f) }
	);
)
(
	a[1]=(
		f:{Pbind(\dur,Pwhite(3.3,4.2),\note,Pwhite(-7,-11),\sustain,Pwhite(2.0,3.0),\amp,1).play},
		when:5,
		play:{ TempoClock.sched(~when,~f) }
	)
)

a[1]
a[0].play; // play at scheduled time
a.f;
a.f.play; //play now

~playem={a.do{|i|i.play}}; //play timeline
~playSec={|section| //play from section
	var startTime=~song.secDur[0..section].sum; 
	a.do{|i| (i.when>startTime).if{
		i.play
}}};

~playem.();
(///2.0

	song: [
		" lyrics ", "panola", //1
		" lyrics ", "panola", //2
		],
	durs: [],

	sections:[
		list:[ //1
			some Pdef ??? - can be defined and redefined below I suppose - the key would help
			some Pbind,
			( some event with offset in syllables ),
			some Pseq
		],
		list:[ //2
			some Pbind,
			( some event with offset in syllables ),
			some Pseq
		],
	]

	play: method to play sections
	reshaper: method to record durs
	cursor:
	locate: method to convert [section,syllable] pair to seconds AND/OR
	locate: method to convert [section,*string*] pair to seconds
)


////as event
(
	~sections=(
		wibbles:(parent:~song,
			start:3,
			music: {Pbind(\dur,Pwhite(0.1,0.3),\note,Pwhite(0,1.0))},
		).
		bassnotes:(parent:~song,
			start:2,
			music: (note:-20,sustain:5,amp:1),
		),
	)
)

(
	~song.cursor_(2);
	~sections.wibbles.p;
	~sections.do({|i| i.p});
)
(
	~song.cursor_(0);
	~sections=();
	~sections.strum1=(parent:~song, start:0,
		music:(\lag: ~song.durTill(0,2),\note:[-5,-3,-2,2,5,7],\strum:0.03,\sustain:2));
	~sections.bassnote=(parent:~song, start:0,
		music:(note:-24+rrand(0,0.01),\amp:rrand(0.5,1),\sustain:5,\lag:rand(0.02)));
	~sections.heartActionBass=(parent:~song, start:2,
		music: Pbind(\dur, ~song.durs[2]++Pseq([1.0]), 
			\note, Pseq([-2,-2,-2,0,-7,\r,\r,-2,-2,-2, 0,\r,-10])-24,\amp,2,
			\legato,Pseq([1 ,1, 1,1, 1.5,1,1, 1, 1, 1, 2, 1, 1]))
		);
	~song.pbind.do({|i x| var label = ("guide"++x).asSymbol; ~sections[label]=(parent:~song,start:x,music:i);label.postln});
	~sections.weeeeuw=(parent:~song,start:2,music:{{Out.ar(0,FreeVerb.ar(Ringz.ar(WhiteNoise.ar(0.01),XLine.kr(2500,240,6),1),room:8,mix:7)*EnvGen.kr(Env.perc(0,7),doneAction:2))}});

	//SynthDef(\test,{|freq|Out.ar(1,RLPF.ar(Saw.ar(freq.lag(1),0.1*EnvGen.kr(Env.linen(0.05,0.5,2))),freq*2+1500,2))}).add;
	~sections.andthe=(parent:~song,start:3,
				music:Pbind(\dur,~song.durs[3]++Pseq([1]), \instrument,\test,
				\lag,Pwhite(-0.01,0.01),
				\midinote,Pseq([\r]++~song.tune[3].list.copyRange(1,~song.tune[3].list.size)++[79])-24));

~sections.do({|i| i.p});
)
~sections.weeeeuw.music;

~song.cursor_(2);
s.boot;
~song.cursor;
~sections.strum1.p;
~sections.bassnote.p;
~sections.bassnote.secDur[0];
~sections.heartActionBass.when;
~song.secDur[0];
~song.secDur[1];
~song.secDur[2];
~song.secDur[2]-~song.secDur[0];
~
|2|3|
~song.durs[2].list;
~song.secDur;
~song.sections;
~sections.do({|i| i.p});
~song.durs;
