( // the song event				{{{1
	~syn1=~synful.();
	s.options.memSize=2**17;
	s.waitForBoot("/Users/michael/tank/super/song-Synthdefs.scd".load);
	~funs=(		//				{{{2
		sections: {|self|self.song.size/2},
		cursor:0,
		lag:0,
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
			offset=offset+self.lag;
			TempoClock.sched(
				(self.secLoc[self.start]-self.secLoc[self.cursor])+offset,
				{self.music.play})};self}, //for sections
		durTillEnd: {|self| var x=0; (self.cursor..(self.sections-1)).do{|i| x=x+self.secDur[i] };x},
		parse:	{|self phrase array start=0| //array of rhythms
			var counter = 0;
			var beatNum = array.flatten.collect{|m i| array.flatten.[0..i].sum};
			beatNum = beatNum.collect{|i|(i-0.001).floor};
			array.collect{ |item|
				item.isArray.not.if(
					{
						var b=beatNum[counter];
						counter=counter+1;
						item*self.durs[phrase].list[b+start]
					},
					{
						var subArray=item.collect{|i x| 
							var b = beatNum[counter+x];
							i*self.durs[phrase].list[b+start]
						}; 
						counter=counter+item.size; 
						subArray.sum;
					}
				);
			}
		};
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
			(type:\kset,id:a[\id],freq:[71,74,77].midicps,lag:2.25).play
		});

	~sections.cymbal5=(parent:~xtreme,start:5,music:
	(\instrument:\cymbal,\lag:~xtreme.durs[5].list[1..4].sum););

	~sections.tremolo6=(parent:~xtreme,start:6,syl:5,music:
		Pbind(/*\instrument,  \pluck ,*/ \note,[7-12,7]*[1,2],\dur,Pwhite(0.05,0.1),\strum,0.01 ,\amp,Pseg([0.2,0.5*Pwhite(0.8,1.2,inf)*0.0001]*0.3,[5.1,1.9],\exp,\offset,0)) //TODO set synth
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
		~syn1.setprog(3,5,0);
		~syn1.setprog(4,5,1);
		~syn1.node[1]=\filter->{|in| FreeVerb.ar(in,room:0.75,mix:0.55)*3};
		{
			8.wait;"now!".postln;127.do( {|i|~syn1.expression((127-i),0);~syn1.expression((127-i),1);0.18.wait} )}.fork;
			(type:\midi,midiout:~syn1.controller.midi,\midinote:~panNotes.("f#3 b- c4 e").flatten-[0,12],dur:20).play;
			(type:\midi,midiout:~syn1.controller.midi,\channel:2,\midinote:~panNotes.("f#3 b-4 c4 e").flatten-24,dur:20).play;
		~syn1.expression(127,0);
		~syn1.expression(127,1);
		//~syn1.init;
	}
);

( // ~complete lyric and tune	{{{1
	//~syn1.controller.loaded.not.if({~syn1.init});

	~complete=(
		key:\complete, parent:~trek, proto:~funs,
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
			"Here, in this body","f e g f c"//11
		]
	).setupDurs;
)

(
	a=~recorder.(~complete,[11],2);
	a.makeWindow;
)
Pseq(~complete.pbind).play
( //// parts for ~complete		{{{1
	~complete.cursor_(0); //	{{{2
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

	~sections2.pad8=(parent:~complete,start:8,music:
	{
		var du=~complete.durs[8].list;
		var dv=~complete.durs[9].list;
		a=(instrument:\sawSynth,midinote:[4,8,11]+60,att:4.5,rel:5,amp:0.05,lagTime:0.3).play;
		Pbind.new(*[
			type:\set,
			id:a[\id],
			freq: Pseq([ [4,8,11],[3,6,11],[3,6,10],[1,6,10],[1,4,10],[-1,4,8] ]+72).midicps ,
			dur:Pseq([du[0..1].sum,du[2..3].sum,du[4..6].sum,dv[0..1].sum,dv[2..5].sum,1 ])
		]).play;
	}
		  );

	~sections2.trombone8=(parent:~complete,start:8,music:
		{ | amp=0.9 exp=80|
			~syn1.node[1]=\filter -> {|in| PlateReverb.ar(in,mix:0.7,decayTime:0.4,size:0.8)} ;
			~syn1.patch(\trombone,\none,3);
			Pbind(*[
				type:\midi, midiout:~syn1.controller.midi, chan:3,
				midinote: Pseq(~noteList.(["g#","c#","b3"]))-[12,36] ,
				dur:Pseq([~complete.secDur[8],~complete.secDur[9],3]),
				\amp:0.55
			]).play;
			}
		);

	~sections2.sargon10=(parent:~complete,start:10,syl:2,music:
		Pseq([
			(note:[4,7,10],dur:~complete.durs[10].list[3],\amp:0.3),
			(note:[4,7,10],dur:~complete.durs[10].list[4],\amp:0.3)
		])
	);

	~sections2.pf11=(parent:~complete,start:11,music:
		Ppar([
			//(instrument:\cymbal,dur:13)
			//,
			Pbind(*[
				midinote:Pseq(
					~noteList.(["<a c5 f>","<g c5 e>","<b- d5 g>","<a c5 f>"])-12),
					dur:~complete.durs[11],
					strum:Pseq([0.01,0.01,0.02,0.01])
				]),
				Pbind(*[
					instrument:\test,
					amp:0.5,
					midinote:Pseq(
						~panList.("c g3 f c4"))-[ 12,24 ]-7,
					dur:~complete.durs[11],
				])
		])
	);

	~complete.pbind.do({|i x| var label = ("guide"++x).asSymbol; ~sections2[label]=(parent:~complete,start:x,music:i);label.postln});

	~complete.loaded.isNil.not.if({~complete.parts.ply});

	~complete.loaded=1;
)

~syn1.init;
( // xtreme-complete transition study		{{{1
	~xtreme.cursor_(0);
	~complete.cursor_(0);
	TempoClock.tempo=1;
	{
		//~syn1.init;
		~syn1.controller.loaded==false.if({~syn1.init;10.wait});
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

(// trill{{{1
	~trill={ |instrument=\default amp=0.1 |
		//Pfindur(5,
			Pbind(*[
				instrument:instrument,
				note:Pseq([6,8],100),
				dur:Pwhite(0.1,0.12)*0.8,
				amp:Pwhite(0.1,0.11)*amp,
				pan:rrand(-1,1)
			]).play
		//).play
	};
	//~trill.value(\test);
	//~trill.value;

	~syn1.patch(\violins,\arco,1); //put these into the Pbind
	~syn1.patch(\clarinet,\none,0); //put these into the Pbind
		~synTrill=
		{|chan=1 amp=0.3 transpose=0 len=6|
			Pfindur(len,
				Pbind(*[
					type:\midi,midiout:~syn1.controller.midi,
					note:Pseq([6,8],inf)+transpose,
					dur:Pwhite(0.1,0.12)*0.8,
					amp:Pwhite(0.1,0.11),
					pan:rrand(-1,1),
					amp:amp,
					chan:chan
				]));
			};
	~trill.value(\test);
	~trill.value;
			//~synTrill.value().play;
			~synTrill.value(0,2.9).play;
			~synTrill.value(1,1.9,4).play;
)
(//trill with preroll {{{2
	~complete.cursor_(8);
	{
		~complete.parts.ply;
		~complete.durTillEnd.wait;
		~trill.value;
	}.fork;
);
(// ~displeased lyric and tune {{{1
~displeased=(
	key:\displeased, parent:~trek, proto:~funs,
	song: [
		"trill","r",//0
		"I am not displeased my husband- ","d#5 c# c a#4 g# f# f d# c# " ,//1
		"r your body is r r  not unlike ","c#3 f4 d# c# g#3 f#2 f# f#4 f d#",//2
		"that which was your own (dum dum dum)","d-4 c d- b-3  g-3 f g- a-",//3
		"and i too am pleased beloved","f# e g f# f# e d c#",//4 -or Bb!
		" boom after so- long... ","d3 a b e4 d f",//5
		"(boom)...so very long... Kiss","g3 b c4 a3 e4 r",//6
		"r r r r r r r r ..","g#5 f# d# b4 a# g# e5 d# ",//7
		" r","f#4",//8
	]
).setupDurs;
)

(
	~afterSoLong=[4,5,8,7,9]++[5,6,4,7] + [ 2,2,2,2,2,2,2,2,3 ].collect{|i| [0,i]};
	(degree:1,octave:4,dur:6).play;
	Pbind(*[legato:1.05,degree:Pseq(~afterSoLong)-1,dur:Pseq( 0.5!4++[2.5]++(0.5!3)++[2])]).play;
	Pbind(*[degree:Pseq([1,-3]),dur:Pseq([4,5])]).play;

)
~displeased.tune[6].list'
(
	a=~recorder.(~displeased,[7],1);
	a.makeWindow;
)
~displeased.save;
( 
	~displeased.cursor_(1); //	{{{2
	~trillLength=5;

	~sections3=(ply:{|self| self.do({|i| i.p});};);~displeased.parts=~sections3;


	// this should be a function
	~displeased.pbind.do({|i x| var label = ("guide"++x).asSymbol; ~sections3[label]=(parent:~displeased,start:x,music:i);label.postln});

	{

		a=~synTrill.value(0,0.9,12,len:22);
		b=~synTrill.value(1,1.9,4,len:22);
		~syn1.expression(40,1);
		~syn1.expression(30,0);
		~syn1.node[1]=\filter->{|in| PlateReverb.ar(in,mix:0.5,decayTime:0.55)};
		~syn1.node[2]=\filter->{|in| Phaser2.ar(in,rate:0.1,fb:0.5)*5};

		~sections3.trill=(parent:~displeased,start:-1,music:
			{{ a=a.play; b=b.play; }}
		);

		~sections3.continueTrill=(parent:~displeased,start:0,music:
			{{ a.isPlaying.not.if(a=a.play;b=b.play);  }}
		);

		~sections3.stopTrill=(parent:~displeased,start:2,music: {{a.stop;b.stop}} );

		~displeased.parts.ply;
	}.fork
);

( ~excellent=( //		{{{1
		key:\excellent, parent:~trek, proto:~funs, song:[
			"this is an excellent body Doctor"," c5 a4 c b- c5 d  e- d c b-4",//0
			"I seem to have received the ","",//1
			"best of the three",""//2
			"strength, hearing,eyesight",""//3
			"all far above their normal range",""//4
		]
	);
)

(~unnecessary=( //		{{{1
	key:\unnecessary, parent:~trek, proto:~funs, 
	song:[
		"that will be unneccesary Doctor"," d# e f# d# g# f# e d# d# c#",//0
		"r this Vulcan body is adapted to the","r b b g# f# e f# g# f# e d# e",//1
		"r r higher metabolism"," f#3 f# a5 g# b a g# f# e ",//2
		"it won't work, Sargon!","d#5 b4 g5 d# b4",//3
		"you have to get out before you","f d- e- f a f g a",//4
		//"kill them! we will transfer at once un-","",//5
		//"til you can administer the ","",//6
		//"metabolic reduction injection... a ","",//7
		//"what? I'll prepare the formula Sargon","",//8
		//"Henoch, your condition","",//9
		//"r I can continue in this body r for several hours","d3 f#4 d f# e c# d e d g3 a2 e d c# c# b",//10
		//"fortunate we will exit at once...","c5 a4 e a3 b c a2 e4 f# g# e g# a#",//11
	]
	).setupDurs;

~unnecessary.durs[1]=Pseq([1,1,1.5,0.25,0.25+0.5, 0.5,0.5,0.25,0.25+0.5,0.5,0.5,0.5]);
~unnecessary.durs[1]=Pseq((~unnecessary.durs[1].list!2).flatten	);

)
(
	a=~recorder.(~unnecessary,[0]);
	a.makeWindow;
)
	~unnecessary.save;
( //	unnecessary sections	{{{2
		//	bass	{{{3
	var bass=NodeProxy.audio(s,2).play;
	~notes=[1,3,6,4].collect{|i| i!4}.flatten;
	
	SynthDef(\bl,{|gate=1 out=0 freq=400 t_trig=0  |
		var sig= SawDPW.ar(freq*[1,2],0,0.04 );  // add these octaves better
		//var env=Decay.kr(t_trig,0.4) ;
		var env= Env.perc(0.00,0.3,curve:\sin).kr(0,gate:t_trig) ;
		sig= sig+CombN.ar(sig, 1, 0.35,  decaytime: 3,  mul: 0.5,  add: 0);
		sig=DFM1.ar(sig,1800,0,5.9);//.distort;
		Out.ar(out,sig*env!2);
	}).add;
	bass[1]=\filterIn->{|in|in+CombN.ar(in,1,0.25/TempoClock.tempo,2,mul:0.8)/2};
	bass.set(\wet1,0.8);
	bass[2]=\filter->{|in| Phaser1.ar(in,  depth: 0.5,  rate: 0.2,  fb: 0.3,  cfb: 0.1,  rot: 1.5707963267949) };

	//	drums	{{{3
~kpat2=([1,1,0,1]!4).flatten;
~spat2=([0,0,0,0,1,0,0,0.6]!4).flatten;
~tk=();
~tk.add(\kick->Pbind(*[
	instrument:\kick2,
	amp:Pseq(~kpat2,3)/6,
	dur:0.5	,
	out:[0,1]
]));

~tk.add(\snare->
	Pbind(*[
		instrument:\snare,
		amp:
		Pseq(~spat2.flatten,3)/7
		,
		dur:0.25,
		out:[0,1]
	]);
);


~tk.add(\hat->
	Pbind(*[
		instrument:\hihat,
		dur:Pwrand([1/4,Pseq([1/16],4)],[0.95,0.05],inf),
		//offset:-0.35,
		att:Pwhite(0,0.01),
		pan:0.4,
		amp:0.04])
	);
//;
//h[1]=\filterIn->{|in| Klank.ar(`[[1100,1200,2500],nil,0.04],in)};h.set(\wet1,0.5);
//h
//.play;

//	synths	{{{3
~octaveWrap={|i a=7| (i>a).if({i-8},i)};
SynthDef(\pulse,{|gate=1 freq=400 amp=1 ffreq=4500 rel=2 out=0 t_trig wiggle=500| //		{{{4
	var sig=Pulse.ar(freq,SinOsc.kr(8.55,0,0.6,0.4));
	var env= Env.perc(0,rel).kr(0,gate:t_trig)*amp;
	//var env=0.1;
	sig= MoogFF.ar(sig,SinOsc.kr(0.3,0,wiggle,1150));
	sig=HPF.ar(sig,500);
	Out.ar(0,sig*env!2)}).add;


~tk.add(\pulse-> //		{{{4
		Pbind(*[ 
			instrument:\pulse,
			degree:Pseq(([\r,1,5,1,\r,0,5,0,\r,1,5,1]++[\r,1,6,1]).flatten,3)-1,
			dur:0.5,
			root:4,
			sustain:2,
			octave:6,
			amp:0.17
		]);
);

//	h=NodeProxy.audio;

~tk.add(\saw-> //		{{{4
	Pbind(*[ 
		instrument:\sawSynth,
		att:0.05,
		rel:5,
		degree:Pseq(
			[1,3,0,3,7,3,7,4].collect{|i|~octaveWrap.(i,6)}-1
			,4
		),
		//degree:Pseq([[1,3],5,[2,0],5,[1,-1],5,[1,-1],6]-1,4),
		root:4,
		octave:6,
	]);
);


	~unnecessary.cursor_(0); //		{{{1
	TempoClock.tempo=1;

	~sections5=(ply:{|self| self.do({|i| i.p});};);~unnecessary.parts=~sections5;

	~sections5.unnecessary=(parent:~unnecessary,start:0,music:~unnecessary.pbind[0]);

	~sections5.tempo1=(parent:~unnecessary,start:0,music:{{TempoClock.tempo=1}.play});
	~sections5.tempo2=(parent:~unnecessary,start:1,music:{{TempoClock.tempo=1.2}.play});

	~sections5.descant=(parent:~unnecessary,start:0,music:
		Pbind(*[ 
			instrument:\sawSynth,
			degree:Pseq([\r,8,7,6,5,5,4.1])-1,
			att:0.7,
			root:4,
			dur:Pseq(
				[~unnecessary.durTill(0,3)]++~unnecessary.durs[0].list [4..9]++[0.5,2]
			)
		])
	);

	~sections5.unnecBass=(parent:~unnecessary,start:0,music:
		Pbind(*[
			instrument:\sawSynth,
			degree:Pseq([5,2])-1,
			rel:4,
			dur:~unnecessary.durTill(0,7),
			//dur:Pseq([2.3,1]),
			root:4,
			octave:3
		])
	);
	

	//TempoClock.tempo;
	~sections5.bass1=(parent:~unnecessary,start:1,music: {bass[0]=Pseq([Rest(8),Pmono(\bl,\degree,Pseq(~notes,4)-1,\dur,0.5,\root,4,\octave,2,\trig,Pseq(1!16))])});

	~sections5.leadIn=(parent:~unnecessary,start:1,music:
		Pfindur(16,
			Ppar([
				//Pseq([~unnecessary.pbind[1]],4).play; 
				~tk.at(\snare),
				~tk.at(\kick),
				~tk.at(\pulse),
				~tk.at(\saw),
				~tk.at(\hat)
			])
		)
	);

	~sections5.bass2=(parent:~unnecessary,start:2,music: 
				{bass[0]=Pmono(
					\bl,
					\degree, Pseq([ 2,2,1,1 ])-1,
					//\dur,Pseq([0.5,1.5]*1.24,2),
					\dur,
					Pseq(
						[ ~unnecessary.durs[2].list[0] ,~unnecessary.durs[2].list[1..4].sum  , ~unnecessary.durs[2].list[5..6].sum,1])
					,
					\root,4,
					\octave,2,
					\trig,1);}
	);

	~sections5.metabolism=(parent:~unnecessary,start:2,music:
		//t=TempoClock.new.tempo_( 1.2 );
		//u=TempoClock.new.tempo_( t.tempo*0.666 );

		Pfindur(4,//12,
			Ppar([
				//Pseq(~unnecessary.pbind[1..2]),
				//a.[0]=Pmono(\bl,\degree,2-1,\dur,0.5,\root,4,\octave,2,\trig,1);
				~unnecessary.pbind[2],
				~tk.at(\hat),
				Pbindf(~tk.at(\pulse), \degree,Pseq([\r,-2,4,-2],1),\dur,0.662 ),//.play
				Pbindf(~tk.at(\saw), \degree,Pseq([-1,4,-1,3]) ),//( ,\dur,0.331),
				~tk.at(\snare),
			])
		);
		//~tk.at(\hat).play(u)

	);
~unnecessary.parts.ply;
~sections5.metabolism.p;
~unnecessary.parts.keys;
)

( //	metabolism sketh	{{{2
	t=TempoClock.new.tempo_( 1.2 );
	u=TempoClock.new.tempo_( t.tempo*0.666 );
	Pfindur(4,//12,
		Ppar([
			//Pseq(~unnecessary.pbind[1..2]),
			~unnecessary.pbind[2];
			//a.[0]=Pmono(\bl,\degree,2-1,\dur,0.5,\root,4,\octave,2,\trig,1);
			.[0]=Pmono(\bl,\degree,2-1,\dur,Pseq([0.5,1.5]*1.5,1),\root,4,\octave,2,\trig,1);
			~unnecessary.pbind[2],
			~tk.at(\hat),
			~tk.at(\saw),
			Pbindf(~tk.at(\pulse), \degree,Pseq([\r,-2,4,-2],1),\dur,0.662 )//.play
			,
			~tk.at(\snare),
		])
	).play(t);
	//~tk.at(\hat).play(u)

)
//~unnecessary.save;
~unnecessary.durs[2].list;

( //	tracklist	{{{1

	t=TempoClock.new.tempo_(1.2);
	a.[0]=Pmono(\bl,\degree,Pseq(~notes,4)-1,\dur,0.5,\root,4,\octave,2,\trig,1);
	Ppar([
		//Pseq([~unnecessary.pbind[1]],4).play; 
		~tk.at(\snare),
		~tk.at(\kick),
		~tk.at(\pulse),
		~tk.at(\saw),
		~tk.at(\hat)
	]).play(t);
)

(// drummachine //		{{{1
//	drums	{{{4
	~pat={|string perBar repeats| string.asDrumPat(perBar,repeats)};

	Pdef.new(\f,Pbind(*[
		instrument:\kick,
		amp:1,
		dur:~pat.("x0x0|x0x0|xx0x|xxxx",4,inf),
		//tempo:Pwhite(0.59,1.11,inf)
	]));
	SynthDef(\fb,
		{|out=1 |
			XOut.ar(out,0.3,
				FreeVerb.ar(In.ar(out,2),1.0,0.9)*1.2)}
	).add;
	SynthDef(\plate,{|out wet=1 |
		var in=In.ar(out);
		var sig = PlateReverb.ar(in);
		XOut.ar(out, wet, sig)}
	).add;
	SynthDef(\phaserr,{|out rate=0.1 fb=0.3|
		var sig = Phaser2.ar(In.ar(out),rate:rate,fb:fb);
		XOut.ar(out, 1, sig)}
	).add;
	SynthDef(\dst,{|out gain=1.5|
		var in=In.ar(out);
		var sig = ( in*gain ).distort;
		XOut.ar(out, 1, sig!2)}
	).add;
	Pdef.new(\q,Pfxb(
		Pbind(*[
			instrument:\snare,
			dur:~pat.("0000x000|0000x000|0000x00x|0000x00x",8,inf),
			amp:0.2
		]),
		//\fb
		//\phaserr
		\dst
	));
	a=Pdef.new(\h,Pbind(*[
		instrument:\hihat,
		amp:Pseq([0.1,0.2],inf*Pwhite(1,1.2,inf)),
		lag:Pseq([0,0.008],inf),
		dur:~pat.("xxxx",08,16)]));//.play
	a.quant=1;
	b=Pdef(\m,Pfxb(a,\phaserr,\fb,-0.99));
	c=Pseq([a,b],inf);

 // 'guitar-ish' //		{{{4
	SynthDef(\pluckD,{|freq=400 amp=1|
		var sig= Pluck.ar(WhiteNoise.ar(0.1),  trig: \trig.tr(1),  maxdelaytime: 0.2,  delaytime: freq.reciprocal,  decaytime: \del.kr(5),  coef: \coef.kr(0.6),  mul: 1,  add: 0) ;
		sig=CrossoverDistortion.ar(sig,\drive.kr(0.9),\smooth.kr(0.1));
		sig=Phaser2.ar(sig,0.5,0.15,rq:1);
		Out.ar(\out.ir,  sig*amp);
	}).add;
 
		Pdef(\a,Pfindur (8,Pmono(\pluckD,
			//\degree,Pwrand([[1,5]-17,[3,7]-17],[0.05,0.95],inf),
			\degree,Pseq([5,5,5,5,4,4,4,4,8,8,8,8,6,6,6,6],inf)+[0,5]-21,
			\out,[0,1],
			\smooth,Pwhite(0.2,0.3,inf),
			\del,Pwhite(0.5,1,inf),
			\dur,0.5,
			\coef,Pbrown(0.1,0.9,0.03),
			\lag,Pwhite(-0.01,0.01)
		)));
//Pdef(\a).play
	
		Pdef(\boodoo,Pbind(*[
			//instrument:\sawSynth,
			att:0,
			degree:Pseq([1,2,3,5,4,2,1],inf)-1,
			dur:Pseq([1,1,1,1,8,8,12]/4,inf),
			root:7,
			octave:2,
			amp:0.6
		])).quant([16,7])
		;
		//Pdef(\boodoo).play

	Ppar([ //		{{{4
		Pdef(\m),
		Pdef(\q),
		c,
		Pdef(\f),
		Pwrand([Pdef(\a),(note:Rest,dur:8)],[0.7,0.3],inf), //guitar
		Pseq([(note:Rest,dur:7+16),Pdef(\boodoo)]),
	]
	).play
)

( // fortunate   {{{1
~iCanContinue=(key:\iCanContinue,parent:~funs,proto:~trek,song:[
		"boom I can continue in this body","d3,f#4,d,f#,e,c#,d,g4",
		"boom for several hours"," r d c# b b a"
	]).setupDurs;
~fortu=(key:\fort,parent:~funs,proto:~trek,song:[
	"fortunate, x x x ","a5 e c a4 b c5",//0
	"x we'll leave  at once","e4 e5 f# g#  a#",//1 
	"(boom) this woman will assist me","b3 b4 f# g# a# f# b f#",//2 
	"(boom boom boom) lead me (boom) to your","c#3 c# d d5 c# d3 b4 a",//3
	"booom Pharmacology Laboratory","e3 e4 d e b3 d4 a3 b a g#",//4
	"boom","r"
]).setupDurs;
)
( //	recorder	{{{2
	a=~recorder.(~iCanContinue,[0],2);
	//a=~recorder.(~fortu,[4],1,2);
	a.makeWindow;
	//~fortu.save;
)
( //	~fortu sections	{{{2
	var t=TempoClock.new;
	~sections4=(ply:{|self| self.do({|i| i.p});};);~fortu.parts=~sections4; //make a parent

	SynthDef(\sq1,{ //		{{{3
		var vib = Vibrato.kr(\freq.kr(300,1),  rate: 6,  depth: \depth.kr(0.02),  delay: \delay.ir(0.1),  onset: \onset.ir(0.2),  rateVariation: 0.04,  depthVariation: 0.1,  iphase: 0,  trig: 0);
		var sig = Pulse.ar(vib, \width.kr(0.5,0.1) );
		var env = Env.adsr(0.05,0.25,0.8,1).kr(2,gate:\gate.kr(1));
		sig=LPF.ar(sig,3000,).distort;
		Out.ar(\out.ir(1),sig*env*0.1);
	}).add;

	~sections4.fortunate = (parent:~fortu,start:0,music: Pbind(*[ //		{{{3
		degree:Pseq([8,5,3])-1,
		scale:Scale.minor,
		root:9,
		//dur:   Pseq([1.0,0.5,2]),
		dur:~fortu.durs[0],
	])
);

~sections4.connector = (parent:~fortu,start:0,music: Pbind(*[ //		{{{3
	instrument:\sawSynth,
	rel:Pseq([2,2,2,4]),
	root:9,
	octave:[4,5.005],
	scale:Scale.minor,
	degree:Pseq([8,5,3,1])-1,
	//dur:   Pseq([1.0,0.5,0.5,2]),
	dur: ~fortu.durs[0]
])
);

~sections4.answer = (parent:~fortu,start:0,syl:2,music: //		{{{3
	Pbind(*[
		degree:Pseq([ 1,2,3,5-7 ])-1,
		root:9,
		octave:[3,4],
		scale:Scale.minor,
		dur:
		Pseq(
			~fortu.durs[0].list[3..5]++ (
				~fortu.durTill(1,3)+0.73)
	)
		,
		//dur:Pseq([1,0.5,0.5,5])
	])
);
//~sections4.answer.music.play;
~sections4.we_square = (parent:~fortu,start:1,syl:0,music: //		{{{3
	Pbind(*[
		//tempo:1.6,
		degree:Pseq([ 4,5,6,[7,5] ])-1,
		//dur:Pseq([0.5,1.5,0.5,2]),
		dur:Pseq(
			~fortu.durs[1].list[1..4] 
		),
		root:11	,
		octave:4,
		instrument:\sq1,
	])
);

~sections4.we_square2 = (parent:~fortu,start:1,syl:0, //		{{{3
	aa: ~fortu.durs[1].list,
	music: Pbind(*[
	instrument:\sq1,
	degree:Pseq([5,4,3])-1,
	dur:
	//Pseq( [~aa[1] + (~aa[2]*2/3) , ~aa[2]*1/3 + ~aa[3] , ~aa[4] ]),
	Pseq(~parse.(~fortu,1,[[1, 2/3],[1/3 ,1],1],start:1)),
	root:9,
	octave:4,
	width:0.1,
	//out:1
])
);


SynthDef(\oteypiano, { |out=0, freq=440,gate=1, amp=0.5,rho=1 | //		{{{3
	    var son = OteyPiano.ar(freq, amp, rho:rho)*EnvGen.ar(Env.asr(0,1,0.1),gate,doneAction:2);
	    Out.ar(out, Pan2.ar(son * 0.1  * \scale.kr(1,0.1), LinLin.kr(freq,36.midicps,90.midicps,-0.75,0.75)));
}).add;

~sections4.otey=(parent:~fortu,start:2,music: { //		{{{3
	//could put the node in a key to interact with
	a=NodeProxy.audio.play;
	a[1]=\filterIn->{|in| 
		var time = Line.kr(0.5,0.3,10);//duration should be from .durs
		PlateReverb.ar(in,   decayTime: time,  damping: 0.6,  diffusion: 1)};
	//a[1]=\filterIn->{|in| PlateReverb.ar(in,   decayTime: 0.5,  damping: 0.6,  diffusion: 1)};
	a.set(\wet1,0.7);
	{var wet=0.7;while({wet>0},{wet=wet-0.01;a.set(\wet1,wet);(24/70).wait})}.fork;//automate wet level
	a[0]= Pbind(*[
		instrument:\oteypiano,
		dur:Pseq(
			[ ~fortu.secDur[2]] ++ 
			~fortu.durs[3].list[0..1] ++
			[~fortu.durs[3].list[2..4].sum] ++
			[~fortu.durs[3].list[5..7].sum] ++
			[~fortu.secDur[4]]
		),
		degree:Pseq([6,7,7,8,8+7,9]) -1,
		octave:2,
		root:2
	]);
}
);

~sections4.a_chord=(parent:~fortu,start:5,music:(degree:[1,3,5,8,-6,-13,-9]-1,strum:0.05,dur:3,root:-3));
~sections4.gliss=  (parent:~fortu,start:5,music:{ ~gliss.(root:-3,amp:0.05) },lag:-1.5);

 //	trigger-echoFeedback	{{{3
	SynthDef.new(\twangInSweepDelay, {|freq=400 t_trig=0 gate=1 |
		var env = (Decay2.kr(t_trig, 0.01, 0.3));
		var sig= Pulse.ar(freq,  width: SinOsc.ar(1), mul: env);
		sig=CombN.ar(sig,1,0.31,5);
		sig=CombC.ar(sig,1,SinOsc.kr(0.1,0,0.2,0.21),4,mul:0.2);
		sig=FreeVerb.ar(sig,0.8,0.8);
		sig= Phaser2.ar(sig,  0.5, 0.1, 0.9,  cfb: 0.9,  rot: 1.5707963267949,  rq: 1);

		//var dummy= Env.cutoff(0.2).kr(1,gate:gate);
		Out.ar(0,sig!2);
	}).add;

	~sections4.sweep=(parent:~fortu,start:5,lag:-1.5,music:
		Pmono(*[
		//instrument:
		\twangInSweepDelay,
		trig:1,
		dur:0.3,
		degree:Prand([1,3,5,8]-1,12),
		root:-3,
	]));

~fortu.cursor_(0); //		{{{2

SynthDef(\delay,{|out wet=1 |
	var in=In.ar(out);
	var sig = CombC.ar(in,1,\delay.kr(0.2,0.1),\decay.kr(2));
	XOut.ar(out, wet, sig!2);
}
).add;

~sections4.leadMe=(parent:~fortu,start:3,syl:2,music:
	Pfx(
		PmonoArtic(*[
			//instrument:\pluck,
			//instrument:
			\sawSynth,
			att:0.7,
			rel:4!4,
			degree:Pseq([[8,6],[7,5],[3,6],[3,5],\r])-1,
			root:2,
			dur: Pseq(~parse.(~fortu,3,[1,[1,1],1,1],start:3)++5),
			legato: Pseq([1,0.99,1,1.95]),
			stretch: Pseq([1,1,1,13]),
			amp:0.15,
			out:3
		]),\delay,\wet,0.2,\delay,0.4,\decay,5
	)
);

//~sections4.tune2=(parent:~fortu,start:2,music:~fortu.pbind[2]);
//~sections4.tune3=(parent:~fortu,start:3,music:~fortu.pbind[3]);

~fortu.parts.ply;
)


//		ideas / sounds {{{1
( //	trigger-echoFeedback	{{{2
	SynthDef.new(\twangInSweepDelay, {|freq=400 t_trig=0 gate=1 |
		var env = (Decay2.kr(t_trig, 0.01, 0.3));
		var sig= Pulse.ar(freq,  width: SinOsc.ar(1), mul: env);
		sig=CombN.ar(sig,1,0.31,5);
		sig=CombC.ar(sig,1,SinOsc.kr(0.1,0,0.2,0.21),4,mul:0.2);
		sig=FreeVerb.ar(sig,0.8,0.8);
		sig= Phaser2.ar(sig,  0.5, 0.1, 0.9,  cfb: 0.9,  rot: 1.5707963267949,  rq: 1);

		//var dummy= Env.cutoff(0.2).kr(1,gate:gate);
		Out.ar(0,sig!2);

	},  rates: nil,  prependArgs: nil,  variants: nil,  metadata: nil).add;

	Pmono(*[
		//instrument:
		\twangInSweepDelay,
		trig:1,
		dur:1,
		freq:Pwhite(200,600,inf)
	]).play
)

( //savage bowing //		{{{2
	{
		//var force = LFSaw.kr(12).range(-0.20,0.8);
		var force=0.5;
		var scale=SinOsc.ar(0.01).range(0.2,1.2);
		var vel=SinOsc.kr(12+LFBrownNoise1.kr(1)).range(0,1);
		//var pos=0.2;
		var pos = LFBrownNoise1.kr(2).range(0.3,0.2);
		var sig = DWGBowed.ar(
			freq:[500, 440+LFBrownNoise0.kr(2).range(0,10)],  
			velb: vel,  
			force: force,  
			gate: 1,  
			pos: pos,  
			release: 0.1,  
			c1: 115,  //inverse of DC decaytime
			c3: 300, // hi freq decay 
			impZ: 0.55*LFBrownNoise1.kr(0.5).range(0.02,1),  
			fB: 2
		); //inharmonicity
		sig= DWGSoundBoard.ar(sig,  c1: 20,  c3: 100,  mix: 0.8,  d1: 199*scale,  d2: 211*scale,  d3: 223*scale,  d4: 227*scale,  d5: 229*scale,  d6: 233*scale,  d7: 239*scale,  d8: 241*scale);
		sig=HPF.ar(sig,300)*0.05;
		//sig =PlateReverb.ar(sig,mix:0.8);
	}.play
)

( //playable tremolo //		{{{2
	~trem={| scale=1 gate=1 out=0| //		{{{3
		//var force = LFSaw.kr(12).range(-0.20,0.8);
		var force=0.5;
		//var scale=SinOsc.ar(0.01).range(0.2,1.2);
		var vel=SinOsc.kr(\rate.kr(12)+LFBrownNoise1.kr(1)).range(0,1);//rate
		//var pos=0.2;
		var pos = LFBrownNoise1.kr(2).range(0.3,0.2);
		var env = Env.asr(0,1,0.5).kr(2,gate:gate);
		var sig = DWGBowed.ar(
			freq: \freq.kr(400,0.5) + LFBrownNoise0.kr(2).range(0,10),  
			velb: vel,  
			force: force,  
			gate: 1,  
			pos: pos,  
			release: 0.5,  
			c1: 15,  //inverse of DC decaytime
			c3: 30, // hi freq decay 
			//impZ: 0.55*LFBrownNoise1.kr(0.5).range(0.02,1),  
			fB: 2 //inharmonicity
		); 
		sig= DWGSoundBoard.ar(sig,  c1: 20,  c3: 100,  mix: 0.8,  d1: 199*scale,  d2: 211*scale,  d3: 223*scale,  d4: 227*scale,  d5: 229*scale,  d6: 233*scale,  d7: 239*scale,  d8: 241*scale);
		sig=HPF.ar(sig,300)*0.05;
		//sig =PlateReverb.ar(sig,mix:0.8);
		Out.ar(out, Splay.ar(sig*env));
	};

	~verb=NodeProxy.audio.(s,2).play(0); //		{{{3
	//~verb[1]=\filter->{|in | FreeVerb.ar(in,room:0.8,mix: \mix.kr(0.8))};
	~verb[0]=\filter->{|in mix=0.5| PlateReverb.ar(in,mix:mix ,decayTime:0.2)};

	~len=9;

	~aa=Pbind(*[
		instrument:~trem,
		out:~verb.bus,
		freq:Pwhite(399,499,~len)*[1,1.2],
		legato:1,
		scale:0.2,
		dur:2
	]);
	Ppar([ //		{{{3
		~aa,
		Pbind(*[ dur:Pseq([1],	~len*2) ]),//pf quarters
	]).play
)

~verb.source;//.id;
~verb.set(\mix,0.3);
(type:\set,id:~verb.synth.id,mix:0).play;
(instrument:~trem,out:~verb.bus,degree:[1,3,5,8],dur:8).play;

s.boot;

( //envelope version //		{{{2
	~blurt={
		arg gate=1,freq=400;
		var scale=SinOsc.ar(0.01).range(0.2,1.2);
		var force=0.5;
		var vel = Env.sine(1/12).kr(2,gate:gate);
		//var vel=SinOsc.kr(12+LFBrownNoise1.kr(1)).range(0,1);
		//var pos= LFSaw.kr(Rand(1,2));
		//var pos=0.2;
		var pos = LFBrownNoise1.kr(2).range(0.3,0.2);
		var sig = DWGBowed.ar(
			freq:[500,freq+LFBrownNoise0.kr(2).range(0,10)],  
			velb: vel,  
			force: force,  
			gate: 1,  
			pos: pos,  
			release: 0.1,  
			c1: 115,  //inverse of DC decaytime
			c3: 300, // hi freq decay 
			impZ: 0.55*LFBrownNoise1.kr(0.5).range(0.02,1),  
			fB: 2
		); //inharmonicity
		sig= DWGSoundBoard.ar(sig,  c1: 20,  c3: 100,  mix: 0.8,  d1: 199*scale,  d2: 211*scale,  d3: 223*scale,  d4: 227*scale,  d5: 229*scale,  d6: 233*scale,  d7: 239*scale,  d8: 241*scale);
		sig=HPF.ar(sig,300)*0.05;
		//sig =PlateReverb.ar(sig,mix:0.8);
};//.play;


	Ppar([
		Pdef(\m),
		Pdef(\q),
		c,
		Pdef(\f),
		Pwrand([Pdef(\a),(note:Rest,dur:4)],[0.7,0.3],inf), //guita
	]
	).play;
Pbind(*[
	instrument:~blurt,
	//dur:Pwrand([0.125,Pseq([0.125/3],3)],[0.97,0.03],inf),
	dur:0.125,
	freq:300,
	]).play;
Pbind(*[
	instrument:~blurt,
	dur:0.5,
	freq:600,
	lag:0.02,
	]).play
)

//	list comprehensions	{{{1
all {:x,x<-[1,3,4],x.odd,var z=x+1,::[z,x].postln};
//so... get a section using list comprehensions
~xtreme.parts;
all {:x,x<-~xtreme.parts,x.class==Event,x.start==3}
a= all {:x,x<-~xtreme.parts.keys,var y=~xtreme.parts[x],y.class==Event,y.start==3 }
~xtreme.cursor_(3);
all {:x,x<-~xtreme.parts.keys,var y=~xtreme.parts[x],y.class==Event,y.start==3,::y.p };
a;
a.class
Array;
[dur:3].p.play
s.reboot;


//	rhythm parsing	{{{1
		z=[1,2/3,[1/3,1],1,]
		f=z.flatten.collect{|m i|z.flatten[0..i].sum};
		g=f.collect{|i|(i-0.001).floor};
(
	~parse={|song phrase array start=0| //array of rhythms
		var counter = 0;
		var beatNum = array.flatten.collect{|m i| array.flatten.[0..i].sum};
		beatNum = beatNum.collect{|i|(i-0.001).floor};
		array.collect{ |item|
			item.isArray.not.if(
				{
					var b=beatNum[counter];
					counter=counter+1;
					item*song.durs[phrase].list[b+start]
				},
				{
					var subArray=item.collect{|i x| 
						var b = beatNum[counter+x];
						i*song.durs[phrase].list[b+start]
					}; 
					counter=counter+item.size; 
					subArray.sum;
				}
			);
		}
	};
~parse.(~fortu,1,z);
)
//	END-JUNK	{{{1

~syn1.init;

(
	(\type:\midi,\midicmd:\control,\ctlNum:11,\midiout:~syn1.controller.midi,\control:12).play;
	a.play;
)
Pfunc

numPseries.new(127,  step: -1, 127);

Pbind(*[
	num: Pseries.new(127,  step: -1,  length: 127) ,
	dur:0.1,
	doit:Pfunc({~syn1.expression(self.num,self.chan)})
	
])				

Pchain.new(patterns: [  ])
~syn1;

(// or....
	~syn1.expression(100);
	(\midinote:60,dur:13,\type:\midi,\midiout:~syn1.controller.midi,chan:0).play;
Pbind(*[
	dur:0.05,
	env:Pseg.new(levels:[127,120,30,0],durs:[5,10,10],curves:\lin),
	//control:Pfunc.new{~syn1.expression(Pkey(\env).round)},
	dev:Pfunc{postln(Pkey(\dur))},
]).play
)

Pkey
Ptime
//Ptime.collect(function)
// Latch.kr - make a synth that discretizes



(
	SynthDef(\wha, //		{{{4
		{
			var freq=300;
			var env=Env([1,[1.1,1.11],1.1],[[\len.ir(1),1.1],2],releaseNode:2).kr(0,gate:\gate.kr(1));
			var envV= Env.linen(0.5,1.5, 2,  level: 1.0,  curve: \lin).kr(0,gate:1);
			var sig= SawDPW.ar(freq*env,0,0.1)*envV;
			sig=CombN.ar(sig,0.7,0.63,9);
			DetectSilence.ar(sig,doneAction:2);
			Out.ar (0, sig )
		}
	).add;

	Pn(  //		{{{4
	Ppar(
		[
			Pdef(\kik,Pbind(\dur,"xoxx|xoxx|xoxx|oxox".asDrumPat(4,3),\octave,3)),
			Pbind(\note,3,\dur,"ox".asDrumPat(2,12),\instrument,\snare),
			//Pdef(\whick,Pbind(\note,3,\dur,"ox".asDrumPat(4,24),\instrument,\kick3,\amp,0.01)),
			Pbind(*[dur:8.reciprocal,note:15,amp:Pwhite(0.05,0.1,96)]),
			Pdef(\whaa,Pbind(*[instrument:\wha,dur:6,note:Pseq([\r,6],1),lag:-0.50]));
		]),4	
	).play
)
s.plotTree;

//	notation analog idea	{{{1
// [[1363]] [2[3]2[3]] 6.[2] 
// [[3 1 2]][[ 3 5 4 ]][[4 6 5]] 5 8 7 8 5 3 1 2 3 4 5 6 ]]
//   ____   ___ 
//  / / /  | | |
// 3 1 2.  3 1 2

// [1,3,5].inC ++ [1,3,5].inF = [1,3,5,4,6,8] 
//	three alien minds	{{{1	
a= ~vsti.('Pianoteq 5');
(
	~tune=[degree:Pseq([Rest(),4,4,3,3,3 ])-1,type:\vsti,controller:a,dur:Pseq([1,1,(2/3)!3,1].flatten),legato:1.4].p;
	
	~ch=[degree:Pseq([[5,8],[5,7],[4,6]])-1,
		dur:2,
		octave:4,
		type:\vsti,
		controller:a,
		legato:1.9,
		root:2,
		scale:Scale.dorian
	].p;

	~bass=[
		octave:4,
		dur:Pseq([3,1,2.7,1.3]/2),
		degree:Pseq([1,1,0,0,])-1,
		root:2,
		scale:Scale.dorian
	].p;

		Ptpar([
			0.2,~tune,
			0.2,~ch,
			0,~bass
		]).play
)
