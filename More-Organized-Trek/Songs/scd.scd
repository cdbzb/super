(

	{ |rate=4 lag=4|
		{
			SinOsc.ar(freq:LFBrownNoise2.kr(3).range(4,rate), phase:0.0, mul:2.0, add:0.0).floor
			=> Select.ar(_, [\lower.ar(7.df,lag ), \upper.ar(11.df, lag)])
			=> Pulse.ar(_, 0.4)
			* 0.05
		}
	}.valueArray([9,12]).play
	=> {|i| fork{2.wait; i.set(\lower,6.df)}}

)
a.source_({})
Pdefn(\ttt).play(quant:0)
""nd(%:p)
"a"
"ap"
/private/tmp/scd.scd
(
"/Users/michael/tank/super/More-Organized-Trek/Songs/chamber1.scd".load;
Song.currentSong.getStartString(2)
3
start: start: start: start: :
start: 

)
~myFree
Song.currentSong.getStartString
Pdefn(\ttt).quant(0)
start



a = {1+1} <>  {|i| i-1}
{SinOsc.ar(freq:99, phase:0.0, mul:1.01, add:0.0).excess(0.1)}.play
a.()
// compose a function that will return an array of random length
a = { |n| { 16.rand } ! n } <> { rrand(4, 8) };
a.value;
a = 10.rand.dup(_) <> 7
7 => 10.rand.dup(_)
// compose a function from a that selects only odd values
b = {|x| x+1} <> a;
b.(1)
b.value;
[1,2,3] select: (_>2)
5.collect{20.rand}.select((_.odd))
Object
"%r%".format(9)
(
{
	PinkNoise.ar(0.1) 
	=> Pluck.ar(_, trig:Impulse.kr(2),maxdelaytime:0.2, delaytime: \freq.kr(300).reciprocal * [1.5,1] * 2, decaytime:3.0, coef:-0.1, mul:1.0, add:0.0) 
	=> Mix.ar(_)
	=> CrossoverDistortion.ar(_, amp:0.3, smooth:0.5, mul:1.0, add:0) 
}.play
)
Song.durs[\measured].list
.last
~guitar

~qq !? (_+2)
~qq + 2
~qq=99
~qq !? (_+3) ?? ( _.postln )
~qq=nil
Song.guitar
a ?? (_=0)
a = a ? 9
a
b = b ? 9
~qoin !? { \p.postln }
w
Piano
a=PF()
a.controller
(type:\vst_midi,midiOut:a.controller, midinote:61).play
VSTPluginController 
VSTPlugin
(type:\strum,instance:a,switch:\up,midinote:20).play
(type:\vst_midi,controller:a,freq:[200 ]).play
a=Synful()
a.setPlayMode(\strum)
a.setPlayMode(\pick)
a.syn.isRunning
AAS_Strum.dump
[freq:330].p +=  [dur:0.8,freq:777].p => _.play
(type:\strum,instance:a,dur:2,switch:\down).play
(type:\strum,instance:a,midinote:[3,5,9]+58,dur:2).play
(type:\strum,switch:\up,instance:a,dur:20).play
().play

Guitar
'!?'.help
a=AAS_Strum.new;
a
(
a.setPlayMode(\strum);
[type:\strum,instance:a, switch:[\d,\u,\d,\u,\f,\fu,\f,\fu].q, lag:0.05, dur:1/8].p
+= [type:\strum,instance:a,midinote:[[1,5,11,13],[1,4,6,14,16,21]].df(\e,octave:4).q].p
=> _.play
)
