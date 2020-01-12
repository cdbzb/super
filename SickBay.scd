Reaper.open


(
	SynthDef(\speaker,{|out| 
		In.ar(out,1)
		//=> FreeVerb.ar(_,room:0.8,mix:0.8)
		=> PlateReverb.ar(_,mix:0.8) * Env.cutoff(1).kr(2,gate:\gate.kr(1))
		=> PartConv.ar(_,4096,~speaker)
		=> ReplaceOut.ar(out,_);
	}).add
)
a={PinkNoise.ar(0.05)}.play(s,9)
a.free

~stills.set('sargonsFormula',2291.43)
~stills.set('sargonWhatIsIt',2285.76)
~stills.set('nothingOfImportance',2287.18)
~stills.preview('sargonWhatIsIt')
~stills.preview('nothingOfImportance')
~stills.preview('sargonsFormula')
(

	b.free;
	b=Synth(\verbb,addAction:\addToTail);

	{
		~stills.isNil.if{~stills=Stills("/Users/michael/tank/Trek/video for stills etc/media/return to tomorrow.mov")};
		~stills.set('kirk-face',(38*60+2.81));
		//~stills.markers['kirk-face']
		~stills.set('enter-Thalassa',(37*60+54.30));
		//Reaper.go(38*60+2.81);//kirk face
		{~stills.preview('kirk-face',5.5)}.defer(0.01);
		2.wait;
		s.bind{Synth(\door)};
		1.05.wait;
		{~stills.preview('enter-Thalassa')}.defer(0.01);
		0.01.wait;
		(instrument:\sawTw,degree:[4-7,6-7,8-7,10-7,4,6,8,10]-1,strum:0.1,octave:[5],sustain:4).play;
		0.3.wait;
	//Reaper.go(38*60+3.11)//enter Thalassa
	//Reaper.go(37*60+54.30)//door open
	}.fork
)

///////markers
	Reaper.go(38*60+2.81) //waiting
	Reaper.go(38*60+8.58)//Sargon what's wrong??
	Reaper.go(37*60+54.30)//door open

(///song
	~sickBay=Song(\sickBay,[
		"Sick Bay.. Sick Bay, Mc- Coy","e c f# d e g#",//0
		"Sar- gon here, i'm in your deck six brief- ing room","b- g- c  e- f g- a- b- b g# d ",//1
		"(enter Thalassa)","e5",//f maj 7 //2
		"You sound ter- ri- ble wait there for me","c4 d e c g3 e-4 d b-3 f", //3
		"Sar- gon what's wrong?","b4 g b e5", //4
		"no- thing of im- portance, Fa- tigue per- haps","f g- a- g- b- g- b- a- g- e-" //5
		"(formula) Sar- gon's for- mu- la...","d e f# a f# c", //6
		//"yes, I wan- ted to be cer- tain there was no"
		//"er- ror. For- mu- la is co- rrect. This is an"
		//"ex- cel- lent bo- dy. There I feel be- tter al- rea- dy"
		//"in Time...."
	])
)
~recorder.(~sickBay,3)
//m=Monitor.new.play(1,1,9,1)

~sickBay.pl
(/// sickBay sections
//synthdefs
~sickBay.resources=();
SynthDef(\door,{ //{{{
	var len=1;
	var sig=WhiteNoise.ar();
	var env= Env.linen(0.01,len-0.02,0.01).kr(2,gate:1);
	var fenv= Env.linen(len-0.21,0.18,0.03).kr(2,gate:1);
	sig=RHPF.ar(sig,fenv.range(200,2000),rq:5);
	Pan2.ar(sig*env*\amp.kr(1),Line.kr(0.2,1,len))
	=>Out.ar(0,_)
}).add;
	//}}}
	SynthDef(\sawTw,{ |freq=400 amp=1 | //{{{
		var env= Env.perc(0.2,6!4.rand).kr(2,gate:1);
		var sig=Splay.ar ( Saw.ar( (10.0!4).rand+freq-5,0.2) )
			.distort*env;
		sig=sig+CombN.ar(sig,1,0.3,3);
		sig=sig/1.5+Phaser2.ar(sig,rate:0.2	);
		Out.ar(\out.ir(0),sig*amp)
		//Out.ar(0,sig)
	}).add;
//}}}
	SynthDef(\verbb,{|in out| //{{{
		var sig= In.ar(in,2);
		sig=PlateReverb.ar(sig,mix:0.8);
		Out.ar(0,sig);
		DetectSilence.ar(sig,doneAction:2)
	}).add;
//}}}
~speaker.isNil.if {~speaker=Library.at(\functions,\prep).("/Users/michael/tank/IR/Saane/Speakers_&_Telephones/Very_small_speaker_mono.wav")};//{{{
~speakerSt.isNil.if {Library.at(\functions,\prepStereo).("/Users/michael/tank/IR/Saane/Speakers_&_Telephones/Small_speaker_stereo.wav")};//}}}
~stills.isNil.if{~stills=Stills("/Users/michael/tank/Trek/video for stills etc/media/return to tomorrow.mov")};//{{{
~stills.set('kirk-face',(38*60+2.81));
~stills.set('enter-Thalassa',(37*60+54.30));//}}}
	//sections
	~sickBay.guide0=(start:0,music:~sickBay.pbind[0]=>Pfin(2,_));
	SynthDef(\speaker,{|in out=0| //{{{
		(
			In.ar(in,1)
			//=> FreeVerb.ar(_,room:0.8,mix:0.8)
			//=> PlateReverb.ar(_,mix:0.8) 
			* Env.cutoff(1).kr(2,gate:\gate.kr(1))
		)
		=> PartConv.ar(_,4096,~speaker)
		=> Out.ar(out,_);
	}).add;//}}}
	SynthDef(\mcCoy,{|freq out=0 amp=0.1| //{{{
		var env = Env.perc(0.1,2).kr(2,gate:\gate.kr(1));
		var sig = Gendy1.ar(minfreq:freq-20,maxfreq:freq+20);
		Out.ar(out,sig*env*amp)
	}).add;//}}}
	~sickBay.kirkFace=(start:0,music:{{~stills.preview('kirk-face',~sickBay.secLoc[2],0)}.defer});
	~sickBay.guide1=(start:1,music:~sickBay.pbind[1]);
	~sickBay.mcCoyBus=Bus.audio.index;
	~sickBay.mcCoy0=(start:0,syl:1,music://{{{
		[
			amp:0.03,
			instrument:\mcCoy,
			out:~sickBay.mcCoyBus,
			midinote: ~sickBay.tune[0].list [ 2..5 ].q,dur:~sickBay.durs[0].list[ 2..5 ].q].p;
	); //}}}
	~sickBay.guide0II=(start:0,syl:1,music: 
		(dur:20,instrument:\speaker,in:~sickBay.mcCoyBus,out:2));
	~sickBay.mcCoy3=(start:3,music:(~sickBay.pbind[3]<>(instrument:\mcCoy,out:~sickBay.mcCoyBus,amp:0.03)));
	SynthDef(\crackle,{ Env.cutoff(0.1).kr(2,gate:\gate.kr(1)) * Dust.ar(5,\amp.kr(0.5))=>Out.ar(\out.ir(0),_)}).add;
	~sickBay.static3=(start:3,music:
		(instrument:\crackle,dur:5,out:~sickBay.mcCoyBus,amp:0.5));
	~sickBay.doorOpen=(start:2,music: //{{{
		//~stills.set('enter-Thalassa',(37*60+54.30));
		{ var vol=0.5;
			Routine{
				var thalassaBus=Bus.audio(s,1).index;
				Synth(\verbb,[\in,thalassaBus]);
				s.bind{Synth(\door,[\amp,vol])};
				1.05.wait;
				{~stills.preview('enter-Thalassa')}.defer(0.01);
				0.01.wait;
				(
					out:thalassaBus,
					amp:vol,
					instrument:\sawTw,
					degree:[4-7,6-7,8-7,10-7,4,6,8,10]-1,
					strum:0.1,octave:[5],sustain:4
				).play;
			}.play
		}
	)//}}}
)

~sickBay.mcCoyBus
Bus(index:23).scope
~sickBay.cursor_(0).play
~sickBay.cursor
~sickBay.play
~sickBay.durs[2].list
~sickBay.cursor_(2).play
~sickBay.pbind[0].play
~sickBay.durs[0].list
~sickBay.doorOpen.play
s.latency_(0.1)
~sickBay.play
~sic
~sickBay.pbind[3].cs
~sickBay.pbind.q.play
~sickBay.pbind.do(_.play)
~sickBay.pbind[0].play
(
	Pfx(
		[note:[1,3,5].q-22,out:1,pan:-1].p.pad,
		\speaker
	).play
)
