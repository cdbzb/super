(//quartal //		{{{1
	{
		18.do(
			{
				a=(\instrument:\sawSynth,att:9+rand(0.1),rel:8,\midinote:[60,65,70,75]-0,\lagTime:rrand(6,8),\amp:rrand(0.09,0.11)).play;
				rrand(3,5).wait;
				a.set(\freq,([60,65,70,75]-1-rand(0.02)).midicps);
				rrand(4,9).wait;
			}
		)
	}.fork
)

(
(note:1,dur:0.1).play
)

( Freesound.token="a1e39f6de957344efe56bfb034195f33addb0a0d" //		{{{1
)
~snd.name;
FSSound.getSound(31362, {|f|
    ~snd = f;
    ~snd["name"].postln;
});


"/tmp/"++~snd.previewFilename.postln;
~buf.play;

(
	FSSound.textSearch( query: "snare", filter: "type:wav", action:{|p|
		~snd = p[10.rand];~snd.name.postln} );
	)
	(

		~preview=~snd.retrievePreview("/tmp/", {
	        ~buf = Buffer.read(s, "/tmp/" ++ ~snd.previewFilename);
	        "done!".postln;
});

	)
~buf.play;

~snd.getSimilar(action: {|p| ~snd=p[1]});

( //glissandi		{{{1 
	SynthDef(\hall,{|out wet=1 |
		var in=In.ar(out,2);
		var sig = NHHall.ar(in,\time.kr(3));
		XOut.ar(out, wet, sig)}
	).add;
)

(
	~gliss={|length=2 root=( 12.rand ) wet=0.3|
		Pfxb(
			Pbind(*[
				dur:Pseg([0.14/length,0.04,0.1],length!2,\sin),
				degree:Pseries(-20,1,50),
				legato:30,
				root:root,
				pan:1.0.rand.range(-1,1)
			]).pad
			,\hall,\wet,wet).play
		}
	
)
~gliss.(root:14,length:8.1);
(
	{19.do{
		~gliss.(1.9.rand+1.5,wet:rrand(0.3,0.6));
		rrand(2,5).wait;
	}}.fork;
)
(Pbind(\instrument,~gliss,\dur,Pwhite(1,4,inf)).play);
//	rhythm ideas	{{{1
(
	var rhythm=[1,2,1,3,1];
	{
		10.do{|i|
			var base=4.rand+1*100;
			var a=
			{|freq=333 gate=1|
				var sig=Saw.ar(freq,0.1);
				sig=Pan2.ar(sig,rrand(-1,1));
				sig=sig* Env.asr(1,1,1).kr(2,gate:gate);
			}.play;
			Routine.new{
				rhythm.do{|i|
					a.set(\freq,rand(300)+base);
					i.yield;
				};
				a.release
			}.play;
			5.rand.wait;
		}
	}.fork
)

( //	pattern way	{{{2
	SynthDef(\zz,{|freq=333 gate=1|
		var sig=Saw.ar(freq,0.1);
		sig=Pan2.ar(sig,Rand(-1,1));
		sig=sig* Env.asr(1,1,1).kr(2,gate:gate);
		Out.ar(\out.ir(0),sig)
	}).add;

	Pspawn(Pbind(*[
		method:\par,
		pattern:{Pmono(*[ \zz ,
			dur:Pseq(~rhythm),freq:Pwhite(0,300)+(4.rand*100)])},
		delta:Pfin(10,Pfunc({5.rand+1})),
	])).play
)

( //	using Pswitch for drummachine	{{{1
	Pbind(*[
		instrument:Pswitch(
			[\zz,\zz,\snare,\kick,],
			Pseq([3,1,2,1,3,3,2,1],4),
		),
		dur:0.5,
		freq:Pwhite(299,305)
	]).play
)

(//all in verb
	SynthDef(\snareVerb,{|out wet=1 |
		var in=In.ar(out,2)*\bypass.kr(1);
		var sig = NHHall.ar(in,3);
		XOut.ar(out, wet, sig)}
	).add;
	Pfxb(
		Pbind(*[
			instrument:Pswitch(
				[\zz,\zz,\snare,\kick,],
				Pseq([3,1,2,1,3,3,2,1],4),
			),
			dur:0.5,
			freq:Pwhite(299,305),
		]).pad,
		\snareVerb
	).play
)
