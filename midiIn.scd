(
	~midi=(
		notes: Array.newClear(128),
		init: {
			MIDIClient.init;
			MIDIIn.connectAll;
		},
		recording: false,
		item: List.new,
		r: {|self| Routine ({|char| loop { self.item = self.item.add([char, Main.elapsedTime-self.time];); char = 0.yield; }})},
		///works to here
		record: {|self|
			self.item=List.new;
			self.time = Main.elapsedTime;
				MIDIdef.noteOn(\record,{|vel num| self.r.([num,vel])});
				MIDIdef.noteOff(\recordd,{|vel num| self.r.([num,vel])});
			},
		ply: {|self| 
			MIDIdef.free(\record);MIDIdef.free(\recordd);
			self.item.do({|pair|
				var vel = pair[0][1];
				var num = pair[0][0];
				SystemClock.sched(
					pair[1],
					{MIDIIn.doNoteOnAction(1,1,num,vel)}
					//vel>0.if ({MIDIIn.doNoteOnAction(1,1,num,vel)},
					//{MIDIIn.doNoteOffAction(1,1,num,0)})
					
				)
			});
		};
	)
)
if
s.boot;
(nil>0);
~midi.item;
(
	MIDIdef.noteOn(\noteon,{|vel num| ~midi.notes[num]= Synth(\default,[\freq,num.midicps+3.0.rand])});
	MIDIdef.noteOff(\noteoff,{|vel num| ~midi.notes[num].free});
	~midi.record;
)
MIDIdenoteOn(\test,{|a b c d| [a,b,c,d].postln});
~midi.ply;
(
	~deltas={
		var times = List.new;
		var deltas= List.new;
		~midi.item.do({|note x| times.add(note[1])});
		times.do{|i x| deltas.add(times.wrapAt(x+1)-times[x])};
		deltas;
	}
)
~deltas.();

~midi.init;
{10.do(~midi.ply;10.wait;)}.fork;
~midi.item[3];
{~midi.item.do({|pair| SystemClock.sched(pair[1],{MIDIIn.doNoteOnAction(1,1,pair[0],64)})});}.fork;

MIDIIn.doNoteOnAction(1,1,60,120);
~midi.r(80);
MIDIdef.noteOn(\noteon,{|vel num| ~midi.notes[num]= Synth(\default,[\freq,num.midicps])});
(
	var item=[];
	~record={
	var start = SystemClock.seconds;
	MIDIdef.noteOn(\record,{|vel num| ~midi.recording.if({item.postln;item=item.add([SystemClock.seconds-start,num])}); })
}
s.boot;

~midi.init;
~rpr.new;
~midi.recording_(true);
a=[];~record.(a);
a=~record.();
a;

a.do()
~midi.recording;
a.size;
a=a.add([9,8]);
Array
s.boot;
)

(///and the body funtions will race 
	Pbind(
		\degree,Pseq([-8,1,2,6,5,6,2,6]),
		\dur,Pseq([1,0.5,0.5,0.375,0.375,0.375,0.375,0.375]),
		\amp,Pwhite(0.1,0.6,inf),
		\tempo,1.18
	).play
)
Pdef

(\type: \note, \degree: Pseq([11,12]) , \dur: 0.5).play

( //step through a sequence with a key
	
	var last=0;
	~deltas=List.new;
	a=Pseq([1,2,6,5,6,2,6,5],inf).asStream;
	w=Window.new(\typer,Rect(0,0,400,400))
	.front;
	w.view.keyDownAction = {
		var delta=SystemClock.seconds-last;
		last=SystemClock.seconds;
		delta.postln; 
		~deltas.add(delta);
		//(\degree:a.next).play;
		//Saw.ar(2**(a.next/12)*400,EnvGen.kr(Env.perc));  }.play
	};

)
~deltas.removeAt(0); ~deltas.postln;
a=List[ 0.243175721, 0.248745953, 0.238238615, 0.25093025800001, 0.243739154, 0.29403621, 0.398641094, 0.34856332299998, 0.35021614800002, 0.36678543400001, 0.32669145, 0.375324401, 0.37907604699998, 0.36874062500002, 0.389345566, 0.721571783, 0.75529736199999, 0.62319431699999 ]
a=a.collect({|i| i.round(0.001)});
a.postln;

List[ 0.37205154500043, 0.40098205399954, 0.4068226950003, 0.47997002800003 ]
a=["and","the","bo-","dy","fun-", "ctions" , "will", "race"];

(
	Pbind(\dur,Pseq(~deltas),\degree,Pseq([1,2,6,5,6,2,6,5])).play
)
s.boot;
~deltas.postln;
SynthDef(\bass,{|freq=440 amp=1| Out.ar(1,Saw.ar(freq,EnvGen.kr(Env.perc(0.1,1.2)))*amp)}).add;
SynthDef(\harp,{|freq=440 amp=1| Out.ar(1,FreeVerb.ar(Blip.ar(freq,16,EnvGen.kr(Env.perc(0.1,2.2))),room:0.9,mix:0.9)*amp)}).add;
( //sequence
	var andThe = [ 0.437, 0.489, 0.322, 0.305, 0.303, 0.322, 0.333, 0.900 ];
	var manyTimes=[ 0.654, 0.254, 0.321, 0.255, 0.318 , 0.508]; //, 0.399, 0.437, 0.463 ]
	var metabolism=[0.372,0.401,0.407,0.44]*(41/37);
	var soWereGoing= [ 0.243, 0.249, 0.238, 0.251, 0.244, 0.294, 0.399, 0.349, 0.35, 0.367, 0.327, 0.375, 0.379, 0.369, 0.389, 0.722, 0.755, 0.623 ];
	Pseq([
		Ppar([
			Pbind(\dur,Pseq(andThe),\degree,Pseq([1,2,6,5,6,2,6,5])),
			Pbind(\instrument, \bass, \dur,Pseq(andThe)+Pwhite(-0.01,0.01,inf),\degree,Pseq([1,2,6,5,6,2,6,5])-14,\amp,0.3)
		]),
		Ptpar([
			0,Pbind(\dur,Pseq([0.884, 0.410,0.474, 0.9]),\midinote,Pseq([\rest, 76, 79, 77]-12) ),
			(0.88+0.4+0.47),Pbind(\dur,Pseq(manyTimes),\midinote,Pseq([\r,67,65,64,67])),
			(0.88+0.4+0.40),Pbind(\instrument, \harp, \midinote,Pseq([62,65,69,72]), \dur, Pwhite(0.05,0.1,4),\amp,0.4),
			0,Pbind(\instrument,\bass,\dur,Pseq([0.410,0.474,0.900, 1]),\midinote,Pseq([61,64,57, 62,])-24)
		]),
		Ppar([
			Pbind(\dur,Pseq(metabolism),\midinote,Pseq([65,64,62,60,59])),
			Pbind(\instrument,\bass,\dur,Pseq(metabolism++0.49)+Pwhite(-0.01,0.01,inf),\midinote,Pseq([65,64,62,60,59])-24)
		]),
		Ppar([
			Pbind(\dur,Pseq(soWereGoing),\note,(Pseq([8,9,11,12,14,16, 14,12,9])-[0,12])),
			Pbind(\instrument,\bass,\dur,Pseq([0.5,1, 1]),\note,Pseq([\r,4-36,9-36 ])) //sum of first five - make function
		])


]).play;

)

p= Pbind(\instrument, \harp, \midinote,Pseq([62,65,69,72]), \dur, Pwhite(0.05,0.1,4),\amp,0.4);
SynthDef(\verb,{|in| Out.ar(0,FreeVerb.ar())})
Pfx(p,verb).play

(note:9).play
~sum={|list to| var sum; to.do({|i| sum=sum+list[i});sum };
~sum

(
	Pseq(
		[
			(note: [5, 7, 8, 9], strum:0.02, dur: 1),
			(note: [5, 9, 11, 13], strum:0.023, dur:1)
		]
	).play
)

(Pbind(\note, Pseq([[5,7,8,9],[5,9,11,13]],inf)) <> (Pbind(\strum, Pseq([0,0.1,0],inf)))).trace.play;

( //Mandolin
SynthDef(\pluck,{|freq| Out.ar(0,Pluck.ar(WhiteNoise.ar(0.1),delaytime:freq.reciprocal,trig:Line.ar(-0.01,1,0.001))) }).add;
SynthDef(\verb, {|out| var in=In.ar(out,2);var sig= FreeVerb.ar(in,room:0.9,mix:0.7,damp:0.1); Out.ar(1,sig)}).add;

	~mando={|array|
		a=Pstep(Pseq(array),Pseq([5,2]));
		Pbind(\insrument, \pluck, \note,a,\dur,Pwhite(0.05,0.1),\strum,0.01 ,\amp,Pseg([0.2,0.5*Pwhite(0.8,1.2,inf),0.01],[5.1,1.9],\exp)) };
		b=(
			Pseq([
				~mando.([[0,3]+Prand([0,2,-6,0],inf),[1,4]]),
				~mando.([[-1,2],[0,3+Prand([0,1],inf)]])
			],inf)
		);
		b=Pbindf(b,\detune,Pwhite(0,1,inf));
		Pfx(b,\verb).play;
)
















