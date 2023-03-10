a= ~synful3.();
(type:\vst_midi,vst:a.controller,chan:0).play
(type:\vst_midi,vst:a.controller,chan:4,amp:1).play
a.shuffle
a.patch(\violins,\mute,0);
a.patch(\violas,\trem,1);
a.patch(\violin,\arco,2);
a.patch(\basses,\arco,3);
a.patch(\basses,\arco,4)
a.controller.gui
(note:5,type:\vst_midi,vst:a.controller).play
(
c=[dur:Pwhite(0.1,1), legato:1, note:Pwhite(-20,12),type:\vst_midi,vst:a.controller,chan:0 ].pp;
c=[dur:Pwhite(0.1,1), legato:1, note:Pwhite(0,12),type:\vst_midi,vst:a.controller,chan:1 ].pp;
c=[dur:Pwhite(0.1,1), legato:1, note:Pwhite(0,12)-15,type:\vst_midi,vst:a.controller,chan:2 ].pp;
b=[dur:0.01,type:\set,exp:Pbrown(10,120,1),func:Pfunc({|e| a.expression(e.exp,0)})].pp;
b=[dur:0.01,type:\set,exp:Pbrown(10,120,1),func:Pfunc({|e| a.expression(e.exp,1)})].pp;
b=[dur:0.01,type:\set,exp:Pbrown(10,120,1),func:Pfunc({|e| a.expression(e.exp,2)})].pp;
a.setOut({o=Bus.audio(s,2)}.value);
d={var in = In.ar(o.index,2);Zita.ar(in[1]*10,in[1]*10,low:6,mid_rt60:5,mix:1)}.play;
)
d.free
a.shuffle
(
v=VoiceLeading.new(
	[
		//[1,1.5,2, 3 , 4],
		[1,  1.5, 2,  \_,  \_,  1,  1.5, 2,       \_],
		[3,  \_,  4,  \_,  \_,  3,  \_,  4,       \_],
		[5,  \_,  6,  \_,  \r,  -5, 6.5, -6,      \_],
		[1,  1.5, 2,  3,   4,   5,  \_,  6,       \_]*(-1)-10,
		[5,  6.5, 6,  \_,  \r,  -5, 6.5, -6,      \_],
	],
	[1,          1,   1,  0.5, 0.5, 1,  1,   1,       1]
).df(\d);
e=VoiceLeading(
	[
		[10, \_,  \_, 110, \_,  \_, \_,  \_,   80, 80] //aaak df!
	],
	v.durs++1=>_.flat
);
TempoClock.tempo_(0.8);
)
5.do{|i| v.at(i)++[type:\vst_midi,vst:a.controller,chan:i,legato:1,amp:0.5] =>_.pp};

w=>Pset(\legato,1,_)=>_.play
(note:0).play
s.reboot

(
{ Saw.ar([0,90]+EnvGen.kr(e.env(0),doneAction:2,timeScale:TempoClock.tempo.reciprocal),0.1)=>FreeVerb.ar(_,0.5,0.8)=>Pan2.ar(_,0) }.play;
5.do{|i| v.at(i)++[type:\vst_midi,vst:a.controller,chan:i,legato:1,amp:0.5] =>_.pp};
)
e.env(0).plot
Env([1,1,2,3],[1,1,1,1],\step).plot
Env([1,2,3],[1,1,1]).plot
v.durs.size


