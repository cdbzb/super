
( ~xtreme=Song( //				{{{
		\song,
		//play:{~parts.do(_.postln)},
		[
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
	);

	~xtreme.ready={ try{~syn1.controller.loaded.not.if{false}}{true}}; 
	~synthsLoaded.isNil.if{"/Users/michael/tank/super/song-Synthdefs.scd".load};
	//~xtreme.init={ try{~syn1.controller.loaded.not.if{~syn1.init}}{~syn1=~synful2.()}}; 
	//~xtreme.init;
	//~xtreme.parts.ply;
	//~xtreme.play
	//}}}


 //// xtreme sections		{{{2
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
	//~xtreme.parts=();
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

