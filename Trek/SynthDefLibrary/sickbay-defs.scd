fork{
	SynthDef(\wash,{| att=2 rel=3 curve=( -4 )| 
	Saw.ar(\freq.kr(400,\freqLag.kr(2.5))*Rand(0.99!4,1.01),\amp.kr(0.1,1))*
	Env.perc(att,rel,curve:curve).kr(2,gate:\gate.kr(1))
	=>MoogLadder.ar(_,800*Rand(0.5,8.3!4)*SinOsc.kr(Rand(2.5,3.1)).range(Rand(0.95!4,0.98),1.03),res:0.8)
	=>Pan2.ar(_,Rand(-1,1!4))
	=>Out.ar(\out.ir(0),_)
}).add.tag(\keys);

	SynthDef(\washSus,{| att=2 rel=3 curve=( -4 )| 
	Saw.ar(\freq.kr(400,\freqLag.kr(2.5))*Rand(0.99!4,1.01),\amp.kr(0.1,1))*
	Env.asr(att,1,rel,curve:curve).kr(2,gate:\gate.kr(1))
	=>MoogLadder.ar(_,800*Rand(0.5,8.3!4)*SinOsc.kr(Rand(2.5,3.1)).range(Rand(0.95!4,0.98),1.03),res:0.8)
	=>Pan2.ar(_,Rand(-1,1!4))
	=>Out.ar(\out.ir(0),_)
}).add.tag(\keys);

SynthDef(\door,{
	var len=1;
	var sig=WhiteNoise.ar();
	var env= Env.linen(0.01,len-0.02,0.01).kr(2,gate:1);
	var fenv= Env.linen(len-0.21,0.18,0.03).kr(2,gate:1);
	sig=RHPF.ar(sig,fenv.range(200,2000),rq:5);
	Pan2.ar(sig*env*\amp.kr(1),Line.kr(0.2,1,len))
	=>Out.ar(\out.kr,_)
}).add.tag(\sfx);

SynthDef(\sawTw,{ |freq=400 amp=1 spread=5 | 
	var env= Env.perc(0.2,6!4.rand).kr(2,gate:1);
	var sig=Splay.ar ( Saw.ar( rrand(spread,(-1*spread))+freq,0.2) )
	.distort*env
	;
	sig=sig+CombN.ar(sig,1,0.3,3);
	sig=sig/1.5+Phaser2.ar(sig,rate:0.2	);
	Out.ar(\out.kr(0),sig*amp)
	//Out.ar(0,sig)
}).add.tag(\keys);

SynthDef(\verbb,{|in out| 
	var sig= In.ar(in,2);
	sig=PlateReverb.ar(sig,mix:0.8)
	* Env.cutoff(5).kr(2,gate:\gate.kr(1)) ;
	Out.ar(0,sig);
	DetectSilence.ar(sig,doneAction:2)
}).add.tag(\verb);

SynthDef(\mcCoy,{|freq out=0 amp=0.1| 
	var env = Env.perc(0.1,2).kr(2,gate:\gate.kr(1));
	var sig = Gendy1.ar(minfreq:freq-20,maxfreq:freq+20);
	Out.ar(out,sig*env*amp)
}).add.tag(\gendy);
SynthDef(\crackle,{ Env.cutoff(0.1).kr(2,gate:\gate.kr(1)) * Dust.ar(5,\amp.kr(0.5))=> 
Decay.ar(_,0.003)=>
Out.ar(\out.ir(0),_)}).add.tag(\sfx);
}




