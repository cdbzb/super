(
	//	FUNC	{{{1
	~funs=(		//	A Pseudo Class for Song with elastic rhythm			{{{2
		// written for trek project
		sections: {|self|self.song.size/2},
		//type:\player,
		parts:(),
		cursor:0,
		lag:0,
		lyrics:{|self| self.song.copySeries(0,2,self.song.size)},
		tune:{
			|self| var array = self.song.copySeries(1,3,self.song.size);
			array.collect({|string| Panola.new(string).midinotePattern})
		},
		setupDurs:{|self| //{{{3
			var a;
			Archive.read(self.dursFile);
			"read".postln;
			Archive.at(self.key).isNil.not.if(
				{
					a=Archive.at(self.key);
					self.durs=a++(Pseq([1])!(self.sections-a.size)); //copy and pad
				},{
					self.durs=Pseq([1])!self.sections
				}
			)
		},//}}}
		pbind:{|self | (0..self.sections-1).collect{|i| Pbind(\dur,self.durs[i],\midinote,self.tune[i])}},
		secDur:{|self | (0..self.sections-1).collect{|i| self.durs[i].list.sum} },
		secLoc:{|self| [0]++self.sections.asInt.collect({|i| self.secDur[0..i].sum}) },
		durTill:{|self sec till | self.durs[sec].list[0..till].sum}, //in a given section
		pbindFrom:{|self from=3| var list=self.pbind[from.asInt..(self.sections-1).asInt].postln;Pseq(list).postln},
		when: {|self| self.secDur[self.start]}, //for sections
		ply:{|self| self.parts.do({|i|i.parent=self; i.p});},
		//play:{~parts.do({|i|i.p=~p;i.p})},
		//play:{
		//	~parts.do({|self|
		//		(self.start<~cursor).not.if{
		//			var offset;
		//			self.syl.isNil.if(
		//				{offset=0;"offset 0".postln},
		//				{offset=~durTill.(self.start,self.syl)}
		//			);
		//			offset=offset+self.lag;
		//			TempoClock.sched(
		//				(~secLoc[self.start]-~secLoc[~cursor])+offset,
		//				{self.music.play}
		//			)
		//		}
		//	})
		//}, //for sections
		play:{
			~parts.do({|self|
				(self.start<~cursor).not.if{
					var offset,lag;
					self.lag.isNil.if({self.lag=0});
					self.syl.isNil.if(
						{offset=0;"offset 0".postln},
						{offset=~durTill.(self.start,self.syl)}
					);
					offset=offset+self.lag;
			//		TempoClock.sched(
			~secLoc.(currentEnvironment)[3].postln;
			//self.start.postln;
			//			(~secLoc[self.start]-~secLoc[~cursor])+offset,
			//			{self.music.play}
					//)
				}
			})
		}, //f/or sections
		p:{|self|(self.start<self.cursor).not.if{ var offset;
			self.syl.isNil.if({offset=0;"offset 0".postln},{offset=self.durTill(self.start,self.syl)});
			offset=offset+self.lag;
			TempoClock.sched(
				(self.secLoc[self.start]-self.secLoc[self.cursor])+offset,
				{self.music.play})};self}, //for sections
				durTillEnd: {|self| var x=0; (self.cursor..(self.sections-1)).do{|i| x=x+self.secDur[i] };x},
				dur: {|self| var x=0; (self.cursor..(self.sections-1)).do{|i| x=x+self.secDur[i] };x},
				parse:	{|self phrase array start=0| //array of rhythms {{{
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
				}; //}}}
			);

			~trek=(	// specific proto for trek song:specifies file for durs		{{{2
				dursFile:"/Users/michael/tank/super/theExtreme3",
				durs:nil,
				save:{|self| Archive.global.put(self.key,self.durs); Archive.write(self.dursFile)},
			);

			// event recorder		{{{2
			// function to allow "re-performance" of rhythms
			// takes an song-Event of proto ~funs a range of lines to perform and a number of lines before to use as cues
			~recorder= {
				|song  rnge=#[0,1] cueSecs=1 |
				var range = Array.with(rnge).flatten;
				var seq = (range[0]..range.clipAt(1))
				.collect({|i|song.tune[i].list}).flatten;
				seq.postln;
				~stepper={ |seq|
					SynthDef(\stepper, {
						var note = Demand.kr(KeyState.kr(38)-0.1,0, Dseq.new(seq.midicps));
						var sig=SinOsc.ar(note,0,EnvGen.kr(Env.perc(0.1,1)*0.1,gate:KeyState.kr(38)-0.1));
						Out.ar(1,sig);
					});
				};
				~stepper.(seq).add;
				( // function returns this pseudo-object and calls makeWindow on it
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
							makeWindow: {|self| var w=Window.new.alwaysOnTop_(true).front.alwaysOnTop_(true);//{{{
							var b=Button.new(w.view,Rect(60,10,100,100))
							.states_(["1",Color.black,Color.white])
							.action = {self.doOver;"do over".postln};
							var c=Button.new(w.view,Rect(160,10,100,100))
							.states_(["1",Color.black,Color.white])
							.action = { var a = self.ret;a.postln};
							var d=Button.new(w.view,Rect(260,10,100,100))
							.states_(["1",Color.black,Color.white])
							.action = {self.nextt;"next".postln};
							var e=Button.new(w.view,Rect(260,300,100,100))
							.states_(["1",Color.black,Color.white])
							.action = {song.save;"saved".postln};
							var v=w.view;
							self.window=w;
							StaticText(b,Rect(0,0,100,100)).string_("Do over").align_(\center);
							StaticText(c,Rect(0,0,100,100)).string_("Return").align_(\center);
							StaticText(d,Rect(0,0,100,100)).string_("next").align_(\center);
							StaticText(e,Rect(0,0,100,100)).string_("save").align_(\center);
							EZText.new(v,Rect(0,110,300,50	),label:"range",initVal:self.range,);
							v.keyDownAction={ |view char|
								self.captureLoop.(b); 
								switch(char,
									$d , {self.doOver},
									$n , {self.nextt},
									$r , {self.ret},
									$s , {song.save}
								)
							};//}}}
							self.item=[];
							t=Synth(\stepper);
							w.onClose_({t.free});
							self.cue.play ;
							self.range.do({|i|song.lyrics[i].postln})
						},
						doOver:{|self| self.item=[];self.cue.play;t.free;t=Synth(\stepper)},
						nextt:{|self| 
							self.range=(self.range+(self.range.clipAt(1)-self.range[0]+1));
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
					).makeWindow;
				}; //}}}
				~concatSongs={ |song1 song2| //{{{2
					( //should I give this parent:~funs ??
						//parent:~funs
						songs:[song1,song2],
						sections:{|f| f.songs.inject(0,{|a i| a+i.sections})},
						cursor:0,
						locate:{|f song sec|
							var ret;
							sec.postln;
							sec.isNil.if(
								{ret=song}
								,
								{ret=(f.songs[sec-1].sections)+song}
							);
							f.cursor=ret;
						},
						play:{
							if ( ~cursor>~songs[0].sections,
							{
								~songs[1].cursor=~songs[1].cursor+~cursor;
								~songs[1].ply
							},
							{
								~songs[1].cursor=0;
								~songs[0].cursor=~cursor;
								{
									~songs[0].ply;
									~songs[0].durTillEnd.wait;
									~songs[1].ply
								}.fork
							}
						)
					}
				)
			}; //}}}
			// functions to get Panola notes{{{2
			~panNotes={|string| Panola.new(string).midinotePattern.list};
			~panList={|string| Panola.new(string).midinotePattern.list.flatten};
			~noteList={|list| list.collect({|x|~panNotes.(x)}).flatten };//}}}
			Event.addEventType(\player,{~dur=~song.durTillEnd;~song.ply});
			Event.addEventType(\player,{~dur=currentEnvironment.durTillEnd;currentEnvironment.ply});
			//	~displeased	{{{1
			// ~displeased lyric and tune {{{1
			~displeased=(//{{{
				key:\displeased, parent:~funs, proto:~trek,
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

			~displeased.cursor_(0); //	{{{2
			//{ ~displeased.ply}.defer(0.2);
			//~displeased.parts=(ply:{|self| self.do({|i| i.p});};);~displeased.parts=~displeased.parts;
			// this should be a function
			//~displeased.pbind.do({|i x| var label = ("guide"++x).asSymbol; ~displeased.parts[label]=(start:x,music:i);label.postln});
			{
				{
					~synTrill= //{{{2
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
						}; //}}}
						~displeased.parts.setupTrill=(start:0,music://{{{2
							{	
								try{~syn1.controller.loaded.not.if{~syn1.init}}{~syn1=~synful.()};
								~syn1.expression(40,1);
								~syn1.expression(30,0);
								~syn1.node[1]=\filter->{|in| PlateReverb.ar(in,mix:0.5,decayTime:0.55)};
								~syn1.node.fadeTime=8;
								~syn1.node[2]=\filter->{|in| Phaser2.ar(in,rate:0.1,fb:0.5)*5};
							}
						); //}}}
						~displeased.parts.fadeoutPlate=(start:2,music://{{{2
							{
								{~syn1.node[1]=nil}.value
							}
						); //}}}
						~displeased.parts.trill=(start:0,music://{{{2
							p{
								var trillLength = ~displeased.secDur[0..1].sum;
								TempoClock.tempo=1;  //hmmm
								~synTrill.value(0,0.9,12,len:trillLength).play;
								~synTrill.value(1,1.9,4,len:trillLength).play;
							}
						); //}}}
					}.value;
					~displeased.parts.bassNotes54=(start:5,music: //{{{2
						[
							dur: Pseq(~displeased.secDur[5..6]) ,
							degree: Pseq([1,4],2) ,
							legato:[1.1,0.9].q,
							octave:3,
							amp:1
						].p
					);//}}}
					//TempoClock.tempo=1.5.reciprocal;
					SynthDef(\trem2,{| rate=12 freq=499 scale=1 gate=1 out=0| //		{{{3
						//var force =LFBrownNoise1.kr(1).range(-0.20,8.8);
						var force=0.9;
						//var scale=SinOsc.ar(0.01).range(0.2,1.2);
						//var vel=1;
						var vel=SinOsc.kr(rate+LFBrownNoise1.kr(1)).range(0,1);//rate
						//var pos=0.2;
						var pos = LFBrownNoise1.kr(2).range(0.3,0.2);
						var env = Env.asr(0,1,0.5).kr(2,gate:gate);
						var sig = DWGBowed.ar(
							freq: freq,// + LFBrownNoise0.kr(2).range(0,10),  
							velb: vel,  
							force: force,  
							gate: 1,  
							pos: pos,  
							release: 0.5,  
							c1: 5,  //inverse of DC decaytime
							c3: 30, // hi freq decay 
							//impZ: 0.55*LFBrownNoise1.kr(0.5).range(0.02,1),  
							fB: 2 //inharmonicity
						); 
						sig= DWGSoundBoard.ar(sig,  c1: 20,  c3: 100,  mix: 0.8,  d1: 199*scale,  d2: 211*scale,  d3: 223*scale,  d4: 227*scale,  d5: 229*scale,  d6: 233*scale,  d7: 239*scale,  d8: 241*scale);
						sig=HPF.ar(sig,300)*0.05;
						//sig =PlateReverb.ar(sig,mix:0.8);
						Out.ar(out, Splay.ar(sig*env));
					}).add; //}}}
					SynthDef(\verb,{|out wet=1 | //{{{
						var in=In.ar(out);
						var sig =PlateReverb.ar(in);
						XOut.ar(out, wet, sig*2)}
					).add; //}}}
					~displeased.parts.bowed7=(start:7,music:Pfx([ //{{{
						instrument:\trem2,
						rate:Pbrown(2,0,0.3),
						degree:Pseq([6,5,3,1,7-7,6-7,4,3,5-7]-1),
						root:-1,
						octave:[6,5,4],
						scale:Scale.major,
						dur:~displeased.durs[7]++Pseq([2.5]),
						legato:1,
						mtranspose:Pseq([
							[0,2,4,7],[0,3,5,7],[0,2,5,7],[0,2,4,7],[0,3,5,7],[0,4,6,7],[0,2,4,7],[0,3,5,7],[0,7]
						]),
					].p.pad,
					\verb,\wet,0.3)  //}}}
				);
				~displeased.parts.bass7=(start:7,music:
					(instrument:\sawSynth,rel:15,att:1,octave:2,amp:0.2,degree:4,root:-1,mtranspose:[0,4,7],dur:10)
				);	
		~displeased.play.defer(1);
			}.fork;
			'loaded ALL!!!'.postln;
)
		~displeased.type
		~displeased.ply

		//([(song:~transform,type:\player,dur:13)].q++ [~complete,~displeased].collect((song:_,type:\player)).q).play
		//
		//~syn1.init;

		//easy to write function will work like this:
		// [~displeased, [~complete,{TempoClock.tempo_(1)}], {vlad.postln} ]

