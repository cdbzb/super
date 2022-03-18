a = "~/tank/super/waveforms/AKWF/AKWF-1024/AKWF_oboe/*".pathMatch.collect(SoundFile.openRead(_))
a = "~/tank/super/waveforms/AKWF/AKWF-1024/AKWF_cello/*".pathMatch.collect(SoundFile.openRead(_))
a = "~/tank/super/waveforms/AKWF/AKWF-1024/AKWF_bw_saw/*".pathMatch.collect(SoundFile.openRead(_))

(
b = a.size.collect({ FloatArray.newClear(a[0].numFrames) }) ;

a.size.do({ |i x| a[i].readData( b[i]);b[i].postln });

//a.readData(b);

c = b.collect({|i| i.as(Signal)});
d = c.collect({|i| i.asWavetable});
e = d.collect{|i|Buffer.loadCollection(s, i)};

)
(
//layer this
{ VOsc.ar(
	SinOsc.kr(1/6*1.rrand(1.01))
	.range(e[4].bufnum,e[13].bufnum-1,
	{pi.rand}!4),
	[500, 300,150,900 ]*[1,2,3,4,5].choose/2 
	//add for modulation
	+ LFNoise1.kr(1,mul:3)
	,
	0,0.01) =>Splay.ar(_) }.play
)

//use Sin waveforms!
{ VOsc.ar(e.choose.bufnum+SinOsc.kr(5.0.rand,mul:3),-12.rrand(21).df(\e,tuning:\pythagorean)+SinOsc.kr(3.0.rand),0,0.07) * Env.triangle(7).kr(2,gate:1) * [[0,1],[1, 1 ],[1,0]].choose }.play

e.do(_.postln)
a.do({|i| i.path.postln })
SoundFil

