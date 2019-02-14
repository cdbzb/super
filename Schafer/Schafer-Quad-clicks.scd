( // ULN Server options
o=Server.local.options;
o.numOutputBusChannels=14;
o.numInputBusChannels=12;
o.device="ULN2 [570]";
 o.outputStreamsEnabled="1111111111111111";
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
		Out.ar(0,[left,right]);
	}.play;
)

(//map b to quad 1 3 5 7
 //              2 4 6 8
	 b=Bus.audio(s,8);
 {
	 var pairs = Array.fill(4,{arg i; Mix.new(b.ar(2,i*2)) });
	 pairs.postln;
	 Out.ar(0,[pairs[0],pairs[1]]);
	 Out.ar(10,[pairs[2],pairs[3]];
 }.play
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

//////aaaaaarg!!
a=SoundFile.collectIntoBuffers("/Users/michael/tank/SchaferHouse/SOUND/DOORS OPENING AND CLOSING/*");
~names=a.collect({|item index| PathName.new(item.path).fileName});
{Out.ar( b.index+rand(8), PlayBuf.ar(2,a.choose)) }.play;

//how to do convo
//~ir = =Library.at(\functions,\prepStereo).("ir"); 
//PartConv.ar(input,4096,~ir);

