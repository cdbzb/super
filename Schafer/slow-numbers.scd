
(
	~playNumbers={Routine.new({
		       8.do { |x|
			{PlayBuf.ar(1,~numberBuffers[x], rate:0.46 )}.play(s,~speakers[x]);
			(~numberBuffers[x].numFrames/44000).wait;
			4.wait;
			        };
		}).play
	};
)

~numberBuffers.()	;
~makeNumberBuffers.();
~moveNumberBuffersToRemote.();

(
	{
		s.prepareForRecord("/Users/michael/tank/SchaferHouse/SOUND/slower-numbers.aif",numChannels:8);
		s.sync;
		s.record(bus:~speakers[0],duration:45);
		~playNumbers.();
	}.fork;
)
