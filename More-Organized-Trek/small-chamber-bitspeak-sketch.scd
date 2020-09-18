"/Users/michael/tank/super/More-Organized-Trek/Songs/small-chamber.scd".load;
(
SynthDef(\vocalFry ,{
		Impulse.ar(\freq.kr(200,\freqLag.kr(0.5)))
		* \amp.kr(0.1)
		* Env.asr(0.1,1,0.1).kr(2,gate:\gate.kr(1))
		=> Out.ar(\out.kr(0),_)	
}).add;
)
(
		//:call scnvim#sclang#send("Song.current.cursor_(13)")
		Song.play;
		~carrier.isNil.if{~carrier=Bus.audio};
		Song.currentSong.pbind[13]=>Pbindf(_,\legato,1,\instrument,\vocalFry,\out,~carrier.index)
		=>Pmul(\freq,[1/4, 1/2 ],_)
		=>_.play;
		{
				Vocoder.ar(
						In.ar( ~carrier.index ),
						Item(\eyeWillReturn).playbuf*2,
						10,
						q: 0.2

				)
//				*1/4
		}.play;
		Item(\eyeWillReturn).play(out:1,amp:0.05)
)
