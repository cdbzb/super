(//quartal
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

(
	Freesound.token="a1e39f6de957344efe56bfb034195f33addb0a0d"
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

