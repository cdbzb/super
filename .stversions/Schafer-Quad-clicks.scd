( // ULN Server options
o=Server.local.options;
o.numOutputBusChannels=14;
o.numInputBusChannels=12;
o.device="ULN2 [570]";
//o.outputStreamsEnabled="0000000000111111";
 o.outputStreamsEnabled="1111111111111111";
//o.inputStreamsEnabled="11111111111111";
o.inputStreamsEnabled="00000000000000";
s.reboot;
)

(// Quad click demo for David 
	{Out.ar([10,11],Impulse.ar([8,8.1])*0.08)}.play;
	{Out.ar([0,1],Impulse.ar([8.05,8.03])*0.2)}.play;
)

(//Map b to stereo (hard pan)	3 4
//				2 5
//				1 6
//				0 7
	b=Bus.audio(s,8);
	{
		var left = Mix.new(b.ar(4));
		var right= Mix.new(b.ar(4,4));
		Out.ar(0,left);
		Out.ar(1,right); 
~size= a.size;
	}.play;
)

( //shuffle chord
	~notes=[450,501,602,703,804,905,906,907];
	~chord.free;
	~notes=~notes.scramble;
	~chord= {Out.ar(b,SinOsc.ar(~notes,0,0.1))}.play;
)

( //stereo ticks
	~tick= { var left = Impulse.ar(8.05);
	var right = Impulse.ar(8.03);
	Out.ar(b.index  ,right);
	Out.ar(b.index+4,left); 
	}.play
)
~tick.free;
b.index;

a=SoundFile.collectIntoBuffers("/Users/michael/tank/SchaferHouse/SOUND/DOORS OPENING AND CLOSING/*");
{Out.ar( b.index+rand(8), PlayBuf.ar(2,a.choose)) }.play;

b.scope;
s.meter;
s.reboot;
