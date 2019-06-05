// OR BETTER -> just send OSC to drive the picture !?!

~rpr=NetAddr("192.168.1.130",8000);
~rpr.sendMsg("/play");
~rpr.sendMsg("/stop");
~rpr.sendMsg('/marker',1);
~rpr.sendMsg('/time',2);

~tone={SinOsc.ar(350+Rand(200),0,EnvGen.kr(Env.perc))};
~tone.play;
(
	var startTime=9;
	t=TempoClock.new;
	t.permanent=true;
	~rpr.sendMsg("/time",startTime);
	~rpr.sendMsg("/play");
	t.beats=startTime;
	t.schedAbs(13,{~tone.play});
	t.beats;
)

(
	t.schedAbs(13,{~tone.play});
	t.beats;
)


(
	~timeline=();
	~timeline.putPairs([13,{~tone.play},15,{~tone.play}]);
)

(
	var start = 10;
	t.beats = start;
	~rpr.sendMsg("/time",start);
	~rpr.sendMsg("/play");
	~timeline.keys.do{|item| (item>start).if(
		{t.schedAbs(item,~timeline[item])}
	)};
)
(
	~timeline2=[
	13,{
	~tone.play
	},15,{
	{Saw.ar(200,0.05*EnvGen.kr(Env.perc))}.play;
}
	]
)



	a=(time:3,play:{{SinOsc.ar(400,0,0.1)}.play}).play;
(
	t.beats=0;
	t.schedAbs(a[\time],{a.play});
)

