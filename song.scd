( ~xtreme=( //				{{{2
		key:\song,proto:~trek,parent:~funs,
		//play:{~parts.do(_.postln)},
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

	~xtreme.ready={ try{~syn1.controller.loaded.not.if{false}}{true}}; 
	~synthsLoaded.isNil.if{"/Users/michael/tank/super/song-Synthdefs.scd".load};
	~xtreme.init={ try{~syn1.controller.loaded.not.if{~syn1.init}}{~syn1=~synful2.()}}; 
	~xtreme.init;
	//~xtreme.parts.ply;
	~xtreme.play
)	

(//record audio in an event{{{2
	~input=RecNodeProxy.audio(s,1)
	.source_({SoundIn.ar(2,1)})
	.open('/tmp/test.aif')
	.record
)
(// record....{{{
	m=p{ ~input.unpause;10.wait;~input.close};
	~xtreme.parts.record2=(start:2,music:m);
	~xtreme.play;
)//}}}
(//playback{{{
	b=Buffer.read(s,"/Users/michael/tank/super/Trek-samples/heart-action.aif"); // when playing back
	//b=Buffer.read(s,'/tmp/test.aif');  // when recording
	//~xtreme.cursor_(1);
	~xtreme.parts.record2=(start:2,music:{{
		var env= Env.perc(5).kr(2,gate:1);
		var sig=PlayBuf.ar(1,b.bufnum).distort*2;
		var center= CombC.ar(sig,0.06!2,2);
		var faster=PlayBuf.ar(1,b.bufnum,rate:1.02).fold2*2;
		[sig,faster]+center;
	}.play});
~xtreme.ply
)//}}}
(// save after recording pseudo-code {{{

	//b.write("/Users/michael/tank/super/Trek-samples/heart-action.aif")
	//or.....
	(
		~recordme={|name bus=2 chan=1| var node=RecNodeProxy.audio(s,1)
			.source_({SoundIn.ar(bus,chan)})
			.open('/tmp/'++name.asSymbol)
			.record;
			node
	}
)
)

(
	~item=(
		name:'test.aif',
		arm: {|self name bus=2 chan=1| 
			var node=RecNodeProxy.audio(s,1)
			.source_({SoundIn.ar(bus,chan)})
			.open('/tmp/'++self.name.asSymbol++'.aif')
			.record;
			self.node=node
		},
		record:{|self|self.node.unpause},
		stp:{|self| self.node.close;self.buffer=Buffer.read(s,'/tmp/'++self.name.asSymbol++'.aif')},
		playback:{|self| self.buffer}
	);
)
~testtt=(name:'testtt',parent:~item);
~testtt.name
~testtt.arm
~testtt.record
~testtt.stp
a=~testtt.playback.play
a.play
~testtt.buffer
~testtt.node.close
~testtt.node.close
~
NodeProxy
a=~recordme.('testt.aif')
(
	~playmee={|name| Buffer.read(s,'/tmp/'++name.asSymbol)}
)
a=~playmee.('testt.aif')
a.play
a.unpause
a.close

//}}}
)//}}}

w=all {:x,x<-~xtreme.parts.keys,var y=~xtreme.parts[x],y.start==2}
s.meter;

~xtreme.play
s.latency=0.2
~xtreme.cursor_(0)
s.plotTree
s.reboot

( //// xtreme sections		{{{2
	//{~xtreme.play}.defer(0.3);
	~xtreme.bassBuss=Bus.audio(s,1);

	~xtreme.infrastructure={ //bass patch lasts as long as end (durTillEnd){{{
		try{~syn1.controller.loaded.not.if{~syn1.init}}{~syn1=~synful.()};
		~bassDecimator=Synth(\xtremeBass,[\amp,0.6]);
		~bassVerb=Synth(\plateReplace);
		~bassDecimator.set(\decimate,-1);
	}.inEnvir;
//}}}
	SynthDef(\xtremeBass,{|amp=1 decimate=0 out=0| //{{{
		var sig = In.ar(~xtreme.bassBuss.index)!2;
		Env.perc(~xtreme.durTillEnd+1).kr(2,gate:1);
		sig= XFade2.ar(sig,Decimator.ar(sig,rate:8000,bits:4)*(-6.dbamp),Lag.kr(decimate));
		Out.ar(out,sig*amp)
	}).add;
//}}}
	SynthDef(\plateReplace,{|in gate=1| //{{{
		var sig=In.ar(~xtreme.bassBuss.index,2);
		sig=sig* Env.asr(0,1,0.1).kr(2,gate:gate);
		ReplaceOut.ar(~xtreme.bassBuss.index,PlateReverb.ar(sig,mix:0.9));
	}).add;
//}}}
	~xtreme.parts=();
	~xtreme.parts.bassT2=(start:2,lag:0,music:p{//{{{
		~bassVerb.release(0.1);
		0.05.wait;
		~bassDecimator.set(\decimate,1)
	});//}}}
	~xtreme.parts.bassT3=(start:4,music:p{~bassDecimator.set(\decimate,-1)});
	~xtreme.parts.strum1=( start:0,syl:2, music://{{{
		(\note:[-5,-3,-2,2,5,7],\strum:0.03,\sustain:2));//}}}
	~xtreme.parts.bassnote=( start:0, music: (note: -24-5,amp:3, sustain:0.5+~xtreme.secDur[0]+~xtreme.secDur[1],\dur:~xtreme.secDur[0]+0.5));
	~xtreme.parts.strum2=( start:1,syl:2, music: (lag:~xtreme.durs[1].list[3]/2,note:[-5,-2,0,4,7],strum:0.03,sustain:2));
	~xtreme.parts.bassnote2=( start:1, music: //{{{
		(note: -12-5,amp:3, sustain:~xtreme.secDur[1]));//}}}
	~xtreme.parts.heartActionBass=( start:2, music: //{{{
		Pbind(
			\dur, ~xtreme.durs[2]++Pseq([1.0]),
			\note, Pseq([-2,-2,-2,0,-7,\r,\r,-2,-2,-2, 0,\r,-10])-24,\amp,2,
			\legato,Pseq([1 ,1, 1,1, 1.5,1,1, 1, 1, 1, 2, 1, 1])
		)
	);//}}}
	~xtreme.parts.weeeeuw=(start:2,music://{{{
		{{FreeVerb.ar(Ringz.ar(WhiteNoise.ar(0.01),XLine.kr(2500,240,6),1),room:8,mix:7)*EnvGen.kr(Env.perc(0,7),doneAction:2)}});
	//~xtreme.parts.weeeeuw.music= Pfxb.new(Pbind(\midinote,Pseries(60+36,-0.99,100),\dur,0.1,\sustain,1,\amp,0.01),\two_tube);
	//~xtreme.parts.weeeeuw.music.play}}}
	{   ///tempo map for drums{{{
		var d= ~xtreme.durs[2].list[0..3] ++ ((~xtreme.durs[2].list[4]/2)!2).asList ++ ~xtreme.durs[2].list[5..8];
		~xtreme.parts.drums=(start:2,music://{{{
			Pbind( \instrument, Pseq([\kick2, \rest, \snare, \rest, \kick2, \kick2, \snare,\rest]++
			[\kick2, \rest, \snare, \rest, \kick2,  \kick2, \snare,\rest]),
			\dur,Pseq(d,inf),
			\lag,Pseq([0,0,-0.01,0,0,0,0,0],inf),
			//\amp,0.5
			\amp,Pseg([0.5,0.5,0.3]*0.5,[d[0..4].sum,d.sum-d[0..4].sum+1])
		));//}}}
		SynthDef (\cymbal, {|amp=1 length=2| //{{{
			var sig=PinkNoise.ar(EnvGen.kr(Env.perc(0,length)))!2;
			sig=TwoTube.ar(RHPF.ar(sig,500,9),d1length:502,d2length:777,loss:0.99)*0.5;
			DetectSilence.ar(sig,doneAction:2);
			Out.ar(0,sig*amp)}
		).add; //}}}
		~xtreme.parts.cymbal=(start:2,music://{{{
			Pbind( \instrument, Pseq([\rest, \rest, \rest, \rest, \rest, \rest, \rest,\rest]++
			[\rest, \rest, \rest, \rest, \cymbal, \rest, \rest,\rest]),
			\dur,Pseq(d,2),\lag,-0.05,\amp,0.4)
		);//}}}
		~xtreme.parts.hat=(start:2,music://{{{
			Pbind(\instrument, \hihat,
				\ffreq,Pwhite(4000,10000),
				//\dur,(Pser(d,48)),
				\dur,(Pser(d/4,96)),
				\amp,Pseg([0.5,0.5,0]*0.15,[d[0..4].sum,d.sum-d[0..4].sum+4.2])
			)
		);//}}}
	}.value;//}}}
	~xtreme.parts.andthe=(start:3,//{{{
				music:Pbind(\dur,~xtreme.durs[3]++Pseq([1]), \instrument,\test,
				\amp,1,
				\lag,Pwhite(-0.01,0.01),
				\midinote,Pseq([\r]++~xtreme.tune[3].list.copyRange(1,~xtreme.tune[3].list.size)++[79])-24));//}}}
	~xtreme.parts.strum3=(start:4,music://{{{
				(\note: [4,16,19]-12,\dur:3,\strum: 0.03);
	);//}}}
	~xtreme.parts.bass3=(start:4,//{{{
		music:Pbindf(Panola.new("r c#2 e a1\\pdur[2.2]").asPbind,\dur,~xtreme.durs[4],\tempo,1,\amp,0.8)
	);//}}}
	~xtreme.parts.bass5=(start:5, music://{{{
		Pbind(
			\midinote,(Pser(~xtreme.tune[5].list,4)++Pseq([71,71-7]))-36,
			\dur,Pseq(~xtreme.durs[5].list[0..3]++~xtreme.durs[5].list[4..6].sum++1),
			\amp,0.8,
			\lag,Pwhite(-0.02,0.02)
		)
	);//}}}
	~xtreme.parts.drums5=(start:5,music://{{{
		Pbind( \instrument, Pseq([\kick2, \kick2, \snare, \kick2, \kick2,] ),
		\dur,Pseq(~xtreme.durs[5].list[0..3]++~xtreme.durs[5].list[4..6].sum++1),
		//\lag,Pseq([0,0,-0.01,0,0,0,0,0],inf),
		//\amp,0.5
		//\amp,Pseg([0.5,0.5,0.3]*0.5,[d[0..4].sum,d.sum-d[0..4].sum+1])
		)
	);//}}}
	~xtreme.parts.hat5=(start:5,music://{{{
		Pbind(
			\instrument, \hihat,
			\ffreq,Pwhite(4000,11000),
			//\dur,(Pser(d,48)),
			//\dur,(Pser(d/4,96)),
			\dur,Pseq(((~xtreme.durs[5].list[0..3]++~xtreme.durs[5].list[4..6].sum++1)/2).stutter(2)),
			\amp,Pseq([1,0.4]*0.1,4))
		);//}}}
	~xtreme.parts.bassnote6=(start:6,music://{{{
		Pbindf(Panola(" a1 g f").asPbind,\dur,Pseq([~xtreme.durs[6].list[1..2].sum]++~xtreme.durs[6].list[3..4]),\tempo,1,\amp,0.8)
	);//}}}
	~xtreme.parts.pad6=(start:6,music://{{{
		{
			{
				var a=(instrument:\sawSynth,midinote:[69,72,77],att:2,rel:3,amp:0.05,lagTime:0.2).play;
				//a.set(\freq,[69,74,77].midicps)
				(type:\set,id:a[\id],freq:[69,74,77].midicps,lag:1.1).play;
				(type:\set,id:a[\id],freq:[71,74,77].midicps,lag:2.25).play
			}.value
		}
	);//}}}
	~xtreme.parts.cymbal5=(start:5,music: //{{{
	(\instrument:\cymbal,\lag:~xtreme.durs[5].list[1..4].sum);); //}}}
	~xtreme.parts.tremolo6=(start:6,syl:5,music://{{{
		Pbind(
			/*\instrument,  \pluck ,*/
			\note,[7-12,7]*[1,2],
			\dur,Pwhite(0.05,0.1),
			\strum,0.01 ,
			\amp,Pseg([0.2,0.5*Pwhite(0.8,1.2,inf)*0.0001]*0.3,[5.1,1.9], \exp, \offset,0)
		) //TODO set synth
	);//}}}
	~xtreme.parts.bass8=(start:8,music: //{{{
		Pbind(\note,Pseq([5,4,2,1]-24),\dur,~xtreme.durs[8],\amp,0.5)
	);//}}}
	~xtreme.parts.bass8Alt=(start:8,music://{{{
		Pbind(\instrument,\test,\note,Pseq([5,4])-[0+rand(0.02),12],\lag,Pseq([0,0]),\amp,0.5)
	);//}}}
	~xtreme.parts.strum8=(start:8,syl:1,music://{{{
	(note:[1,4,9]-12++[1,4],strum:0.04,sustain:2,lag:0.52,amp:0.05)
	);//}}}
	~xtreme.parts.strum9=(start:9,music://{{{
		(midinote:~panNotes.(" <g b- e-5 g5>").flatten-12,strum:0.042)
	);//}}}
	~xtreme.parts.bass9=(start:9,music://{{{
		(note:~panNotes.("e-2").flatten-60,dur:2,amp:0.3)
	);//}}}
	~xtreme.parts.tremoChord=(start:10,music://{{{
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
	);//}}}
	~xtreme.parts.tremoChord2=(start:10,syl:0,music://{{{
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
	);//}}}
 //{{{ modify Bass Track
 //~xtreme.play

	all {:x,x<-~xtreme.parts.keys, var y=~xtreme.parts[x], x.asString.find("bass",true).isNil.not,y.music.class==Event,::y.music=Pseq([y.music])};
 ~sendBasstoBus={all {
	 :x,x<-~xtreme.parts.keys, var y=~xtreme.parts[x],
	 x.asString.find("bass",true).isNil.not,
	 ::y.music=y.music<>(out:~xtreme.bassBuss.index,addAction:\addToHead)}
 }.value; //}}}
	~xtreme.pbind.do({|i x| var label = ("guide"++x).asSymbol; ~xtreme.parts[label]=(start:x,music:i);label.postln});
	c=SystemClock.seconds;
	//~xtreme.cursor_(1);
	//~xtreme.play
	//~xtreme.parts.nextSection=(start:10,lag: ~xtreme.secDur[10]+0.01,music:{~transform.ply});
) 
~xtreme.cursor_(0);
~xtreme.play

(//vocal sess
 ~xtreme.parts.heartdouble=(start:2,music:{~rec.(\heartHi2,4,7)});
 //~xtreme.parts.heartVocal=(start:2,music:{~rec.(\heart,4,7)});
 ~xtreme.play
)
~syn1.keys.do(_.postln)
~syn1.controller.info.keys.do(_.postln)
b=Buffer.read(s,File.getcwd++"/media/heart.wav");
c=Buffer.read(s,File.getcwd++"/media/heartd.wav");
d=Buffer.read(s,File.getcwd++"/media/heartHi.wav");
e=Buffer.read(s,File.getcwd++"/media/heartHi2.wav");

~xtreme.cursor_(2).play;

(//Heart Vocal Sess 1{{{
	~xtreme.parts.heartdouble=nil;
	~xtreme.parts.heartVocal=(start:2,music:(instrument:\heartVoc));
		SynthDef(\heartVoc,{
			var sig,sig2;
			sig=PlayBuf.ar(1,[b,c].collect(_.bufnum))*3;
			sig=Compander.ar(sig!2,sig,thresh:0.3,slopeAbove:0.10).tanh;
			//sig=PlateReverb.ar(sig/1,mix:0.6);
			sig=TwoTube.ar(sig,0.01,0.7,2222,2333)+sig.distort;
			sig=RHPF.ar(sig,1500,rq:0.25)*2;//+HPF.ar(sig);
			sig2=PlayBuf.ar(1,[d,e].collect(_.bufnum));
			sig2=Mix.ar(sig2);
			sig2=FreeVerb.ar(sig2,0.8,0.4,0.1)*2;
			sig2=Compander.ar(sig2,sig2,thresh:0.3,slopeAbove:0.10).tanh;
			sig+sig2;
			Out.ar(\out.ir,sig+sig2);
	}).add;
	~xtreme.play;
)//}}}
 ~xtreme.play
 ~xtreme.cursor_(9).play

 ( //transformation			{{{1
	~transformation={ 
			var dur=15;
			var pitches=~panNotes.("f#3 b- c4 e")+[0,12];
		s.bind{
			var chord=pitches.collect({|item index|  Synth(\trans,[\freq,item.midicps,\amp,0.1])});
			var chord2=pitches.collect({|item index|  Synth(\trans,[\freq,item.midicps,\amp,0.1])});
			//~xtreme.init;
			try{~fadeO.stop};
			//try{~syn1.controller.loaded.not.if{~syn1.init}}{~syn1=~synful.()};
			try{~syn1.controller.loaded.not.if{~syn1.init}}{~syn1=~synful2.()};
			{dur.wait;chord.do{|i|i.release}}.fork;
			{dur.wait;chord2.do{|i|i.release}}.fork;
		};
		////cymbal
		(instrument:\cymbal,length:8).play;
		////strings
		try{~syn1.monitor.free;};~syn1.monitor=Monitor.new;~syn1.monitor.play(~syn1.bus.index,2,0,2,fadeTime:0.05);
		v={var sig=In.ar(~syn1.bus);sig=FreeVerb.ar(sig,room:0.75,mix:0.55)*3;ReplaceOut.ar(~syn1.bus,sig)};v=v.play;
		{20.wait;v.free}.fork;
		//~myFree.(~syn1)
		~syn1.setprog(3,5,0); ~syn1.setprog(4,5,1);
		//~syn1.node[1]=\filter->{|in| FreeVerb.ar(in,room:0.75,mix:0.55)*3};
		~fadeO={
			8.wait;"now!".postln;127.do( {|i|~syn1.expression((127-i),0);~syn1.expression((127-i),1);0.18.wait} )
		}.fork;

		s.bind{
			(type:\midi,midiout:~syn1.controller.midi,\midinote:~panNotes.("f#3 b- c4 e").flatten-[0,12],dur:20).play;
			(type:\midi,midiout:~syn1.controller.midi,\channel:2,\midinote:~panNotes.("f#3 b-4 c4 e").flatten-24,dur:20).play;
			~syn1.expression(127,0);
			~syn1.expression(127,1);
		};
		//tympani
		s.bind{{ |pitchScale=1.15 loss=0.99998 |
			var env=Env.linen(0,dur-5,8).kr(2,gate:1)*0.175;
			var exc = Dust.ar(2!2)+Impulse.ar(0);
			var sig;
			exc = Decay.ar(exc,0.02);
			exc=Integrator.ar(exc,0.8,0.1);
			exc=PinkNoise.ar(exc);
			sig=MembraneCircle.ar(exc,[0.007,0.0073]*pitchScale,loss)*env;
			sig
		}.play;}
		
	};
	//cue (could add conditions for this.....)
	~transform=(play:{topEnvironment.use({~transformation.fork})},durTillEnd:15);
); //}}}

p({~xtreme.play;~xtreme.durTillEnd.wait;~transformation.play}).play

( // {{{ \player Event Type
	Event.addEventType(\player,{~dur=~song.durTillEnd;~song.ply});
	~xtreme.cursor_(7);
	(
		a:(song:~xtreme,type:\player),
		c:(type:\player,song:~transform,dur:15),
		d:(type:\player,song:~complete),
		play:{Pseq([~a,~c,~d]).play}
	).play;
)
//}}}
//alternate fadeout for ~transformation
[dur:0.1,dev:Pseg([100,1],2,\exp),play:Pfunc{|e|e.dev.postln}].p.play
( // ~complete lyric and tune	{{{1
	//~syn1.controller.loaded.not.if({~syn1.init});

	~complete=( //{{{
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
)//}}}
(
	~recorder.(~complete,2,1);
)

TempoClock.play
~complete.play
~complete.cursor_(3)
all {:x,x<-~complete.parts,x.start==3};
all {:x,x<-~complete.parts.keys,var y=~complete.parts[x],x.asString.contains("guide").not,y.start==3,::y.p};
all {:x,x<-~complete.parts,x.start==3,::x.p};
(//adding a part to Hellusing List comprehension...
	all {:x,x<-~complete.parts.keys,var y=~complete.parts[x],(x==\guide3).not,(y.start==3).or(y.start==4),::x.postln;y.p};
	[legato:1.05,degree:([8,7,6,5].q++[6,6,5,4].q)-1,amp:Pseries(0.1,-0.015),octave:[4,5],dur:1,root:2].p.trace.play(~complete.parts.helloSequence.clock);
	//[degree:[8,7,6,5,6].q-1,octave:[3,4],dur:1,root:2].p.play(~complete.parts.helloSequence.clock);
)
a=Pseries(0.1,-0.05).asStream
a.next
~complete.cursor_(3).play;
s.boot
~complete.play

[~complete.player].q(2).play
( //// parts for ~complete		{{{1
	~syn1.isNil.if({~syn1=~synful2.()},{~syn1.controller.loaded.not.if{~syn1.init}});
//	~complete.cursor_(0); //	{{{2
	//"/Users/michael/tank/super/song-hello-beet.scd".load;
	TempoClock.tempo=1;
//	~complete.parts=(
//		ply:{|self| self.do({|i| i.p});};
//	);
//	~complete.parts=~complete.parts;

~complete.parts=();
	//0							{{{2
	~complete.parts.bassnotes=(start:0,syl:3,music:
		{
			Pseq([
				(note:1-24,amp:0.5,dur:~complete.durs[0].list[4]),
				(note:1-24,amp:0.6,dur:5,sustain:2)
			])
		}
	);

	SynthDef(\phaser ,{|out=0 depth=0.5 fb=0.3 rate=0.03 gate=1| //{{{
		XOut.ar(
			out,
			//Env.cutoff(6).kr(gate),
			Env.linen(0,8.5,6).kr(doneAction:2),
			Phaser2.ar(In.ar(out,2)+
			PlateReverb.ar(
				In.ar(out,2),mix:Env.linen(0,2.5,6).kr)
				,rate:rate,fb:fb,depth:depth
			)
		)
	}).add;//}}}
	~complete.parts.chord0=(start:0,syl:3,music://{{{
		Pfx(
			Pseq([
				(note:[1,8,13]-24,instrument:\sawSynth,release:4,strum:0.03,dur:~complete.durs[0].list[4]),
				(note:[1,8,13]-24,instrument:\sawSynth,release:5,strum:0.03,dur:11),
				(note:\r,dur:12),
			]),\phaser
		)
	);//}}}
//	~complete.parts.bassnotes2=(start:1,syl:2,music:
//		(note:2,amp:0.1)
//	);
//1					{{{2
	~complete.parts.bassnotes3=(start:2,music://{{{
		(note:-2-12,amp:0.1)
	);//}}}
	~complete.parts.bassnotes4=(start:2,syl:2,music://{{{
		(note:[7,-5],amp:0.1,sustain:2)
	);
//}}}
	~complete.parts.pad0=(start:0,music://{{{
		Pbind(\midinote,Pseq(~complete.tune[0].list[0..3])-[0,12],\instrument,\sawSynth,\dur,~complete.durs[0]);
	);
//}}}
	~complete.parts.helloImage=(start:2,syl:8,music://{{{
		{ { { a=Image.open("/Users/michael/tank/super/Spock.png");
					w=a.plot(freeOnClose:true).alwaysOnTop_(true);
					w.alwaysOnTop_(true);
				}.defer;
				5.wait;
				{w.close}.defer;
			}.fork
		});
//}}}
	//3 -                		{{{2
	~complete.parts.helloChord=(start:3,music:
		(instrument:\test,midinote:~panNotes.("<d4 f# a c#>").flatten,strum:0.03,amp:0.4)
	);

	~helloTempo=1/~complete.durs[3].list.mean;
	~helloTemp2=1/(~complete.durs[4].list[0..6].sum/5*2);
	~complete.parts.helloImage=(start:2,syl:8,music://{{{
		{ { { var a,w; a=Image.open("/Users/michael/tank/super/Spock.png");
					w=a.plot(freeOnClose:true).alwaysOnTop_(true);
					w.alwaysOnTop_(true);
				}.defer;
				5.wait;
				//{w.close}.defer;
			}.fork
		});
//}}}
	//3 -  ~helloBeat    		{{{2

	~complete.parts.helloSequence=(start:3,clock:TempoClock.new,bus:Bus.audio,music:{|self| //returns a function
		var kickPatterns,kickBar,snarePatterns,snareBar,synth,helloBass2,helloBass1,helloBeat;
		SynthDef( \phaser2,{//{{{
				|out=5 depth=0.5 fb=0.3 rate=0.03|
				ReplaceOut.ar(
					out,Phaser2.ar(In.ar(out,1)+
					PlateReverb.ar( In.ar(out,1),mix:Env.linen(0,2.5,6).kr)
					,rate:rate,fb:fb,depth:depth))
				}
			).add;
//}}}
			kickPatterns=[[3/4,1/4],1];//{{{
			p=[0,0,0,0,1,1,1,0]++[1,0,1];   ///XTENDED
			kickBar=Pseq(p.collect{|i|kickPatterns[i]}.flatten);
//}}}
			snarePatterns=[[Rest(3/4),1/4],[Rest(1)],[Rest(1/2),1/2],[Rest(1/2),1/4,1/4],[Rest(1/4),1/4,1/2]];//{{{
			p=[0,1,2,0, 0,3,0,4]++[0,4,4];   ///XTENDED
			snareBar=Pseq(p.collect{|i|snarePatterns[i]}.flatten);
//}}}
			synth= Pbind( //{{{
				\note,Pseq([2-24,2-12,-1-12,9-12])-12,
				\instrument,\sawSynth,
				\dur,2,\rel,5,
				\amp,0.2) ;
//}}}
			helloBass1=Pbind(//{{{
				\note, Pseq([2,4],4)-24,
				\legato,Pseq([1,Pwhite(0.25,0.55,1)],4),
				\amp,0.5
			) ;
//}}}
			helloBass2=Pbind(//{{{
				\note,Pseq([\r,2,0],8),
				\dur,Pseq([1/2,1/4,1/4],inf),
				\amp,0.04
			) ;
//}}}
			helloBeat= { |synthamp=0.3 drumsamp=1 tempo1=(52/60) tempo2=(50/60)|
				Ppar([
					Pbind(
						\tempo,Pseq([tempo1,tempo2]),\dur,4,\note,\r),
					Pbind(
						\instrument,\kick1,
						\dur,kickBar,
						\amp,drumsamp*0.1
					),
					Pfin(
						42, Pn( ///XTENDED
							Pbind(\instrument,\hihat, //ffreq rel
								//\dur,Pseq([0.245,0.255],32),
								\dur,Pseq([0.245,0.255],32),
								\amp,Pseq([Pwhite(0.3,0.4,1),Pwhite(0.2,0.3,1)],32)*0.4*drumsamp,
								\lag, Pseq(
									(1!16++(-1!16)).scramble*0.003),
									\ffreq, Pwhite(6000,6500),
									\rel,0.15
								) ,2
							)
						),
					Pbind(
						\instrument,\snare,
						\dur,snareBar,
						\amp,drumsamp*0.1
					),
					Pfx(
						Pbind( \instrument,\sawSynth,
							\note,Pser(~panNotes.("d f# a c#5 e5").flatten-60,16),
							\dur,1/2,
							\att,0.5,
							\octave,Pser(4!5++(5!5)++(6!5)++(7!5),42),
							\amp, Pseq(( 0.1!5 )++(0.09!5)++(0.08!5)++Pseries(0.07,-0.005))
						).pad,
						\phaser2
					),
						//~helloBass1,
						//~helloBass2,
						Pset(\amp,synthamp,synth),
						//Pseq([(\type:\rest,dur:4),~complete.pbind[4]]);//remove
						//	Ptpar([
						//		0.15,~helloGtr1,
						//		0.15,~helloGtr2
						//	])
					],1   /// repeats!!
				)<>(out:self.bus)};

				'self bus '.post;self.bus.postln;
				self.mon=Monitor.new.play(self.bus.index,2,0);
				{s.bind {helloBeat.(synthamp:0.1,drumsamp:0.7,tempo1:~helloTempo,tempo2:~helloTemp2).play(self.clock)}};
			});
// 4-6 {{{2
	~complete.parts.drumPan4=(start:4,music:{
		{
			~complete.parts.helloSequence.mon.play(
				~complete.parts.helloSequence.bus.index,2,1,1,
				fadeTime:~complete.secDur[4..5].sum,
				volume:0.2);
		}.fork
	}
	);
	~complete.parts.bass4=(start:4,syl:6,music:
		(instrument:\sawSynth,note:[7,-5]-12,amp:0.2,sustain:2,att:1.0,rel:3)
	);
	~complete.parts.bass5=(start:5,syl:4,music:
		(instrument:\sawSynth,note:[7,-5]-13,amp:0.2,sustain:2,att:1.0,rel:3)
	);

	~phrase6quarter=~complete.durs[6].list.[0..6].sum/6;

	~complete.parts.bass6=(start:6,music:
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
		DetectSilence.ar(sig,doneAction:2);
	},  rates: nil,  prependArgs: nil,  variants: nil,  metadata: nil).add;


	SynthDef.new(\yowbass, {|freq=400 amp gate=1 dur=1|
		var sig=Formant.ar(freq,  formfreq: Line.kr(3060,00,dur),  bwfreq: 880,  mul: 1,  add: 0).distort;
		var env=Env.asr(0,1,1,1.5).kr(gate:gate,doneAction:2);
		Out.ar(0,sig*env*amp!2)}
		,  rates: nil,  prependArgs: nil,  variants: nil,  metadata: nil).add;

		~durs6=~complete.durs[6].list;

	~complete.parts.yow6=(start:6,music:
		Pbind(\instrument,\yowbass,
			\note,Pseq([[-3,0],[-3,0],[-5,-1]]),
			\dur,Pseq( [~durs6[0..2].sum,~durs6[3],~durs6[4..8].sum]),
			\amp,0.03,
		),
);

	~complete.parts.yow7=(start:7,syl:0,music:
	(instrument:\yowbass,note:[-3,0,5],dur:3,amp:0.05)
);
	~complete.parts.keys6=(start:6,music:
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

	~complete.parts.keys62=(start:6,syl:5,music://{{{
		Pbind(
			\instrument,\stab,
			\note,Pseq([ [7,9,13],[7,9,13],[5,9,14] ]),
			\dur, Pseq(~complete.durs[6].list.[6..7]++[1]) ,
			\amp,Pseq([1,1.3,1])*0.8,
		)
	);//}}}
	// 7 on {{{2
	~complete.parts.bass7=(start:7,syl:0,music://{{{
		Pseq([
			(note:5-24,dur:~phrase6quarter*3,amp:0.5),
			//(note:4-24,dur:~phrase6quarter,amp:0.5),
			//(note:7-24,dur:~phrase6quarter*2,amp:0.5),
		]));
//}}}
	~complete.parts.keys7=(start:7,syl:0,music://{{{
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
//}}}
	~complete.parts.pad8=(start:8,music://{{{
	{
		var du=~complete.durs[8].list;
		var dv=~complete.durs[9].list;
		var a=(instrument:\sawSynth,midinote:[4,8,11]+60,att:4.5,rel:5,amp:0.05,lagTime:0.3).play;
		Pbind.new(*[
			type:\set,
			id:a[\id],
			freq: Pseq([ [4,8,11],[3,6,11],[3,6,10],[1,6,10],[1,4,10],[-1,4,8] ]+72).midicps ,
			dur:Pseq([du[0..1].sum,du[2..3].sum,du[4..6].sum,dv[0..1].sum,dv[2..5].sum,1 ])
		]).play;
	}
		  );
//}}}
SynthDef(\tromboneVerb,{ |room=0.8 mix=0.7| //{{{
	var sig=In.ar(~syn1.bus,2);
	sig=FreeVerb.ar(sig,room:room,mix:mix)*3;
	ReplaceOut.ar(~syn1.bus,sig);DetectSilence.ar(sig,time:2,doneAction:2) 
}).add;
//}}}
			//~complete.cursor_(0).play;
	~complete.parts.trombone8=(start:8,music://{{{
		{ | amp=0.9 exp=80|
			~syn1.monitor.free;
			~syn1.monitor.play(~syn1.bus.index,2,0,2,fadeTime:0.05,volume:1);
			~syn1.patch(\trombone,\none,3);
			~syn1.expression(84,3);
			Ppar([[instrument:Pseq([\tromboneVerb])].p,
			Pbind(*[lag:s.latency,
				type:\vsti,
				controller:~syn1.controller,
				chan:3,
				midinote: Pseq(~noteList.(["g#","c#","b3"]))-[12,36] ,
				dur:Pseq([~complete.secDur[8],~complete.secDur[9],3]),
				\amp:0.55 ])]);
			}
		);
//}}}
	~complete.parts.sargon10=(start:10,syl:2,music://{{{
		Pseq([
			(note:[4,7,10],dur:~complete.durs[10].list[3],\amp:0.3),
			(note:[4,7,10],dur:~complete.durs[10].list[4],\amp:0.3)
		])
	);
//}}}
	~complete.parts.pf11=(start:11,music://{{{
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
//}}}
	//~complete.pbind.do({|i x| var label = ("guide"++x).asSymbol; ~complete.parts[label]=(start:x,music:i);label.postln});
	"xxx.xxxxxxx".do({|i n| var label="guide"++n.asSymbol; (i==$x).if {~complete.parts[label]=(start:n,music:~complete.pbind[n])} });
		
	~complete.loaded=1;
	try{~syn1.controller.loaded==false.if({~syn1.init})}{~syn1=~synful2.()};
)
~complete.play
~complete.cursor_(0).play

~syn1=~synful2.()

s.plotTree
~complete.cursor_(0).play
(
		~transformation.play;
	{
		17.wait;
		~complete.play;
	}.fork
)

( // xtreme-complete transition study		{{{1
	~xtreme.cursor_(5);
	~complete.cursor_(0);
	TempoClock.tempo=1;
	{
		try{~syn1.controller.loaded==false.if({~syn1.init;10.wait})}{~syn1=~synful2.();10.wait};
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
( //	OR in the new spelling.....	{{{2
	var d = (note:[0,1,2]-48,\amp:1,sustain:5,dur:5);
	~complete.parts.boom=(start:0,music:d);
	(
		play:{Pseq([~c,~b,~a]).play},
		a: Pfin(1,(song:~complete,type:\player)),
		b:	(song:~transform,dur:13,type:\player),
		c: (song:~displeased,type:\player)
	).play
)
s.plotTree
~playemOnce={|list| Ppar(list.collect{|i|Pfin(1,i)}) };
~playemOnce.([ (song:~complete,type:\player) ,(note:[0,1,2]-48,amp:2),Prout({TempoClock.tempo=1})]).play
~displeased.ply;
~displeased.keys.do(_.postln)
~funs.keys.do(_.postln)


(// trill{{{1
	~trill={ |instrument=\default amp=0.1 len=5 |
		Pfindur(len,
			Pbind(*[
				instrument:instrument,
				note:Pseq([6,8],100),
				dur:Pwhite(0.1,0.12)*0.8,
				amp:Pwhite(0.1,0.11)*amp,
				pan:rrand(-1,1)
			])
		).play
	};
	//~trill.value(\test);
	//~trill.value;

		~synTrill=
		{|chan=1 amp=0.3 transpose=0 len=6|
			Pfindur(len,
				Pbind(*[
					type:\vsti,controller:~syn1.controller,
					note:Pseq([6,8],inf)+transpose,
					dur:Pwhite(0.1,0.12)*0.8,
					amp:Pwhite(0.1,0.11)*amp,
					legato:Prand([0.95,1,1,1,1],inf),
					pan:rrand(-1,1),
					//amp:amp,
					chan:chan
				]));
			};

			~trl=(dur:6,play: 
				topEnvironment.use{
					Routine{var len=6;
						~syn1.expression(64,1);
						~syn1.expression(64,2);
						~syn1.patch(\violins,\arco,1); //put these into the Pbind
						~syn1.patch(\clarinet,\none,0); //put these into the Pbind
						~syn1.monitor.free;
						~syn1.monitor.play(~syn1.bus.index,2,0);
						Synth(\tromboneVerb,[mix:0.4]); //change??
						//~trill.value(\test,len:len);
						~trill.value(len:len);
						~synTrill.value(0,3.0).play;
						~synTrill.value(1,3.9,4).play;
					};
				}
			)
)
.play

~trl.play;
~trl.stop;
[~trl,~complete.player].q.play

//trill with preroll {{{2
	~complete.cursor_(8);
	{
		~complete.parts.ply;
		~complete.durTillEnd.wait;
		~trill.value;
			~synTrill.value(0,2.9).play;
			~synTrill.value(1,1.9,4).play;
	}.fork;
);
(// ~displeased lyric and tune {{{1
~displeased=(
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
)

( //after so long piano sketch{{{
	~afterSoLong=[4,5,8,7,9]++[5,6,4,7] + [ 2,2,2,2,2,2,2,2,3 ].collect{|i| [0,i]};
	(degree:1,octave:4,dur:6).play;
	Pbind(*[legato:1.05,degree:Pseq(~afterSoLong)-1,dur:Pseq( 0.5!4++[2.5]++(0.5!3)++[2])]).play;
	Pbind(*[degree:Pseq([1,-3]),dur:Pseq([4,5])]).play;
)//}}}
(
	a=~recorder.(~displeased,[8],1);
	a.makeWindow;
)

[~complete.player,~displeased.player].q.play;
~syn1=~synful2.()
~displeased.play
~syn1.controller.loaded

([~displeased,~displeased<>(lag:5)].q).play(SystemClock,~funs);
~displeased.play
TempoClock.tempo=1
~displeased.ply //the problem is to do with the ~trill continuing malarkey
~displeased.save;
( ~displeased.cursor_(0); //	{{{2
	//{ ~displeased.ply}.defer(0.2);
	//~displeased.parts=(ply:{|self| self.do({|i| i.p});};);~displeased.parts=~displeased.parts;
	// this should be a function
	~displeased.pbind.do({|i x| var label = ("guide"++x).asSymbol; ~displeased.parts[label]=(start:x,music:i);label.postln});
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

			SynthDef(\plate_phaser_insert,{|inBus=0 gate=1| //{{{
				var env= Env.cutoff(15,curve:\cub).kr(2,gate:gate);
				var sig = In.ar(inBus,2);
					sig=PlateReverb.ar(sig,mix:0.5,decayTime:0.55);
					sig=Phaser2.ar(sig,rate:0.1,fb:0.5)*2;
					ReplaceOut.ar(inBus,sig*env)
			}).add;//}}}

			SynthDef(\syn1_Monitor,{|out=0| //{{{
				Out.ar(out,In.ar(~syn1.bus.index,2))
			}).add;//}}}

			~displeased.parts.setupTrill=(start:0,music://{{{2
					p{	
						try{~syn1.controller.loaded.not.if{~syn1.init}}{~syn1=~synful2.()};
						~syn1.expression(40,1);
						~syn1.expression(30,0);
						~syn1.monitor=Synth(\syn1_Monitor);
						~syn1.insert=Synth(\plate_phaser_insert,[\inBus,~syn1.bus.index],addAction:\addBefore,target:~syn1.monitor);
					}
				
			); //}}}

			~displeased.parts.fadeoutPlate=(start:2,music://{{{2
				{
					{
						~syn1.insert.release;
					}.fork
					//{~syn1.node[1]=nil}.value
				}
			); //}}}

			~displeased.parts.trill=(start:0,lag:0.1,music://{{{2
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
		tempo:0.8,
		instrument:\trem2,
		rate:Pbrown(2,0,0.3),
		degree:Pseq([6,5,3,1,7-7,6-7,4,3,5-7]-1),
		root:-1,
		octave:[6,4],
		scale:Scale.major,
		dur:~displeased.durs[7]++Pseq([2.5]),
		legato:1,
		mtranspose:Pseq([ [0,2,4,7],[0,3,5,7],[0,2,5,7],[0,2,4,7],[0,3,5,7],[0,4,6,7],[0,2,4,7],[0,3,5,7],[0,7] ].collect(_-7)),
	].p.pad,
	\verb,\wet,0.3)  //}}}
);

	~displeased.parts.bass7=(start:7,music:
		(instrument:\sawSynth,rel:15,att:1,octave:2,amp:0.17,degree:4,root:-1,mtranspose:[0,4,7],dur:10)
	);	
	}.fork
)
TempoClock.tempo_(1);~displeased.cursor_(6).play
//([(song:~transform,type:\player,dur:13)].q++ [~complete,~displeased].collect((song:_,type:\player)).q).play
//or, better 
[~transform,~complete,~displeased].q.play(TempoClock,~funs);

//

~syn1.init;

//easy to write function will work like this:
// [~displeased, [~complete,{TempoClock.tempo_(1)}], {vlad.postln} ]

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
		//	bass setup	{{{3
	var bass=NodeProxy.audio(s,2).play;
		~unnecessary.parts=();
	bass[1]=\filterIn->{|in|in+CombN.ar(in,1,0.25/TempoClock.tempo,2,mul:0.8)/2};
	bass.set(\wet1,0.8);
	bass[2]=\filter->{|in| Phaser1.ar(in,  depth: 0.5,  rate: 0.2,  fb: 0.3,  cfb: 0.1,  rot: 1.5707963267949) };

	~notes=[1,3,6,4].collect{|i| i!4}.flatten;
	
	SynthDef(\bl,{|gate=1 out=0 freq=400 t_trig=0  | //{{{ 
		var sig= SawDPW.ar(freq*[1,2],0,0.04 );  // add these octaves better
		//var env=Decay.kr(t_trig,0.4) ;
		var env= Env.perc(0.00,0.3,curve:\sin).kr(0,gate:t_trig) ;
		sig= sig+CombN.ar(sig, 1, 0.35,  decaytime: 3,  mul: 0.5,  add: 0);
		sig=DFM1.ar(sig,1800,0,5.9);//.distort;
		Out.ar(out,sig*env!2);
	}).add;
//}}}
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
	//TempoClock.tempo=1;
	~unnecessary.parts.unnecessary=(start:0,music:~unnecessary.pbind[0]);
	~unnecessary.parts.tempo1=(start:0,music:{{TempoClock.tempo=1}.fork});
	~unnecessary.parts.tempo2=(start:1,music:{{TempoClock.tempo=1.2}.fork});
	~unnecessary.parts.descant=(start:0,music: //		{{{
		Pbind(*[ 
			instrument:\sawSynth,
			degree:Pseq([\r,8,7,6,5,5,4.1])-1,
			att:0.7,
			root:4,
			dur:Pseq(
				[~unnecessary.durTill(0,3)]++~unnecessary.durs[0].list [4..9]++[0.5,2]
			)
		])
	);//}}}
	~unnecessary.parts.unnecBass=(start:0,music: //		{{{
		Pbind(*[
			instrument:\sawSynth,
			degree:Pseq([5,2])-1,
			rel:4,
			dur:~unnecessary.durTill(0,7),
			//dur:Pseq([2.3,1]),
			root:4,
			octave:3
		])
	);//}}}
	//TempoClock.tempo;
	~unnecessary.parts.bass1=(start:1,music: {bass[0]=Pseq([Rest(8),Pmono(\bl,\degree,Pseq(~notes,4)-1,\dur,0.5,\root,4,\octave,2,\trig,Pseq(1!16))])});

	~unnecessary.parts.leadIn=(start:1,music: //		{{{
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
	); //}}}
	~unnecessary.parts.bass2=(start:2,music: //		{{{
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
	); //}}}
	~unnecessary.parts.metabolism=(start:2,music: //{{{ 
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
	);//}}}
//~sections5.metabolism.p;//just making louder hmmm
~unnecessary.ply;
)

( //	metabolism sketh	{{{2
	t=TempoClock.new.tempo_( 1.2 );
	u=TempoClock.new.tempo_( t.tempo*0.666 );
	Pfindur(4,//12,
		Ppar([
			//Pseq(~unnecessary.pbind[1..2]),
			//~unnecessary.pbind[2];
			//a.[0]=Pmono(\bl,\degree,2-1,\dur,0.5,\root,4,\octave,2,\trig,1);
			Pmono(\bl,\degree,2-1,\dur,Pseq([0.5,1.5]*1.5,1),\root,4,\octave,2,\trig,1),
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
	"boom","r"//
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
	Pseq(
		//~parse.(~fortu,1,[[1, 2/3],[1/3 ,1],1],start:1)
		~fortu.parse(1,[[1, 2/3],[1/3 ,1],1],1)
	),
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
			//dur: Pseq(~parse.(~fortu,3,[1,[1,1],1,1],start:3)++5),
			dur: Pseq( 
				~fortu.parse (3,[1,[1,1],1,1],3)++5
			),
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


( //three alien minds  {{{1
	~three= ( key:\three, parent:~trek, proto:~funs,song:[
		"r three alien minds","d3 f5 f e e e", //0
		"now inhabit the bodies of", "d5 c b4 a g f g a", //1
		"Captain Kirk,science officer Spock and", "b c5 f4 c5 d c b4 a a g", //2
		"Doctor Jane Mulhall. As -- ","b c5 d d c c f",//3
		"Planned the con- struc- tion of an- droid","f5 c d c a4 c5 g f",//4
		"ro- bots is un- der- way","e5 d c d  e g4",//5
		"All is pro- cee- ding as ex- pect- ed and as pro- mised (ba- by)","f g a c5 d b-4 c5 d e- b-4 d5 e- d b-4 c5 d",//6
		"I can see no rea- son for con-","e-5 d c b-4 g b- c5 d",//7
		"cern. And yet, I am filled with fore- bo- ding...","d5 c b4 a b c5 e4 a g f#" //8
	]).setupDurs
)

//	idea about saving versioning durs	{{{
~three.key=\threeTEMP //to try stuff out
~three.key=\three //before saving or will disappear !!
// or could simply NOT SAVE UNTIL SATISFIED
// alternatively save a safety copy to backup from or.... }}}
~recorder.(~three,[7,8],2); //		{{{
~recorder.(~three,1,1); /
~three.key.postln; ~three.save; //}}}

( //~three sections {{{2
	~three.cursor_(0);
	~three.parts=();
	"xxxxx..xx".do({|i n| var label="guide"++n.asSymbol; (i==$x).if {~three.parts[label]=(start:n,music:~three.pbind[n])} });
	//a.isNil.if({a=~vsti.('Pianoteq 5')},{a.synth.isPlaying.not.if({a=~vsti.('Pianoteq 5')})});
	~bass0quarters=~three.parse(0,[ [1,1],[1,1,1],1 ]);
	//setup guitars now //		{{{
	try{~g.controller.loaded.not.if{~g=~guitar.()}}{~g=~guitar.()};
	~g.node[1]=\filter->{|in|PlateReverb.ar(in,mix:0.5)};
	~g.node[2]=\filter->{|in|Phaser2.ar(in,rate:0.1,mix:0.5).distort(0.95)};
	~g.node.play(vol:1);
//}}}
	~three.parts.chords= (start:0,lag:0.18,music:Pbind(*[ //		{{{
	degree:Pseq([[5,8],[5,7],[4,6]])-1,
	dur: Pseq(~three.parse(0,[[1,1],[1,1,1],[1]])) ,
	octave:4,
	type:\vsti,
	controller:a,
	legato:0.9,
	root:2,
	scale:Scale.dorian
	]));// 	}}}
	~three.parts.guit0=(start:0,music: //		{{{
		Ppar([
		[
			type:\strum,controller:~g.controller,
			switch:Pseq([\down,\down,\up],3)++Pseq([\down]),
			lag:0.2,
			dur:Pseq( 
					~bass0quarters[0]*[2,1,1]/4 ++ (~bass0quarters[1]*[1.9,1,1.1]/4)//moved with bass
				,3 ),
			amp:Pseq([4,3,3]/10,3),
			'Play Mode: Play Mode':0.6
		].p,
		[
			type:\vsti,controller:~g.controller,
			legato:0.95,
			note:Pseq([ [2,5],0,-5 ]),
			dur:Pseq(
				~bass0quarters+[0,0,3]
			),
			lag:0.1
		].p
		])
	);//}}}
	~three.parts.lick=(start:0,music:[ //		{{{
		degree:Pseq([6,5,7]-1),
		dur:Pseq(~bass0quarters),//Pseq([2,2,4]),
		instrument:\sawSynth,
		att:1,
		rel:4,
		amp:0.05].p);//}}}
	~three.parts.bass0=(start:0,music: //		{{{
		[
			degree:Pseq([2,2,1,1,1,-2])-1,
			dur: Pseq(
				[~bass0quarters[0]*[3,1]/4 , ~bass0quarters[1]*[1,1.4,1.6]/4, 2].flatten
		//		[~bass0quarters[0]*[3,1]/4 , ~bass0quarters[1]*[1,2,1]/4, 2].flatten
			),
			octave:4
	].p
	); //}}}
		~three.parts.guit1=(start:1,music:[ //		{{{
			type:\vsti,controller:~g.controller,
			degree:Pseq([5,[4,6,8],[3,5,8],[2,4],[2.1,4.1,6,8],[3,6,7],[3,5,7]]-1),
			octave:4,
			dur:Pseq(
				~three.parse(1,[[1,1,1,1,1],[1,1],1])
				++
				~three.parse(2,[[1,1,1],[1,1,1,1,1],1,1])
			),
			legato:0.96,
			'Play Mode: Play Mode':0.6,
			lag:0.18
		].p
	);//}}}
	~three.parts.guit1v2=(start:2,music: //		{{{
		v=[
			type:\vsti,controller:~g.controller,
			lag:0.17,
			degree:Pseq([7,8])-1,
			octave:4,
			legato:0.97,
			dur:Pseq(
				~three.parse(2,[1,[1,1,1,1]])
			),
		].p
);//}}}
		~three.parts.strum1=(start:1,music:[ //		{{{
		
			type:\strum,controller:~g.controller,
			dur:
			Pseq(
				~three.parse(1,[1,1,[1,1],1,[1,1],1])
				++ 
				~three.parse(2,[1,1,1,[1,1,1,1,1],1,1])
			)
			,
			//dur:~three.durs[1],
			switch:Pseq([\down,\up,\down],2)
			++
			Pseq([\up,\four,\three,\down])
			++
			Pseq([\down,\five])
			,
			amp:Pseq([0.2,0.01,0.2],2)
			++
			Pseq([0.2,0.1,0.1,0.2],1)
			++
			Pseq([0.2,0.1])
			,
			lag:0.2
		].p;
	);//}}}
	~three.parts.connectorBass=(start:1,music: //		{{{
		[
			degree:Pseq([Rest(),3,2,1,1.1,2,3,4,4-7,0,7,0])-1,
			dur:Pseq(~three.parse(1,[[1,1,1,1,1],[1,1],1])++~three.parse(2,[[1,1,1],[1,1,1,1,1],1,1])++
			~three.parse(3,[[1,1],1,[1,1],1,1])),
			octave:3, root:2, scale:Scale.dorian
		].p
	); //}}}
	~three.parts.chords1=(start:2,syl:2,lag:0.18,music: //		{{{
		[
			type:\vsti,
			note:Pseq([6,[4,-1],5]),
			dur: Pseq( ~three.parse(2,[[1,1,1,1,1],[1,1]],3)++2),
			controller:a,
			octave:4
		].p
	);//}}}
	~three.parts.guitarSetup=(start:3,syl:3,music: //		{{{
		{ 
			{ ~g.node.fadeTime_(0.5);//make this right
				~g.node.play(vol:1);
				~g.node[1]=\filter->{|in|SmoothClipQ.ar(in*6,lo:-0.1,hi:0.1,foldRange:0.5)*0.6};
			}.value;
		}
	);//}}}
	~three.parts.slide=(start:3,syl:4,music:[ //		{{{
				lag:0.2,
				note:Pseries(0,1,6)+[0,4],
				dur:Pseq([0.6,0.1,0.1,0.1,0.1,1]*0.9),
				legato:Pseq([1.5,1.5,1.5,1.5,0.9,2]),
				controller:~g.controller,
				type:\vsti,'Play Mode: Play Mode',0,'Effect 1: On':0].p;
	);   //}}}
	~three.parts.guitar4=( //		{{{
		start:3,syl:4,
		music:
		Pmono(
			//\degree,Pseq([5,5,5,5,4,4,4,4,8,8,8,8,6,6,6,6],inf)+[0,5]-21,
			\pluckD,
			\degree,Pseq([ [1,3,5],[1,4,6] ])-1,
			\amp,0.025,
			\out,[0,1],
			\smooth,Pwhite(0.2,0.3,inf),
			\del,Pwhite(0.5,1,inf),
			\dur,Pseq(~three.parse(3,[ [1,1] ])++2),
			\coef,0.1,//Pbrown(0.1,0.9,0.03),
			\lag,Pwhite(-0.01,0.01)
		);
	);//}}}
		//"Planned the con- struc- tion of an- droid","f5 c d c a4 c5 g f",//4
	~quarters4=~three.parse(4,[1, [1,1], [1,1,1], [1,1] ]);
	~three.parts.bass4=(start:4,music: //fold	{{{
		[
			dur:Pseq( 
				[~quarters4[0]+(~quarters4[1]*0.5),
				~quarters4[1]*0.5,
				~quarters4[2]+(~quarters4[3]*0.5),
				~quarters4[3]*0.5].flatten,   2),
			amp:0.5,
			degree:Pseq([4,3,2,2,5-7,5-7,5-7]-1),
			octave:3
		].p
	);//}}}
	~three.parts.guit4= (start:4,music: //		{{{
		{ { //do these with an event instead??
				var roots=[
					lag:0.19,
					note:Pseq([-7,[2,5],-5]),
					type:\vsti,
					controller:~g.controller,
					dur:Pseq([2,2,4]*~quarters4.sum/4),
					legato:0.94].p;
				var strums=[
					lag:0.2,
					type:\strum, switch:Pseq([Rest(),\down,\up])++Pseq([\down,\down,[Rest(),\up].choose],3),
					controller:~g.controller,
					dur:Pseq([2,1,1]/2,4)*~quarters4.sum/4,
					'Play Mode: Play Mode':0.6].p;
				~g.node.play(vol:0.5);
				Ppar([roots,strums]);
				}.value
			}
		);//}}}
	try{~h.controller.loaded.not.if{~h=~guitar.()}}{~h=~guitar.()};
	~three.parts.guitarPatches5=(start:5,lag:-1,music: //		{{{
		{
			{
				~h.node[1]=\filter->{|in| in*2*0.5};
				~g.node[1]=\filter->{|in|SmoothClipQ.ar(in*8,lo:-0.1,hi:0.1,foldRange:0.5)*0.5};
			}.value
		}
);//}}}
	~three.parts.guitarh5=(start:6,lag:0.2,music: //		{{{
	[
		degree:Pseq([1,2,3,5,4]-1),
		//dur:Pseq(1!4++[4]/2),
		dur: Pseq(~three.durs[6].list[0..3]++~three.durs[6].list[4..7].sum),
		legato:0.96,
		root:5,
		octave:3,
		type:\vsti, controller:~h.controller,
		'Play Mode: Play Mode':0
	].p;
	); //}}}
	~quarters6= ~three.parse(6,1!4!4);
	~three.parts.guitarh6II=(start:6,syl:7,lag:0.10,music:[ //		{{{
		degree:Pseq([6.1,4]-1),
		dur: Pseq(~quarters6[2..3]) ,
		legato:0.96,
		root:5,
		octave:3,
		type:\vsti, controller:~h.controller,
	].p;
); //}}}
	~three.parts.guitarh5Strum=(start:6,syl:5,lag:0.2,music:[ //		{{{
	//var b2s=[
		type:\strum,
		controller:~h.controller,
		switch:Pseq([\down, \up, \down,],3),
		//dur:Pseq([1,1,2]/2,3),
		dur:Pseq(~three.durs[6].list[6..7]++~three.durs[6].list[8..9].sum,3),
		'Play Mode: Play Mode':0.6
	].p;
); //}}}
	q=0.9; ~gr=0.2; 
	~three.parts.guit6=(start:6,lag:0.2,music:[ //		{{{
		degree:Pseq([1,2,3,5,5.1,6]-1),
		//dur:Pseq([1,1,1, (1-~gr),~gr,4 ]/2*0.98),
		dur:Pseq(~three.durs[6].list[0..2]++[~three.durs[6].list[3]-~gr,~gr,3.5]),
		legato:Pseq([q,q,q,1.4,1.4,1]),
		root:5,
		octave:3,
		type:\vsti,
		controller:~g.controller,
		'Play Mode: Play Mode':0
	].p;
);//}}}
~three.parts.bass6=(start:6,music:[ //		{{{
	degree:Pseq([Rest(),1,4,1,2]-1),
	root:10,
	octave:2,
	amp:0.4,
	dur:Pseq( ~three.parse(6, 1!4!4))
].p);//}}}
	~three.parts.saw6=(start:6,music:[ //		{{{
		degree:Pseq([Rest(),1,4,1]-1),
		//dur:Pseq([5,4,4,2 ,3])/2,
		dur:Pseq( ~three.parse( 6, [1!5,1!4,1!4,1!2])++[3]) ,
		//type:\vsti,
		//controller:p.controller
		instrument:\sawSynth,
		rel:3,att:0.2,
		//amp:0.35,
		amp:0.1,
		root:5,octave:[4,5]
	].p;
);//}}}
	~three.parts.pf6=(start:6,syl:7,music:[ //		{{{
		degree:Pseq([2,4,6,6.1,1,4,5,6])-1,
		root:5,
		instrument:\default,
		octave:[6,5],
		//dur:0.5,
		dur:Pseq(~three.durs[6].list[8..]),
		legato:3,
		amp:0.10
	].p;
);//}}}
	SynthDef(\avsd, //		{{{
		{
			|freq=400 att=0.05 |
			var fenv= Env.perc(att,8.5).kr(gate:1);
			var env= Env.perc(att*2.2,8.5).kr(gate:1);
			var tail= Env.perc(att*2.2,11).kr(2,gate:1);
			var freqs= freq*rrand(0.99,1.01!2);//
			var sig= SawDPW.ar(freqs,mul:\amp.kr(0.05));
			sig=Formants.ar(freqs/2,Vowel())*0.1+sig;
			sig=MoogVCF.ar(sig,fenv*1500+(freq),0.9);
			sig=PlateReverb.ar(sig,mix:0.2);
			Out.ar(\out.ir(0),sig*env);
		},[0.3]
	).add; //}}}
	SynthDef(\tritri,{//{{{
		|freq=400 gate=1|
		var sig=DPW3Tri.ar(freq,\amp.kr(0.1));
		var env= Env.asr(\att.kr(0.1),\sus.kr(1),\rel.kr(2)).kr(2,gate:gate);
		Out.ar(\out.ir(0),sig*env);

	}).add; //}}}
	~three.parts.forboding8=(start:8,music://{{{
		Ppar([
		[
			degree:Pseq([\r,[0,2,5],[-1,1.1]]-1),
			root:2,
			scale:Scale.mixolydian,
			octave:[4,5],
			instrument:\tritri,
			att:0.2,
			rel:3,
			amp:0.06,
			dur:Pseq(~three.parse(8,[1!3,1!5,1!2])),
		].p,
		Pmono(
			*[
				\avsd,
				degree:Pseq([ [1,3],[0,2],[6-7,1.1]]-1),//thicken chord?
				//degree:Pseq([ [1,3],[0,2],[5-7,1]]-1),
				att:2,
				scale:Scale.mixolydian,
				dur:Pseq(~three.parse(8,[1!3,1!5,1!2])),
				root:2,
			]
		),
		~three.pbind[8],
		[
			degree:Pseq([[1,1-7],6-7,7-7,[6-7,1.1],5-7-7]-1),
			//degree:Pseq([1,6-7,7-7,[5-7,1]]-1),
			root:2,
			octave:4,
			dur:Pseq(~three.parse(8,[[1,1],1,1!5,1!2]))++Pseq([8]),
			scale:Scale.mixolydian
		].p,

		[ //final chord
			instrument:\avsd,att:8,amp:0.018,degree:Pseq([\r,[5,7,9,11.1]-1]),dur:Pseq([8,12]),octave:4,root:2,
		].p
	])
);//}}}
);
(
	{ ~three.cursor_(0); //		{{{
	2.wait;  //to give time for vstis
	~three.ply;
}.fork //}}}
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
// get a section using list comprehensions
all {:x,x<-~xtreme.parts,x.class==Event,x.start==3}
//gets the keys and the parts
all {:x,x<-~xtreme.parts.keys,var y=~xtreme.parts[x],y.class==Event,y.start==3 }
//find all Events
all {:x,x<-~xtreme.parts.keys,var y=~xtreme.parts[x],y.class==Event,y.start==3,::y.p };
//find and play with bass in name
all {:x,x<-~xtreme.parts.keys,x.asString.find("bass",true).isNil.not,::~xtreme.parts[x].p}
all {:x,x<-~xtreme.parts.keys,x.asString.find("bass",true).isNil.not,::~xtreme.parts[x].music.class.postln}
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
//	strum studio	{{{1
( //	nice harsh chain	{{{3
	{
		g=~guitar.();
		({g.controller.loaded==false}).while{0.01.wait};
		g.node[1]=\filter->{|in|TwoTube.ar(in,-0.81,0.9,111,321).fold(0.1)*5};
		g.node[2]=\filter->{|in| RLPFD.ar(in,2200,0.5)*15};
		g.node[3]=\filter->{|in| Phaser2.ar(in,rate:0.1,fb:-0.9,mix:0.5)};
		q=[strum:0.06,type:\vsti,\controller:g.controller,\midinote: Pwhite(30,70,inf).clump(3) ].p;
		p=q.play;
	}.fork
)
p.stop;
//}}}
(// cool pattern //		{{{3
//setup
	~strum= [ 'down', 'muted', 'up', 'alt-bass', 'one', 'two', 'muffle-down', 'three', 'muffle-up', 'four', 'mute', 'five', 'six', ];
	e=();
	~strum.do{|i x| e.[i.asSymbol]=x};
)

(
	var len = 18;
	~strumPattern=Pseq([e.down,e.up,e.one],len);
	m.set('Play Mode: Play Mode',0.5);
	p=( 
		Ptpar([
		0.05,[midinote:~strumPattern+72,dur:0.3,legato:0.5].p,
		0,[midinote:Pseq([[60,63],58],len*1.5),dur:0.3,legato:0.95].p
	])
	<>
	(type:\vsti,controller:m)
).play
) //}}}
//old rekkerd - strum gets keyswitch order right //		{{{3
g=~guitar.();
(
	Ptpar (
		[
			0.2,[midinote: Ptuple([Pseq([65,68],inf),Pwhite(72,80,inf)]) ,'Play Mode: Play Mode':0.6,strum:0.02,type:\vsti,controller:g.controller].p,
			0,[instrument:\snare,dur:"0x".asDrumPat(4,inf)].p,
			0,[instrument:\hihat,dur:0.25].p
		]
	).play;
a={Dust.ar(8.9,0.4)!2}.play;
b={BrownNoise.ar(0.01).dup}.play
)
//GTR EVENT TYPE (experimental) //		{{{

g=~guitar.()
(
	Event.addEventType(\gtr,{|server| 
		~switch.isNil.not.if { ~midinote=[~midinote,~switch].flatten };
		~type=\vsti;
		currentEnvironment.play},(switch:72))
)//}}}
(//examples //		{{{4
	[type:\strum,switch:Pseq([\up,\down],8),amp:Pseq([0.8,0.5],inf),lag:Pseq([0.01,0.00],inf),dur:0.1,controller:g.controller].p.trace.play;
	(type:\vsti,note:6,controller:g.controller,'Play Mode: Play Mode':0.6,dur:13).play;

)
(
	[type:\strum,controller:g.controller,switch:Pxrand(~stru,inf),dur:Pbrown(0.1,0.5,0.05,inf)].p.play;
	['Play Mode: Play Mode',0.6,type:\vsti,controller:g.controller,midinote:Pwhite(60,70,inf),dur:Pbrown(1,2,0.05,inf)].p.play;
)

~strums[\down]

(type:\gtr,controller:g.controller,midinote:61,'Play Mode: Play Mode':0.6,strum:0.02,dur:4).play
(type:\gtr,controller:g.controller,midinote:60,switch:72,'Play Mode: Play Mode':0.6,strum:0.02).play
(dur:20,type:\gtr,controller:g.controller,midinote:[63,60],switch:e.down,'Play Mode: Play Mode':0.6,strum:0.02).play
(dur:20,type:\vsti,controller:g.controller,midinote:[63,60],'Play Mode: Play Mode':0.6,strum:0.02).play
[type:\gtr,controller:g.controller,switch:Pseq([e.down,e.up],inf),dur:0.4,'Play Mode: Play Mode':0.6,strum:0.03].p.trace.play


e=e.collect({|i|i+72});

//	rhythm parsing with lyrics	{{{1

a=[\a,\f,\c,\a];
//TODO..distinguish duplicates
b=a.collect{|i x| i->x}.asDict
~durss=[1,3,2,4,3]
~durss[(b[\f])]
~lyrr={|symbol| b[symbol]};
~lyrr.(\c);

(//make into pseudo method!!
	tart:lyrr={|symbol section=8| 
		a=~three.lyrics[section];
		a=a.split($ ).collect(_.asSymbol);
		b=a.collect{|i x|i->x}.asDict;
		~three.durs[section].list[b[symbol]];
	};
	~lyrr.(\filled)
)
//concat		{{{1
}}
~c=~concatSongs.(~three,~unnecessary);
//	my strum	{{{

(
	//DWGSoundBoard.ar(inp: 0,  c1: 20,  c3: 20,  mix: 0.8,  d1:103,  d2:188,  d3:202,  d4:223,  d5:231,  d6:262,  d7:315,  d8:385)
	SynthDef(\myG,{ |out=0, freq=440, amp=0.5, gate=1, c3=20, pan=0,fB = 80 pos=0.14 c1=1 rel=0.1|
		var env = Env.new([0,1, 1, 0],[0.001,0.001, 0.005],[5,-5, -8]);
		var inp = amp *LFClipNoise.ar(2000) * EnvGen.ar(env,gate);
		 var sig = DWGPluckedStiff.ar(freq+SinOsc.kr(1.9), /*amp*/0.1, gate,pos,1,c3,inp,fB);
		 sig = DWGPluckedStiff.ar(freq+SinOsc.kr(1.9,mul:0.1), amp, gate,pos,c1,c3,sig*env.kr/2,rel,fB);
		//DWGPluckedStiff.ar(freq: 440,  amp: 0.5,  gate: 1,  pos: 0.14,  c1: 1,  c3: 30,  inp: 0,  release: 0.1,  fB: 2)
		//these are cool!
		 //sig = DWGPluckedStiff.ar(freq+SinOsc.kr(1.9), /*amp*/0.1, gate,pos,1,c3,sig*0.01,fB);
		sig= DWGSoundBoard.ar(sig,  c1: 80,  c3: 20,  mix: 0.9,  d1:103,  d2:188,  d3:202,  d4:223,  d5:231,  d6:262,  d7:315,  d8:385);
		DetectSilence.ar(sig, 0.01, doneAction:2);
		Out.ar(out, Pan2.ar(sig * 0.1, pan));
	}).add
)

(
	{
		loop{
			{var fb=rand(100);var pos=rand(0.4)+0.08;fb.postln;6.do{ Synth(\myG,[\pos,pos,\freq,rrand(30,80).midicps,\fb,fb]);rrand(0.015,0.05).wait }}.fork;
			rrand(0.2,2.5).wait;
		}

	}.fork
)
(
	var strings = [0,5,10,15,19,24];
	var fingers = strings.collect(_+rand(3));
	{var fret=rand(2);fingers.do{|i|Synth(\myG,[\freq,((fret+40+i).midicps),
	\c1,1.5,
	\rel,0.78,
	\fB,5,
	\pos,0.3,
	\c3,1]);0.01.wait}}.fork
)

//play a few of each of these...
PmonoArtic(*[\sawSynth,legato:Prand([1,1,1,1,0.1,0.5],inf),amp:0.02,rel:4,note:Pwhite(-20,20,inf),dur:Pbrown(0.1,1)]).play;
PmonoArtic(*[\myG,note:Pwhite(0,12)+rrand(-10,10),legato:Prand([0.9,1.1],inf),pan:rrand(-1,1)]).play


