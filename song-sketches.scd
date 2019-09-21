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
