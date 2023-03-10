SynthDef(\recc,{|buf bus=0|DiskOut.ar(buf,In.ar(bus))}).add;
SynthDef(\trans,{var sig=Impulse.ar(2);Out.ar(0,sig)}).add;

(  //this works ....
	a = ( 
		start:2,
		music:{
			var b=Buffer.alloc(s,2**16);
			var name=\tt;
			b.write("/tmp/"++name++".wav","WAV","int24",0,0,true);
			b.bufnum.postln;
			{
				Routine.run({
					Synth.tail(nil,\recc,[\buf,b,\bus,0]);
					4.wait;
					b.bufnum.postln;
					b.close })
				}
			}
		)
)

(  //so now make into a function that takes a name...
	var rec = {|name in=0| //returns a func
		{
			var b=Buffer.alloc(s,2**16);
			b.write("/tmp/"++name++".wav","WAV","int24",0,0,true);
			b.bufnum.postln;
			{
				Routine.run({
					Synth.tail(nil,\recc,[\buf,b,\bus,in]);
					4.wait;
					b.bufnum.postln;
					b.close })
				}
			}
		};
			a = ( 
				start:2,
				music:rec.(\fun,0) 
			)
)
(  //finally move to ~funs!!! or....
)

(
	SystemClock.sched(3.1,a.music.awake);
	SystemClock.sched(3.1,{Synth(\sin)});
	SystemClock.sched(3.1,{Synth(\trans)});
)
	
	a.b
	a.music.awake
	a=Task({1.postln;{2.postln}})
	a.play.awake
	a.awake
	Clock
	Task
	SystemClock.sched(2,{1.postln;{2.postln}.play})
	a={2.postln;{1.postln}.play} 
	a.sched(SystemClock,2)
	SystemClock.sched(3,a.play)











{PinkNoise.ar(0.1)}.play
a=~rec.(\tarshme2)
a.close

~prep.()
a=(start:3,parent:~funs,music:(note:0),type:\rec)
a.lag
Event.addEventType(\rec,{},(lag:-0.2))

(type:\item,name:\ttt)++(rec:false)

(
	d=SystemClock.seconds;
	SystemClock.schedAbs(d+0.5, 
		{RecordBuf.ar(In.ar(0),c,loop:0,run:1)}.value
	);
	SystemClock.schedAbs(d+0.5, {Synth(\trans)} );
)

( ///works
	a=();
	a.parts=();
	a.p={|f|f.parts.do{
		|i|TempoClock.sched(2,{i.music.play})}};
	a.parts.c=(music: {'prepping'.postln;{{Impulse.ar(2)}}}.value);
	//a.parts.d=(music: x={'prepping'.postln;{{Impulse.ar(2)*(-0.5)}}}.value);
	//a.parts.p
	//a.parts.c.music;
	a.p
)
{Impulse.ar(2)}.play
(
	t=Task({1.postln;nil.yield;2.postln})
	r=Routine({1.postln;nil.yield;2.postln})
	r.play
	t.play
	

	//~rec
	//a.music=Prout({1.postln});
	a.p;
	//a.parts.c.music
	//SystemClock.sched(1,{a.music.play})
)
