
(
	{
		SplayAz.ar(8,
			[
				PlayBuf.ar(1,~marketPhrases[0].bufnum),
				PlayBuf.ar(~marketPhrases[1].numChannels,~marketPhrases[1]),
				PlayBuf.ar(~marketPhrases[2].numChannels,~marketPhrases[2]),
			],
			width:0.05,center:1
		)
	//}.plot;
	}.play(s,~speakers[0])
)


(
	{
		SplayAz.ar(  8,
			[
				PlayBuf.ar(1,~marketPhrases[1]),
				PlayBuf.ar(1,~marketPhrases[2]),
				PlayBuf.ar(1,~marketPhrases[0])
			],
		spread:0.05,center:0.875	
		)
	}.play(s,~speakers);
	
)
{PinkNoise.ar(0.05)}.play(s,~speakers[0]);
