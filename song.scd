( // the song event				{{{1
	s.options.memSize=2**17;
	s.waitForBoot("/Users/michael/tank/super/song-Synthdefs.scd".load);
	~funs=(		//				{{{2
		sections: {|self|self.song.size/2},
		cursor:0,
		lyrics:{|self| self.song.copySeries(0,2,self.song.size)},
		tune:{|self| var array = self.song.copySeries(1,3,self.song.size);
				array.collect({|string| Panola.new(string).midinotePattern})},
		setupDurs:{|self|
				var a; Archive.read(self.dursFile);
				"read".postln;
				Archive.at(self.key).isNil.not.if(
					{
						a=Archive.at(self.key);
						self.durs=a++(Pseq([1])!(self.sections-a.size)); //copy and pad
					},{
						self.durs=Pseq([1])!self.sections
					}
				)
			},
		pbind:{|self | (0..self.sections-1).collect{|i| Pbind(\dur,self.durs[i],\midinote,self.tune[i])}},
		secDur:{|self | (0..self.sections-1).collect{|i| self.durs[i].list.sum} },
		secLoc:{|self| [0]++self.sections.asInt.collect({|i| self.secDur[0..i].sum}) },
		durTill:{|self sec till | self.durs[sec].list[0..till].sum}, //in a given section
		pbindFrom:{|self from=3| var list=self.pbind[from.asInt..(self.sections-1).asInt].postln;Pseq(list).postln},
		when: {|self| self.secDur[self.start]}, //for sections
		p:{|self|(self.start<self.cursor).not.if{ var offset;
			self.syl.isNil.if({offset=0;"offset 0".postln},{offset=self.durTill(self.start,self.syl)});
			TempoClock.sched(
				(self.secLoc[self.start]-self.secLoc[self.cursor])+offset,
				{self.music.play})};self}, //for sections
		durTillEnd: {|self| var x=0; (self.cursor..(self.sections-1)).do{|i| x=x+self.secDur[i] };x}
	);

	~trek=(	//					{{{2
		dursFile:"/Users/michael/tank/super/theExtreme3",
		durs:nil,
		save:{|self| Archive.global.put(self.key,self.durs); Archive.write(self.dursFile)},
	);	

	~xtreme=( //				{{{2
		key:\song, parent:~trek, proto:~funs,
		song:[
			"the extreme power of the","g a b- d5 b-4 a g", //0
			"alien mind will make the -","e5 d c f e f g f", //1
			"r r r r heart action dan ger ous ly high- ", "r r r r  c6 a5 f b- a g f g ", //2
			" - and the body functions will", "a5 c d a g a d a ", //3
			" race r r many times their natural me-", "g5 r r  e5 g5 a4 g5 f e g ", //4
			"tabolism so we're going to have to", " f5 e d c r g#4 a b c5 d e ", //5
			" mo- ni- tor this very", "d5 c4 a4 f f5 e ", //6
			"carefully","e5 d b4 r r r", //7
			"r r r well... I ", "r r r a g#", //8
			"guess that's as read- y as I'm gon- na ","g e- f g e- d- e- f g ", //9
			"be. Rea- dy Sar- gon","a d5 c a4 f#", //10
		],
		parts:nil,
	).setupDurs;

//construct event recorder		{{{2
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
			});
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
						var elements=song.tune[i].list.size;
						elements.do(
							{|i| 
								if(recorded.size>0)
								{returnChunk.add(recorded.removeAt(0)) }
							}
						);
						(returnChunk[0].isNil.not).if{song.durs[i]=Pseq(returnChunk)} ;
					});
					//~xtreme.durs[nextTune]= Pseq(recorded);
				};
			)
		};

//// 'sections' event		{{{2
	~sections=( ply:{|self| self.do({|i| i.p});};);
	~xtreme.parts=~sections;

	~sections.strum1=(parent:~xtreme, start:0,syl:2, music:(\note:[-5,-3,-2,2,5,7],\strum:0.03,\sustain:2));
	~sections.bassnote=(parent:~xtreme, start:0, music: (note: -24-5,amp:3, sustain:0.5+~xtreme.secDur[0]+~xtreme.secDur[1],\dur:~xtreme.secDur[0]+0.5));
	~sections.strum2=(parent:~xtreme, start:1,syl:2, music: (lag:~xtreme.durs[1].list[3]/2,note:[-5,-2,0,4,7],strum:0.03,sustain:2));
	~sections.bassnote2=(parent:~xtreme, start:1,
		music: (note: -12-5,amp:3, sustain:~xtreme.secDur[1]));
	~sections.heartActionBass=(parent:~xtreme, start:2,
		music: Pbind(\dur, ~xtreme.durs[2]++Pseq([1.0]), 
			\note, Pseq([-2,-2,-2,0,-7,\r,\r,-2,-2,-2, 0,\r,-10])-24,\amp,2,
			\legato,Pseq([1 ,1, 1,1, 1.5,1,1, 1, 1, 1, 2, 1, 1])));
	~sections.weeeeuw=(parent:~xtreme,start:2,music:
		{{Out.ar(0,FreeVerb.ar(Ringz.ar(WhiteNoise.ar(0.01),XLine.kr(2500,240,6),1),room:8,mix:7)*EnvGen.kr(Env.perc(0,7),doneAction:2))}});
	~sections.weeeeuw.music= Pfxb.new(Pbind(\midinote,Pseries(60+36,-0.99,100),\dur,0.1,\sustain,1,\amp,0.01),\two_tube);

	///tempo map for drums
	d= ~xtreme.durs[2].list[0..3] ++ ((~xtreme.durs[2].list[4]/2)!2).asList ++ ~xtreme.durs[2].list[5..8];
	~dquarters=(d/4).round(1).asInt.collect({|i|d[i..(i+4)].sum });
	~dquarters=2.collect({|i| i=i*4; d[i..(i+4)].sum });
	///
	~sections.drums=(parent:~xtreme,start:2,music:
		Pbind( \instrument, Pseq([\kick2, \rest, \snare, \rest, \kick2, \kick2, \snare,\rest]++
	                             [\kick2, \rest, \snare, \rest, \kick2,  \kick2, \snare,\rest]),
		\dur,Pseq(d,inf),
		\lag,Pseq([0,0,-0.01,0,0,0,0,0],inf),
		//\amp,0.5
		\amp,Pseg([0.5,0.5,0.3]*0.5,[d[0..4].sum,d.sum-d[0..4].sum+1])
	));

	~sections.cymbal=(parent:~xtreme,start:2,music:
		Pbind( \instrument, Pseq([\rest, \rest, \rest, \rest, \rest, \rest, \rest,\rest]++
		[\rest, \rest, \rest, \rest, \cymbal, \rest, \rest,\rest]),
		\dur,Pseq(d,2),\lag,-0.05,\amp,0.4));
	SynthDef (\cymbal, {|amp=1 length=2| 
		var sig=PinkNoise.ar(EnvGen.kr(Env.perc(0,length)))!2; 
		sig=TwoTube.ar(RHPF.ar(sig,500,9),d1length:502,d2length:777,loss:0.99)*0.5;
		Out.ar(0,sig*amp)}
	).add;
	~sections.hat=(parent:~xtreme,start:2,music:
		Pbind(\instrument, \hihat, 
			\ffreq,Pwhite(4000,10000),
			//\dur,(Pser(d,48)),
			\dur,(Pser(d/4,96)),
			\amp,Pseg([0.5,0.5,0]*0.15,[d[0..4].sum,d.sum-d[0..4].sum+4.2]))
	);
	~sections.andthe=(parent:~xtreme,start:3,
				music:Pbind(\dur,~xtreme.durs[3]++Pseq([1]), \instrument,\test,
				\amp,1,
				\lag,Pwhite(-0.01,0.01),
				\midinote,Pseq([\r]++~xtreme.tune[3].list.copyRange(1,~xtreme.tune[3].list.size)++[79])-24));
	~sections.strum3=(parent:~xtreme,start:4,music:
				(\note: [4,16,19]-12,\dur:3,\strum: 0.03);
			);
	~sections.bass3=(parent:~xtreme,start:4,
				music:Pbindf(Panola.new("r c#2 e a1\\pdur[2.2]").asPbind,\dur,~xtreme.durs[4],\tempo,1,\amp,0.8));
	~sections.bass5=(parent:~xtreme,start:5, music: 
				Pbind(\midinote,(Pser(~xtreme.tune[5].list,4)++Pseq([71,71-7]))-36,
				\dur,Pseq(~xtreme.durs[5].list[0..3]++~xtreme.durs[5].list[4..6].sum++1),
				\amp,0.8,
				\lag,Pwhite(-0.02,0.02));
			);
~sections.drums5=(parent:~xtreme,start:5,music:
		Pbind( \instrument, Pseq([\kick2, \kick2, \snare, \kick2, \kick2,] ),
		\dur,Pseq(~xtreme.durs[5].list[0..3]++~xtreme.durs[5].list[4..6].sum++1),
		//\lag,Pseq([0,0,-0.01,0,0,0,0,0],inf),
		//\amp,0.5
		//\amp,Pseg([0.5,0.5,0.3]*0.5,[d[0..4].sum,d.sum-d[0..4].sum+1])
	));

	~sections.hat5=(parent:~xtreme,start:5,music:
	Pbind(\instrument, \hihat, 
		\ffreq,Pwhite(4000,11000),
		//\dur,(Pser(d,48)),
		//\dur,(Pser(d/4,96)),
		\dur,Pseq(((~xtreme.durs[5].list[0..3]++~xtreme.durs[5].list[4..6].sum++1)/2).stutter(2)),
		\amp,Pseq([1,0.4]*0.1,4))
);
	~sections.bassnote6=(parent:~xtreme,start:6,music:
		Pbindf(Panola(" a1 g f").asPbind,\dur,Pseq([~xtreme.durs[6].list[1..2].sum]++~xtreme.durs[6].list[3..4]),\tempo,1,\amp,0.8)
	);

	~sections.pad6=(parent:~xtreme,start:6,music:
		{
			 a=(instrument:\sawSynth,midinote:[69,72,77],att:2,rel:3,amp:0.05,lagTime:0.2).play;
			 //a.set(\freq,[69,74,77].midicps)
			(type:\set,id:a[\id],freq:[69,74,77].midicps,lag:1.1).play;
			(type:\set,id:a[\id],freq:[71,74,77].midicps,lag:2.25).play
		});

	~sections.cymbal5=(parent:~xtreme,start:5,music:
	(\instrument:\cymbal,\lag:~xtreme.durs[5].list[1..4].sum););

	~sections.tremolo6=(parent:~xtreme,start:6,syl:5,music:
		Pbind(\insrument, \pluck, \note,[7-12,7]*[1,2],\dur,Pwhite(0.05,0.1),\strum,0.01 ,\amp,Pseg([0.2,0.5*Pwhite(0.8,1.2,inf)*0.0001]*0.3,[5.1,1.9],\exp,\offset,0))
	);
	~sections.bass8=(parent:~xtreme,start:8,music:
	Pbind(\note,Pseq([5,4,2,1]-24),\dur,~xtreme.durs[8],\amp,0.5)
);
	~sections.bass8Alt=(parent:~xtreme,start:8,music:
		Pbind(\instrument,\test,\note,Pseq([5,4])-[0+rand(0.02),12],\lag,Pseq([0,0]),\amp,0.5)
	);
	~sections.strum8=(parent:~xtreme,start:8,syl:1,music:
	(note:[1,4,9]-12++[1,4],strum:0.04,sustain:2,lag:0.52,amp:0.05)
	);
	~sections.strum9=(parent:~xtreme,start:9,music:
		(midinote:~panNotes.(" <g b- e-5 g5>").flatten-12,strum:0.042)
	);
	
	~sections.bass9=(parent:~xtreme,start:9,music:
		(note:~panNotes.("e-2").flatten-60,dur:2,amp:0.3)
	);
	
	~sections.tremoChord=(parent:~xtreme,start:10,music:
		Pfxb(
			Pfindur(~xtreme.durs[10].list[0],
				Ppar(
					[-3,0,3,5].collect{|i| 
						Pbind(
							\note,i,
							\dur,Pwhite(0.05,0.08),
							\amp,Pseg([0.02,0.13,0.15,0],[0.3,0.3,1.9]),
							\pan,0.5
						)
						}.value;
					)
			),\verb_fade,\time,2
		);
	);

	~sections.tremoChord2=(parent:~xtreme,start:10,syl:0,music:
		Pfxb(
			Pfindur(~xtreme.durs[10].list[1..4].sum-0.1,
				Ppar(
					[-3,0,2,6].collect{|i| 
						Pbind(
							\note,i,
							\dur,Pwhite(0.05,0.08),
							\amp,Pseg([0.02,0.17,0.15,0],[0.4,0.6,1.9]),
							\pan,-0.5
						)
						}.value;
					)
			),\verb_fade,\time,2
		);
	);

	~xtreme.pbind.do({|i x| var label = ("guide"++x).asSymbol; ~sections[label]=(parent:~xtreme,start:x,music:i);label.postln});
	c=SystemClock.seconds;

 //transformation			{{{2
	~transformation={ var dur=15;
		var pitches=~panNotes.("f#3 b- c4 e")+[0,12];
		////whrrrrr
		var chord=pitches.collect({|item index|  Synth(\trans,[\freq,item.midicps,\amp,0.1])});
		var chord2=pitches.collect({|item index|  Synth(\trans,[\freq,item.midicps,\amp,0.1])});
		pitches.postln;
		{dur.wait;chord.do{|i|i.release}}.fork;
		{dur.wait;chord2.do{|i|i.release};5.wait;((SystemClock.seconds-c).postln)}.fork;
		////cymbal
		(instrument:\cymbal,length:8).play;
		////strings
		~synful.setprog(3,5,0);
		~synful.setprog(4,5,1);
		~synful.node[1]=\filter->{|in| FreeVerb.ar(in,room:0.75,mix:0.55)*3};
		{
			8.wait;"now!".postln;127.do( {|i|~synful.expression((127-i),0);~synful.expression((127-i),1);0.18.wait} )}.fork;
			(type:\midi,midiout:~synful.controller.midi,\midinote:~panNotes.("f#3 b- c4 e").flatten-[0,12],dur:20).play;
			(type:\midi,midiout:~synful.controller.midi,\channel:2,\midinote:~panNotes.("f#3 b-4 c4 e").flatten-24,dur:20).play;
		~synful.expression(127,0);
		~synful.expression(127,1);
		//~synful.init;
	}
);

( // ~complete lyric and tune	{{{1
	~complete=(
		key:\complete,
		parent:~trek,
		proto:~funs,
		song:[
			"the tran - fer is com-"," f5 c a-4 e c#", //0
			"plete. metabolic rate is","c#4 c5 b-4 c5 a-4 d4 c5",//1
			"double and rising, Doctor...r  Hel- ","d5 b-4 c#5 g c# a-4 g r b",//2
			"lo. r r r"," c#5 d2 d d",//3
			"you are a lovely female, r a","e5 d c# b4 a f# e e2 c#4",//4
			"pleasant sight to wake up to after","e4 d c# d e b a f# a ", //5
			"half a million years- r r ","f5 g f e  e d c# c#",//6
			"r r you're welcome","d5 f4  g5 f ",//7
			"I've forgotten what it fee-","g#4 e b f# a# b c#5",//8 
			"ls like even to brea-","d#5 a#4 c#5 d# e f# ",//9 
			"th again, Sargon?"," g#5 f# b4 g g",//10
			//"Here, in this body","f e g f c"//11
		]
	).setupDurs;
)

(
	a=~recorder.(~complete,[11],2);
	a.makeWindow;
)
Pseq(~complete.pbind).play
( //// parts for ~complete		{{{1
	~complete.cursor_(6); //	{{{2
	"/Users/michael/tank/super/song-hello-beet.scd".load;
	TempoClock.tempo=1;
	~sections2=(
		ply:{|self| self.do({|i| i.p});};
	);
	~complete.parts=~sections2;

	//0							{{{2
	~sections2.bassnotes=(parent:~complete,start:0,syl:3,music:
		Pseq([
			(note:1-24,amp:0.5,dur:~complete.durs[0].list[4]), 
			(note:1-24,amp:0.6,dur:5,sustain:2)
		])
	);

//SynthDef(\phaser,{|out depth=0.5 fb=0.3 rate=0.03| 
//		ReplaceOut.ar(
//			out,Phaser2.ar(In.ar(out,2)+
//				PlateReverb.ar( In.ar(out,2),mix:Env.linen(0,2.5,6).kr)
//				,rate:rate,fb:fb,depth:depth))}
//			).add;
//

	SynthDef(\phaser ,{|out depth=0.5 fb=0.3 rate=0.03 gate=1| 
		XOut.ar(
			out,Env.cutoff(6).kr(gate),Phaser2.ar(In.ar(out,2)+
				PlateReverb.ar( In.ar(out,2),mix:Env.linen(0,2.5,6).kr)
				,rate:rate,fb:fb,depth:depth))}
			).add;

	~sections2.chord0=(parent:~complete,start:0,syl:3,music:
		Pfx(
			Pseq([
				(note:[1,8,13]-24,instrument:\sawSynth,release:4,strum:0.03,dur:~complete.durs[0].list[4]),
				(note:[1,8,13]-24,instrument:\sawSynth,release:5,strum:0.03,dur:11)
			]),\phaser
		)
	);
//	~sections2.bassnotes2=(parent:~complete,start:1,syl:2,music:
//		(note:2,amp:0.1)
//	);
//1					{{{2
	~sections2.bassnotes3=(parent:~complete,start:2,music:
		(note:-2-12,amp:0.1)
	);
	~sections2.bassnotes4=(parent:~complete,start:2,syl:2,music:
		(note:[7,-5],amp:0.1,sustain:2)
	);

	~sections2.pad0=(parent:~complete,start:0,music:
		Pbind(\midinote,Pseq(~complete.tune[0].list[0..3])-[0,12],\instrument,\sawSynth,\dur,~complete.durs[0]);
	);

	~sections2.helloImage=(parent:~complete,start:2,syl:8,music:
		{ { { a=Image.open("/Users/michael/tank/super/Spock.png");
					w=a.plot(freeOnClose:true).alwaysOnTop_(true);
					w.alwaysOnTop_(true);
				}.defer;
				5.wait;
				//{w.close}.defer;
			}.fork
		});

	//3 -                		{{{2
	~sections2.helloChord=(parent:~complete,start:3,music:
		(instrument:\test,midinote:~panNotes.("<d4 f# a c#>").flatten,strum:0.03,amp:0.4)
	);

	~helloTempo=1/~complete.durs[3].list.mean;
	~helloTemp2=1/(~complete.durs[4].list[0..6].sum/5*2);
	~sections2.helloImage=(parent:~complete,start:2,syl:8,music:
		{ { { a=Image.open("/Users/michael/tank/super/Spock.png");
					w=a.plot(freeOnClose:true).alwaysOnTop_(true);
					w.alwaysOnTop_(true);
				}.defer;
				5.wait;
				//{w.close}.defer;
			}.fork
		});

	~sections2.helloSequence=(parent:~complete,start:3,music:{
		//TempoClock.tempo_(~helloTempo);

	//3 -  ~helloBeat    		{{{2

	SynthDef(\phaser2,{|out=5 depth=0.5 fb=0.3 rate=0.03| 
		ReplaceOut.ar(
			out,Phaser2.ar(In.ar(out,1)+
				PlateReverb.ar( In.ar(out,1),mix:Env.linen(0,2.5,6).kr)
				,rate:rate,fb:fb,depth:depth))}
		).add;

	~kickPatterns=[[3/4,1/4],1];
	p=[0,0,0,0,1,1,1,0];
	~kickBar=Pseq(p.collect{|i|~kickPatterns[i]}.flatten);

	~snarePatterns=[[Rest(3/4),1/4],[Rest(1)],[Rest(1/2),1/2],[Rest(1/2),1/4,1/4],[Rest(1/4),1/4,1/2]];
	p=[0,1,2,0, 0,3,0,4];
	~snareBar=Pseq(p.collect{|i|~snarePatterns[i]}.flatten);

	~synth=
		Pbind(\note,Pseq([2-24,2-12,-1-12,9-12])-12,
		//Pbind(\note,Pseq([2-24,2-12,[-1-12,-1,6],[1,4,9-12]])-12, //)
			\instrument,\sawSynth,\dur,2,\rel,5,\amp,0.2)
		//.play
;

~helloBass1=Pbind(
	\note, Pseq([2,4],4)-24,
	\legato,Pseq([1,Pwhite(0.25,0.55,1)],4),
	\amp,0.5
)
//.play	
;
~helloBass2=Pbind(
	\note,Pseq([\r,2,0],8),
	\dur,Pseq([1/2,1/4,1/4],inf),
	\amp,0.04
)
//.play
;

	~helloBeat= {|synthamp=0.3 drumsamp=1 tempo1=(52/60) tempo2=(50/60)|
	
	Ppar([
		Pbind(\tempo,Pseq([tempo1,tempo2]),\dur,4,\note,\r),

		Pbind(\instrument,\kick1,
			\dur,~kickBar,
			\amp,drumsamp*0.1
		),
		//Pbus(
			Pbind(\instrument,\hihat, //ffreq rel
				\dur,Pseq([0.245,0.255],32),
				\amp,Pseq([Pwhite(0.3,0.4,1),Pwhite(0.2,0.3,1)],32)*0.4*drumsamp,
				\lag, Pseq(
					(1!16++(-1!16)).scramble*0.003),
					\ffreq, Pwhite(6000,6500),
					\rel,0.15
				),
		//	),
		Pbind(\instrument,\snare,
			\dur,~snareBar,
			\amp,drumsamp*0.1
		),
	
		Pfx(
			Pbind( \instrument,\sawSynth,
			\note,Pser(~panNotes.("d f# a c#5 e5").flatten-60,16),
			\dur,1/2,
			\att,0.5,
			\octave,Pser(4!5++(5!5)++(6!5)++(7!5),42),
			\amp, Pseq(( 0.1!5 )++(0.09!5)++(0.08!5)++Pseries(0.07,-0.005))
		),
		\phaser2),
//		~helloBass1,
		//~helloBass2,
		Pset(\amp,synthamp,~synth),
		//Pseq([(\type:\rest,dur:4),~complete.pbind[4]]);//remove
		
	//	Ptpar([
	//		0.15,~helloGtr1,
	//		0.15,~helloGtr2
	//	])
		],1   /// repeats!!
	)};
	
//	~helloBeat.(synthamp:0.18,drumsamp:0.35).play;
//}.fork

	t=TempoClock.new;		            
	~helloBeat.(synthamp:0.1,drumsamp:0.7,tempo1:~helloTempo,tempo2:~helloTemp2).play(t);
	});
// 4-6 {{{2
	~sections2.bass4=(parent:~complete,start:4,syl:6,music:
		(instrument:\sawSynth,note:[7,-5]-12,amp:0.2,sustain:2,att:1.0,rel:3)
	);
	~sections2.bass5=(parent:~complete,start:5,syl:4,music:
		(instrument:\sawSynth,note:[7,-5]-13,amp:0.2,sustain:2,att:1.0,rel:3)
	);

	~phrase6quarter=~complete.durs[6].list.[0..6].sum/6;

	~sections2.bass6=(parent:~complete,start:6,music:
		Pseq([
			(note:5-24,dur:~phrase6quarter*3,amp:0.5),
			(note:4-24,dur:~phrase6quarter,amp:0.5),
			(note:7-24,dur:~phrase6quarter*4,amp:0.5),
		]));

	//harp		{{{3
	SynthDef.new(\harp, { |gate=1 out=0 freq = 400|
		var in=PinkNoise.ar(1);
		var sig=Pluck.ar(in: in,  gate: gate,  maxdelaytime: 0.02,  delaytime: 1/freq,  decaytime: 10,  coef: 0.5,  mul: 1,  add: 0);
		Out.ar(out,sig);
	},  rates: nil,  prependArgs: nil,  variants: nil,  metadata: nil).add;


	SynthDef.new(\yowbass, {|freq=400 amp gate=1 dur=1|
		var sig=Formant.ar(freq,  formfreq: Line.kr(3060,00,dur),  bwfreq: 880,  mul: 1,  add: 0).distort;
		var env=Env.asr(0,1,1,1.5).kr(gate:gate,doneAction:2);
		Out.ar(0,sig*env*amp!2)}
		,  rates: nil,  prependArgs: nil,  variants: nil,  metadata: nil).add;

		~durs6=~complete.durs[6].list;

	~sections2.yow6=(parent:~complete,start:6,music:
		Pbind(\instrument,\yowbass,
			\note,Pseq([[-3,0],[-3,0],[-5,-1]]),
			\dur,Pseq( [~durs6[0..2].sum,~durs6[3],~durs6[4..8].sum]),
			\amp,0.03,
		),
);

	~sections2.yow7=(parent:~complete,start:7,syl:0,music:
	(instrument:\yowbass,note:[-3,0,5],dur:3,amp:0.05)
);
	~sections2.keys6=(parent:~complete,start:6,music:
		Pbind(
			\instrument,\harp,
			\midinote,Pseq(~panNotes.("f5 a4 c5")-[0,12]),
			\dur,//Pseq(
				~
				complete.durs[6].list.[0..1]
				.sum/4
			//) //make a function for this
		)
	);

	//stab		{{{3
	SynthDef.new(\stab, {|out=0 freq=400 width=0.2 gate=1 amp=1|
		var sig=Pulse.ar(freq,width);
		var env=Env.asr(0.06,0.1,0.4).kr(gate:gate,doneAction:2);
		var fenv=Env.linen(0.0,0.1,0.7).kr(gate:gate)*freq*5;
		sig=RLPF.ar(sig,fenv,rq: 1);
		Out.ar(out, sig*env*amp);
	},  rates: nil,  prependArgs: nil,  variants: nil,  metadata: nil).add;

	~sections2.keys62=(parent:~complete,start:6,syl:5,music:
		Pbind(
			\instrument,\stab,
			\note,Pseq([ [7,9,13],[7,9,13],[5,9,14] ]),
			\dur, Pseq(~complete.durs[6].list.[6..7]++[1]) ,
			\amp,Pseq([1,1.3,1])*0.8,
		)
	);
	// 7 on {{{2

	~sections2.bass7=(parent:~complete,start:7,syl:0,music:
		Pseq([
			(note:5-24,dur:~phrase6quarter*3,amp:0.5),
			//(note:4-24,dur:~phrase6quarter,amp:0.5),
			//(note:7-24,dur:~phrase6quarter*2,amp:0.5),
		]));

	~sections2.keys7=(parent:~complete,start:7,syl:0,music:
		Pbind(
			\instrument,\harp,
			\midinote,Pseq(~panNotes.("f5 a4 c5")-[0,12]),
			\dur,//Pseq(
				~
				complete.durs[7].list.[1..2]
				.sum/4
			//) //make a function for this
		)
	);

	~sections2.trombone8=(parent:~complete,start:8,music:
		{ | amp=0.9 exp=90|
			~synful.node[1]=\filter -> {|in| PlateReverb.ar(in,mix:0.7,decayTime:0.4,size:0.8)} ;
			//~synful.controller.gui;
			~synful.controller.loaded;
			~synful.expression(90,3);
			~synful.setprog(57,0,3);// program bank  channel trombone
			Pseq([
			(type:\midi,midiout:~synful.controller.midi, \midinote:~panNotes.("g# ").flatten-[12,36], \chan:3, dur:~complete.durs[8].list.sum,\amp:0.75).play
			,
			(type:\midi,midiout:~synful.controller.midi, \midinote:~panNotes.("c# ").flatten-[12,36], \chan:3, dur:~complete.durs[9].list.sum,\amp:0.75),
			(type:\midi,midiout:~synful.controller.midi, \midinote:~panNotes.("<b e>").flat-[24,36], \chan:3, dur:3,\amp:0.75)
		])
			}
		);

	~sections2.sargon10=(parent:~complete,start:10,syl:2,music:
		Pseq([
			(note:[4,7,10],dur:~complete.durs[10].list[3],\amp:0.3),
			(note:[4,7,10],dur:~complete.durs[10].list[4],\amp:0.3)
		])
	);

	~complete.pbind.do({|i x| var label = ("guide"++x).asSymbol; ~sections2[label]=(parent:~complete,start:x,music:i);label.postln});

	~complete.parts.ply;
)

~synful.init;
( //moving on to next song		{{{1
	~xtreme.cursor_(0);
	~complete.cursor_(0);
	TempoClock.tempo=1;
	{
		//~synful.init;
		~synful.controller.loaded==false.if({~synful.init;10.wait});
		~xtreme.parts.ply;
		//SystemClock.sched( ~xtreme.durTillEnd,~transformation);
		~xtreme.durTillEnd.wait;
		TempoClock.tempo=0.7;
		~transformation.fork(TempoClock);
		//{a=Image.open("/Users/michael/tank/super/Spock.png")}.defer;
		//{w=a.plot(freeOnClose:true).alwaysOnTop_(true);}.defer;
		13.wait;
		//{w.close}.defer;
		(note:[0,1,2]-48,\amp:2,\sustain:5).play;
		TempoClock.tempo=1;
		~complete.parts.ply;
	//~complete.parts.ply;
	}.fork
)
