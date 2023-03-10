
    (

    SynthDef(\help_flute, { |out=0,freq=100,att=0.01,amp=0.5,endr= 0.5, jetr= 0.24,jetRa=0.33, gate= 1, release= 0.01,noisegain=12, pan=0|
        var vib,env,signal;
        vib = SinOsc.kr(4,0,0.003,1);
        env = EnvGen.ar(Env.asr(att,1,0.2,1),gate)*(1.1 + (amp*0.2)) *(vib+(0.001*noisegain*WhiteNoise.ar()));
        signal = DWGFlute.ar(freq, env,endr,jetr,jetRa, gate,release);
        signal = HPF.ar(LPF.ar(signal,6000),200);
        Out.ar(out,Pan2.ar(signal*0.2*amp,0));
    }).add;
    )
(
a =Pmono(
	\help_flute,
	\dur , 0.25 * Prand([1,1,1,1,1,0.2],inf),
	\noisegain , Pseq([Pseq([10], 6),36, 1,1,Pseq([1], 3)],inf),
	\degree, rrand(-10,10)+Pseq([1,5,7+3], inf) + [0,3],
	\amp , Pseq([0.9,0.7,0.5],inf),
	\legato , 1,
	\out,
	Effect({|i| EarlyRef.ar(i,#[0,0,0],#[1,10,18],roomsize:#[6,17,19])=> DWGReverbC1C3.ar(_,c1:1/1,c3:1)/3}).bus.index
)!2=>Ppar(_)=>_.play;
    )


[note:Pwhite(-10,10),out:Effect({|i| EarlyRef.ar(i,#[0,0,0],#[6,7,18],roomsize:#[6,17,19])=> DWGReverbC1C3.ar(_,c1:1/1,c3:0.100)}).bus.index].pp


(
SynthDef(\help_dwgplucked, { |out=0, freq=440, amp=0.5, gate=1, c3=20, jw = 24, pan=0|
	var env = Env.new([1,  0],[ 0.01],[-5]);
	var inp = amp * LFClipNoise.ar(2000) * EnvGen.ar(env,gate);
	var son = MyPlucked.ar(freq, amp, gate,Rand(0.4,0.5),\c1.kr(1),c3,inp,0.1,jw*0.0001);
	son=son.distort;

//	=> MoogFF.ar(_,500,2);
	DetectSilence.ar(son, 0.001, doneAction:2);
	Out.ar(out, Pan2.ar(son * 0.1, pan));
}).add;
    )
Synths(\help_dwgplucked,\freq,[101, 100 ]/3,\jw,10,\c3,100,\c1,5.reciprocal)
(
[note:Pwhite(1,12,inf)-32+2.rrand(32),
c3:100.rand,
c1:9.reciprocal,
legato:Pwrand([1,0.9],[9,1]/10,inf),
out:Pwhite(0,3),
dur:Pwhite(0.01,0.09),].pma(\help_dwgplucked).play
)
