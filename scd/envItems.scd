
(
t=Item('5-9-envtest');
t.refresh;
u=Item('5-9-envtest2');
u.refresh;
v=Item('5-9-envtest3');

//v.arm(length:8)
//v.record
v.refresh;
//u.arm(length:4);
//u.record
{
	MegaBind(
		[
			[1,  3,  5, 4,  3, 4,  2,  3],
			[-1, \_, 2, \_, 6, \_, -5, \_]
		].df(\c),
		6!10 => _.gaussian(dev:0.01),
		[
			pan:[1,-1],
			env: [t.buffer.bufnum,u.buffer.bufnum],
			amp: [1,5],
			vibrato: [ { PlayBuf.ar(1,v.buffer.bufnum, rate:BufRateScale.kr(v.buffer.bufnum)) => Amplitude.ar(_) *200 },0 ]
			//vibrato: [1,1]

		],
		{|i|
			SinOsc.ar( 
			i.freqSeq + 
			i.vibrato )
			* Env.asr().kr(0,gate: i.gateSeq)
			=> Pan2.ar(_, i.pan)
			* (
				PlayBuf.ar(1,i.env, rate: BufRateScale.kr(i.env)* BufDur.kr(i.env)/i.dur.sum)=>Amplitude.ar(_) ** 2 *2
			)
				* i.amp
			},
			{|i|
				Mix.ar(i)
				=> SineShaper.ar(_,limit:0.2)
				//=> Phaser2.ar(_)
				=> FreeVerb.ar(_,0.3,1)
			},
			release:15
		).play
	}.()//.sched([0,4, 8, 12, 16])
)


(
b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav"); // remember to free the buffer later.

SynthDef(\help_PlayBuf, {| out = 0, bufnum = 0 |
    Out.ar(out,
        PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum).poll, doneAction: Done.freeSelf)
    )
}).play(s, [\out, 0, \bufnum, b]);
)
