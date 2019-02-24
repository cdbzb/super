(
~names={|collection| collection.collect({|item index| PathName.new(item.path).fileName}) };

~randomPair={
	var speakers=Array.newFrom(~speakers);
	[speakers.remove(speakers.choose),speakers.choose];
};


~outM={|outArray inArray| outArray.do({|item index| Out.ar(item,inArray[index])})};//Out.ar for non-contig spkrs

~downmix={Out.ar(0,[Mix.ar(In.ar([10,11,12,13])),Mix.ar(In.ar([14,15,16,17])) ])};//mix to laptop

~laptop=CmdPeriod.add({{~downmix.()}.defer(0.03)});//set Cmd-. to restore mix to laptop

~local={ s=Server.local; Server.default=s; };

~remote={ s=Server.remote; Server.default=s; };
);

( //Circular echo = round the circle - order must be backwrds
	{Out.ar(17,DelayN.ar(In.ar(16)*0.5),1,0.5)}.play;
	{Out.ar(16,DelayN.ar(In.ar(15)*0.5),1,0.5)}.play;
	{Out.ar(15,DelayN.ar(In.ar(14)*0.5),1,0.5)}.play;
	{Out.ar(14,DelayN.ar(In.ar(13)*0.5),1,0.5)}.play;
	{Out.ar(13,DelayN.ar(In.ar(12)*0.5),1,0.5)}.play;
	{Out.ar(12,DelayN.ar(In.ar(11)*0.5),1,0.5)}.play;
	{Out.ar(11,DelayN.ar(In.ar(10)*0.5),1,0.5)}.play;
	{Out.ar(10,DelayN.ar(InFeedback.ar(17)*0.5),1,0.5)}.play;
);/////

(
	SynthDef(\pingpong8,{ |fb=0.75 delay=0.5|
		var in = Array.series(17,11);
		var delayline = {|in| DelayN.ar(in*fb,delay)};
		in.do({|i| Out.ar(i,delayline.(InFeedback.ar(i-1)))});
		Out.ar(10,delayline.(InFeedback.ar(17)));
	}).add

);
