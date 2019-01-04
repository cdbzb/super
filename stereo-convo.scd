//todo make Prep do stereo or mono and return an array

~bufarray=Library.at(\functions,\prepStereo).("/Users/michael/tank/IR/Saane/Church_Schellingwoude/Schellingwoude_m-st.wav"); 

(
	{
		var sig = Pan2.ar(Blip.ar(LFNoise2.ar(0.3,200,200),8,0.1),SinOsc.ar(3.31));
		var mono = Mix.new(sig);
		var wet =PartConv.ar(mono,4096,~bufarray);
		Out.ar(0,wet+sig*0.5)
	}.play
)

s.meter;
