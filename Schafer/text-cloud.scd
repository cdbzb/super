
(
	{       var line=Line.kr(3,0.2,10);
	80.do({
		{PlayBuf.ar(1,~texts.choose,rate:([0.9,1,1.11].choose*(rrand(0.99,1.01))) ,doneAction:2) *[0.5,0.5,0.1].choose}.play(s,~speakers.choose);

		a.wait; //use a line for the lower bound
	})}.fork;
)
l;


~line=NodeProxy.control(s,1);
 ~line.source={LFNoise2.kr(1)};
~line.monitor;
~dust=NodeProxy.audio(s,1);
~dust.source={Dust.ar(line,add:)}
Select
{ SinOsc.ar(110).linrand }.plot;


(
	SynthDef (\text ,{ 
		var rate=Select.kr(Rand(0,3),[0.9,1,1.11])*Rand(0.99,1.01);
		var vol=Select.kr(Rand(0,4),[0.5,0.5,0.1]);
		var spk=Select.kr(Rand(0,8),~speakers);
		var numtexts=~texts.size;
		var texts=~texts.collect({|item| PlayBuf.ar(item.numChannels,item,rate:rate,doneAction:2)});
		var text=Select.ar(Rand(0,numtexts-1),texts);
		rate.postln;
		Out.ar(spk,text*vol);
	}).add

)

Synth(\text);
~speakers=1!8;

(//add curves
	~levels=Pseq([2,0.05,0.05,2],inf);
	~levelsTop=Pseg(Pseq([4,0.15,0.1,6],inf),35);
	~segment=Pseg(~levels,25);
 a=Pbind.new(\instrument,\text,
	 //\dur,1;
	 \dur,Pexprand(~segment,~levelsTop,inf);
	 //\dur,Pexprand( 0,3,inf);
	).play;
)

s.reboot;
s;

