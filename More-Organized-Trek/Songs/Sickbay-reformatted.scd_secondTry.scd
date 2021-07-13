(
SynthDef(\wash,{| att=2 rel=3| 
	Saw.ar(\freq.kr(400,\freqLag.kr(2.5))*Rand(0.99!4,1.01),\amp.kr(0.1,1))*
	Env.perc(att,rel).kr(2,gate:\gate.kr(1))
	=>MoogLadder.ar(_,800*Rand(0.5,8.3!4)*SinOsc.kr(Rand(2.5,3.1)).range(Rand(0.95!4,0.98),1.03),res:0.8)
	=>Pan2.ar(_,Rand(-1,1!4))
	=>Out.ar(\out.ir(0),_)
}).add;

SynthDef(\door,{ 
	var len=1;
	var sig=WhiteNoise.ar();
	var env= Env.linen(0.01,len-0.02,0.01).kr(2,gate:1);
	var fenv= Env.linen(len-0.21,0.18,0.03).kr(2,gate:1);
	sig=RHPF.ar(sig,fenv.range(200,2000),rq:5);
	Pan2.ar(sig*env*\amp.kr(1),Line.kr(0.2,1,len))
	=>Out.ar(0,_)
}).add;

SynthDef(\sawTw,{ |freq=400 amp=1 spread=5 | 
	var env= Env.perc(0.2,6!4.rand).kr(2,gate:1);
	var sig=Splay.ar ( Saw.ar( rrand(spread,(-1*spread))+freq,0.2) )
		.distort*env
		;
	sig=sig+CombN.ar(sig,1,0.3,3);
	sig=sig/1.5+Phaser2.ar(sig,rate:0.2	);
	Out.ar(\out.kr(0),sig*amp)
	//Out.ar(0,sig)
}).add;

SynthDef(\verbb,{|in out| 
	var sig= In.ar(in,2);
	sig=PlateReverb.ar(sig,mix:0.8)
	* Env.cutoff(5).kr(2,gate:\gate.kr(1)) ;
	Out.ar(0,sig);
	DetectSilence.ar(sig,doneAction:2)
}).add;

SynthDef(\mcCoy,{|freq out=0 amp=0.1| 
	var env = Env.perc(0.1,2).kr(2,gate:\gate.kr(1));
	var sig = Gendy1.ar(minfreq:freq-20,maxfreq:freq+20);
	Out.ar(out,sig*env*amp)
}).add;
SynthDef(\crackle,{ Env.cutoff(0.1).kr(2,gate:\gate.kr(1)) * Dust.ar(5,\amp.kr(0.5))=> 
Decay.ar(_,0.003)=>
Out.ar(\out.ir(0),_)}).add;

)

(/// line 326
 

	Monitor.new().play(2,2,0,2);
~speaker ? ~speaker=Library.at(\functions,\prep).("/Users/michael/tank/IR/Saane/Speakers_&_Telephones/Very_small_speaker_mono.wav");
	Song.dursFile_("/Users/michael/tank/super/theExtreme_Sep18");
	~sickBay=Song(\sickBay,[]).current;
	["Sick Bay.. Sick Bay, Mc- Coy","e c f# d e g#"].addLine; //0
	P(\guide0,start:0,music:~sickBay.pbind[0]=>Pfin(2,_));
	P(\kirkFace,start:0,music:{
		{~stills.preview('kirk-face',~sickBay.secLoc[2],monitor:0)}.defer
	});

	P(\mcCoy0,start:0,syl:1,music: 
		{
			[
				amp:0.03,
				instrument:\mcCoy,
				//out:~sickBay.mcCoyBus,
				out:Effect({|i| PartConv.ar(i,2048,~speaker)},out:0).bus.index,
				midinote: ~sickBay.tune[0].list [ 2..5 ].q,dur:~sickBay.durs[0].list[ 2..5 ].q
			].pp;
	}); 
		["Sar- gon here, i'm in your deck six brief- ing room","b- g- c  e- f g- a- b- b g# d "].addLine; //1
		~justTheTune.('Sar- gon here');
["(enter Thalassa)","e5"].addLine; //f maj 7 //2
		~justTheTune.('enter Thalassa');
		P(\plucks5,start:5,music:{ [ 
			degree:[Rest(),3,1,5-7,[3,6]-7].q-1,
			root:6,
			dur: ~sickBay.parse(5,[[1,1,1,1],1,0.66,[0.34,1],[1,1]]).q,
			octave:4,
			amp:0.3
		].pp 
	});
	P(\padBass5,start:5,music: 
	[
		degree:[\r,[1,5+7,3+14],[6-7,6,6+4,6+7]].q-1, //idea write 1 5' 3''
		root:6,
		octave:[2,3],
		instrument:\wash,
		out:[1,1,2].q,
		amp:0.2,
		att:2,
		dur:~sickBay.parse(5,[[1,1,1,1],[1,1,1],[1,1]]).q
	].p);
	P(\gliss,start:5,syl:6,music:{
		var a= (
			octave:4,q:2,cutoff:1900,
			degree:[6-7,3,6,8,9]-1,freqLag:10,root:6,
			instrument:\glissChord,
			out:2,dur:7,\rel:5,\att:9)
			.play;
			Song.durs[5].list[6..9].sum.wait;
			(type:\set,id:a[\id],degree:[1,5,8,11,12]-1,octave:4,root:2)
	=>Prout(_) => _.play
	});
//glissChord
	{Saw.ar(
		(\freq.kr(400,\freqLag.kr(2))
	+(LFBrownNoise1.ar(2!5))*rrand(0.99,1.01!5)
	=> Vibrato.kr(_,3,depth:0.004,delay:4,onset:4)))
	+ WhiteNoise.ar(0.001)
	* Env.asr(\att.kr(1),\amp.kr(1),\rel.kr(3)).kr(0,gate:\gate.kr(1))
	//=>MoogFF.ar(_,2800)
	=>RHPF.ar(_,Line.kr(0.1,2,17)*\cutoff.kr(1000),\q.kr(1))
	=>MoogFF.ar(_,6666,1,mul:2)
	=>Splay.ar(_)
	//=>FreeVerb.ar(_,1,\wet.kr(0.7)) *3
	=>( JPverb.ar(_,3,mix:\wet.kr(0.7))<!DetectSilence.ar(_,time:1,doneAction:2) ) 
	=>Out.ar(\out.ir(2),_)}=>SynthDef(\glissChord,_)=>_.add; 
["You sound ter- ri- ble wait there for me","c4 d e c g3 e-4 d b-3 f"].addLine;  //3
~justTheTune.('ter- ri');

	P(\mcCoy3,start:3,music: {
		( Song.currentSong.pbind[3]<>(instrument:\mcCoy,
			//out:~sickBay.mcCoyBus,
			out:Effect({|i| PartConv.ar(i,2048,~speaker)},out:0).bus.index,
			amp:0.03) ).play  
	});
	P(\static3,start:3,music: 
		(instrument:\crackle,dur:5,out:~sickBay.mcCoyBus,amp:0.3));
		["Sar- gon what's wrong?","b4 g b e5"].addLine;  //4
	P(\image,start:4,music:{{
		~stills.preview('whatsWrong?')
	}.defer(0.01)});
	P(\whatsWrong4,start:4,music:
		Ppar([
			Song.currentSong.tune[4]<>(instrument:\sawTw,\amp:0.5)

			,
			[		instrument:\sawTw,
				dur:~sickBay.parse(4,[[1,0.5],[0.5,1,1]]).q,
				spread:3,
				degree:[\r,4].q,
				out:[0,1,2],
				root:0,
				octave:[3,2],
				amp:0.5
			].p,
			Pseq([(degree: [5,7,10]+[0,0,0,7,7,7]-1 ,octave:4,strum:0.1,amp:0.1,sustain:1)])
	])
//=>_.play
); 
P(\verbFade4,start:4,music:{~sickBay.thalassaVerb.release(5)});
		["no- thing of im- portance, Fa- tigue per- haps","f g- a- g- b- g- b- a- g- e-"].addLine;  //5
		~justTheTune.('Fa- tigue');
P(\padBass5,start:5,music: 
	 Prout({
		var b, p = (out:2,root:6, instrument:\wash, amp:0.2, att:2,); //proto
		var a=~sickBay.parse(5,[[1,1,1,1],[1,1,1],[1,1,1]]);
		a[0].wait;
		(dur:a[0],octave:[2,3],degree:[1,5+7,3+14]-1,proto:p).play;//chord1
		a[1].wait;
		b=(proto:p,type:\note,octave:[2,3],degree:[6-7,6,6+4,6+7]-1,freqLag:10).play;//chord2
		b.postln;
		a[2].wait;
		(type:\set,id:b[\id],degree:[5.1-7,5.1,5.1+4,5.1+7]-1,root:6,octave:[2,3]).play//bend
	});
); 
	P(\doorOpen,start:2,music: 
		//~stills.set('enter-Thalassa',(37*60+54.30));
		 
		Prout({
			var vol=0.5;
			var thalassaBus=Bus.audio(s,1).index;
			~sickBay.thalassaVerb=Synth(\verbb,[\in,thalassaBus]);
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
		})
		
	); 
		["(beat) (formula) Sar- gon's for- mu- la...","d d5 e f# a f# c"].addLine;  //6
		~justTheTune.('(formula)');

		["yes, I wan- ted to be cer- tain there was no","f4 c#4 c c# f c# c b-3 a- b- e-4"].addLine;  //7
		["er- ror. For- mu- la is co- ","d4 f3 g a b g b "].addLine; //8
		["rrect. Don't be concer -- ned, this is an","d4 c# e d f# g f# d e f# "].addLine;  //9
		["ex- cel- lent bo- dy. "," g#4 e d d c#"].addLine; //10
		["There I feel be- tter al- rea- dy","c4 g3 a b c4 b3 a b d4 c"].addLine; //11
		//in Time
		["in Time a host ","b3 b4 a b"].addLine; //12
		[" -- body will become... (cis) ","c# b a g a b c#3"].addLine; //13
		//"(d a fis) accustomed to us (fis)"
/// sickBay sections {{{1
//~sickBay.resources=();

)
(


~speakerSt.isNil.if {Library.at(\functions,\prepStereo).("/Users/michael/tank/IR/Saane/Speakers_&_Telephones/Small_speaker_stereo.wav")};

//Stills   ! {{{
~stills.isNil.if{~stills=Stills("/Users/michael/tank/Trek/video for stills etc/media/return to tomorrow.mov")}; 
~stills.set('whatsWrong?',2288.6);
~stills.set('kirk-face',(38*60+2.81));
~stills.set('enter-Thalassa',(37*60+54.30));     
~stills.set('sargonsFormula',2291.43); 
	//sections
	//P(\guide1,start:1,music:~sickBay.pbind[1]);
	//should this be done as an event?	

