
~upstairs=Library.at(\functions,\prep).("/Users/michael/tank/IR/Saane/Domestic/Upstairs_1_floor.wav",\upstairs);

(
	{
		var in=Impulse.ar(4);
		in = PartConv.ar(in,4096,105);
		Out.ar([0,1],in);
	}.play
)

a;
Buffer(0);

Library.at(\upstairs);

