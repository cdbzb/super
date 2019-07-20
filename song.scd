( //load song from disk
Archive.global.put(\song,~song);
Archive.write("/Users/michael/tank/super/theExtreme3")
)

( // the song event
	"/Users/michael/tank/super/song-Synthdefs.scd".load;
	~song=(
		song:[
			"the extreme power of the","g a b- d5 b-4 a g",
			"alien mind will make the -","e5 d c f e f g f",
			"r r r r heart action dan ger ous ly high- ", "r r r r  c6 a5 f b- a g f g ",
			" - and the body functions will", "a5 c d a g a d a ", 
			" race r r many times their natural me-", "g5 r r  e5 g5 a4 g5 f e g ",
			"tabolism so we're going to have to", " f5 e d c r g#4 a b c5 d e ",
			" mo- ni- tor this very", "d5 c4 a4 f f5 e ",
			"carefully","e5 d b4 r r r",
			"r r r well... I ", "r r r a g#",
			//"guess that's as read- y as I'm gon- na be...",""
		],
		sections: {|self|self.song.size/2},
		cursor:0,
		lyrics:{|self| self.song.copySeries(0,2,self.song.size)},
		tune:{|self| var array = self.song.copySeries(1,3,self.song.size);
				array.collect({|string| Panola.new(string).midinotePattern})},
		dursFile:"/Users/michael/tank/super/theExtreme3",
		setupDurs:{|self|self.dursFile.isNil.if(
				{Pseq([1])!self.sections},
				{var a; Archive.read(self.dursFile);a=Archive.at(\song);
					self.durs=a.durs++(Pseq([1])!self.sections-a.durs.size); //copy and pad
			})},
		pbind:{|self | (0..self.sections-1).collect{|i| Pbind(\dur,self.durs[i],\midinote,self.tune[i])}},
		secDur:{|self | (0..self.sections-1).collect{|i| self.durs[i].list.sum} },
		secLoc:{|self| [0]++self.sections.asInt.collect({|i| self.secDur[0..i].sum}) },
		durTill:{|self sec till | self.durs[sec].list[0..till].sum},
		pbindFrom:{|self from=3| var list=self.pbind[from.asInt..(self.sections-1).asInt].postln;Pseq(list).postln},
		when: {|self| self.secDur[self.start]}, //for sections
		p:{|self|(self.start<self.cursor).not.if{ var offset;
			self.syl.isNil.if({offset=0;"offset 0".postln},{offset=self.durTill(self.start,self.syl)});
			TempoClock.sched(
				(self.secLoc[self.start]-self.secLoc[self.cursor])+offset,
				{self.music.play})};self}, //for sections
	)
)

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
a=~recorder.(~song,[8],3);
a.makeWindow;
)
( ////as 'sections' event
	//~song.cursor_(0);
	~song.setupDurs;
	~sections=(
		ply:{|self| self.do({|i| i.p});};
	);
	~sections.strum1=(parent:~song, start:0,syl:2,
		music:(\note:[-5,-3,-2,2,5,7],\strum:0.03,\sustain:2));
	~sections.strum2=(parent:~song, start:1,syl:2,
		music: (\lag:~song.durs[1].list[3]/2,\note:[-5,-2,0,4,7],\strum:0.03,\sustain:2));
	~sections.bassnote=(parent:~song, start:0,
		music: (note: -24-5,amp:3, sustain:0.5+~song.secDur[0]+~song.secDur[1],\dur:~song.secDur[0]+0.5));
	~sections.bassnote2=(parent:~song, start:1,
		music: (note: -12-5,amp:3, sustain:~song.secDur[1]));
	~sections.heartActionBass=(parent:~song, start:2,
		music: Pbind(\dur, ~song.durs[2]++Pseq([1.0]), 
			\note, Pseq([-2,-2,-2,0,-7,\r,\r,-2,-2,-2, 0,\r,-10])-24,\amp,2,
			\legato,Pseq([1 ,1, 1,1, 1.5,1,1, 1, 1, 1, 2, 1, 1])));


	~sections.weeeeuw=(parent:~song,start:2,music:{{Out.ar(0,FreeVerb.ar(Ringz.ar(WhiteNoise.ar(0.01),XLine.kr(2500,240,6),1),room:8,mix:7)*EnvGen.kr(Env.perc(0,7),doneAction:2))}});
	~sections.weeeeuw.music= Pfxb.new(Pbind(\midinote,Pseries(60+36,-0.99,100),\dur,0.1,\sustain,1,\amp,0.01),\flanger);
	SynthDef(\test,{|freq amp=1|Out.ar(1,amp*RLPF.ar(Saw.ar(freq.lag(2),0.1*EnvGen.kr(Env.linen(0.05,0.5,2))),freq*2+1500+SinOsc.ar(5.2,0,350),2))}).add;
	///tempo map for drums
	d= ~song.durs[2].list[0..3] ++ ((~song.durs[2].list[4]/2)!2).asList ++ ~song.durs[2].list[5..8];
	~dquarters=(d/4).round(1).asInt.collect({|i|d[i..(i+4)].sum });
	~dquarters=2.collect({|i| i=i*4; d[i..(i+4)].sum });
	///
	~sections.drums=(parent:~song,start:2,music:
		Pbind( \instrument, Pseq([\kick2, \rest, \snare, \rest, \kick2, \kick2, \snare,\rest]++
	                             [\kick2, \rest, \snare, \rest, \kick2,  \kick2, \snare,\rest]),
		\dur,Pseq(d,inf),
		\lag,Pseq([0,0,-0.01,0,0,0,0,0],inf),
		//\amp,0.5
		\amp,Pseg([0.5,0.5,0.3]*0.5,[d[0..4].sum,d.sum-d[0..4].sum+1])
	));

	~sections.cymbal=(parent:~song,start:2,music:
	Pbind( \instrument, Pseq([\rest, \rest, \rest, \rest, \rest, \rest, \rest,\rest]++
	[\rest, \rest, \rest, \rest, \cymbal, \rest, \rest,\rest]),
	\dur,Pseq(d,2),\lag,-0.05,\amp,0.4));
	SynthDef (\cymbal, {|amp=1| var sig=PinkNoise.ar(EnvGen.kr(Env.perc(0,2)))!2; sig=TwoTube.ar(RHPF.ar(sig,500,9),d1length:502,d2length:777,loss:0.99)*0.5;Out.ar(0,sig*amp)} ).add;
	~sections.hat=(parent:~song,start:2,music:
	Pbind(\instrument, \hihat, 
		\ffreq,Pwhite(4000,10000),
		//\dur,(Pser(d,48)),
		\dur,(Pser(d/4,96)),
		\amp,Pseg([0.5,0.5,0]*0.15,[d[0..4].sum,d.sum-d[0..4].sum+4.2]))
);
	~sections.andthe=(parent:~song,start:3,
				music:Pbind(\dur,~song.durs[3]++Pseq([1]), \instrument,\test,
				\amp,1,
				\lag,Pwhite(-0.01,0.01),
				\midinote,Pseq([\r]++~song.tune[3].list.copyRange(1,~song.tune[3].list.size)++[79])-24));
	~sections.strum3=(parent:~song,start:4,music:
				(\note: [4,16,19]-12,\dur:3,\strum: 0.03);
			);
	~sections.bass3=(parent:~song,start:4,
				music:Pbindf(Panola.new("r c#2 e a1\\pdur[2.2]").asPbind,\dur,~song.durs[4],\tempo,1,\amp,0.8));
	~sections.bass5=(parent:~song,start:5, music: 
				Pbind(\midinote,(Pser(~song.tune[5].list,4)++Pseq([71,71-7]))-36,
				\dur,Pseq(~song.durs[5].list[0..3]++~song.durs[5].list[4..6].sum++1),
				\amp,0.8,
				\lag,Pwhite(-0.02,0.02));
			);
~sections.drums5=(parent:~song,start:5,music:
		Pbind( \instrument, Pseq([\kick2, \kick2, \snare, \kick2, \kick2,] ),
		\dur,Pseq(~song.durs[5].list[0..3]++~song.durs[5].list[4..6].sum++1),
		//\lag,Pseq([0,0,-0.01,0,0,0,0,0],inf),
		//\amp,0.5
		//\amp,Pseg([0.5,0.5,0.3]*0.5,[d[0..4].sum,d.sum-d[0..4].sum+1])
	));

	~sections.hat5=(parent:~song,start:5,music:
	Pbind(\instrument, \hihat, 
		\ffreq,Pwhite(4000,11000),
		//\dur,(Pser(d,48)),
		//\dur,(Pser(d/4,96)),
		\dur,Pseq(((~song.durs[5].list[0..3]++~song.durs[5].list[4..6].sum++1)/2).stutter(2)),
		\amp,Pseq([1,0.4]*0.1,4))
);
	~sections.bassnote6=(parent:~song,start:6,music:
		Pbindf(Panola(" a1 g f").asPbind,\dur,Pseq([~song.durs[6].list[1..2].sum]++~song.durs[6].list[3..4]),\tempo,1,\amp,0.8)
	);

	~sections.pad6=(parent:~song,start:6,music:
		{
			 a=(instrument:\sawSynth,midinote:[69,72,77],att:2,rel:3,amp:0.05,lagTime:0.2).play;
			 //a.set(\freq,[69,74,77].midicps)
			(type:\set,id:a[\id],freq:[69,74,77].midicps,lag:1.1).play;
			(type:\set,id:a[\id],freq:[71,74,77].midicps,lag:2.25).play
		});

	~sections.cymbal5=(parent:~song,start:5,music:
	(\instrument:\cymbal,\lag:~song.durs[5].list[1..4].sum););

	~sections.tremolo6=(parent:~song,start:6,syl:5,music:
		Pbind(\insrument, \pluck, \note,[7-12,7]*[1,2],\dur,Pwhite(0.05,0.1),\strum,0.01 ,\amp,Pseg([0.2,0.5*Pwhite(0.8,1.2,inf)*0.0001]*0.3,[5.1,1.9],\exp,\offset,0))
	);
	~sections.bass8=(parent:~song,start:8,music:
	Pbind(\note,Pseq([5,4,2,1]-24),\dur,~song.durs[8],\amp,0.5)
);
	~sections.bass8Alt=(parent:~song,start:8,music:
	Pbind(\instrument,\test,\note,Pseq([5,4])-[0+rand(0.02),12],\lag,Pseq([0,0]),\amp,0.5));
	~sections.strum8=(parent:~song,start:8,syl:1,music:
	(note:[1,4,9]-12++[1,4],strum:0.04,sustain:2,lag:0.52,amp:0.05)
	);
	~song.pbind.do({|i x| var label = ("guide"++x).asSymbol; ~sections[label]=(parent:~song,start:x,music:i);label.postln});
	{s.sync;~sections.do({|i| i.p})}.fork;
)


( /// make the beats regular
)
(
	~sections.drums=(parent:~song,start:2,music:
		Pbind( \instrument, Pseq([\kick2, \rest, \snare, \rest, \kick2, \kick2, \snare,\rest],2),
		\dur,Pseq(d,inf),
		\lag,Pseq([0,0,-0.01,0,0,0,0,0],inf)
	));
	~sections.hat=(parent:~song,start:2,music:
	Pbind(\instrument, \hihat, \ffreq,Pwhite(9000,11000),\dur,(Pseq(d,inf)),\amp,0.05))
	//~sections.bassnote2.music;
	//~sections.bassnote2;
)
~sections.do({|i|i.p});
