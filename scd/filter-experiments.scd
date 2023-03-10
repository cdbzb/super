r


OnePole.ar()
{OnePole.ar(PinkNoise.ar,-0.8)}.play
OnePole.scopeResponse(coef: 0.1)
OnePole.scopeResponse([0.1],[-0.1])
NLFiltC
Ugen 
Filter
Ndef(\aa)
Ndef(\)
TwoPole.ar()
(//stereo folly
	{ var sig=WhiteNoise.ar(0.1);
	var radius= SinOsc.kr([0.11,0.31]).range(0.2,0.99);
	var angle=LFSaw.kr([0.121,0.127],0,7000,100	).range(0,0.99);
	TwoPole.ar(sig,angle,radius);
}.play;

)
HPF.scopeResponse
Ndef(\aa)[1]=\filter->{|in|OneZero.ar(in,-0.5)}
OneZero.ar
Ndef(\aa,{PinkNoise.ar(0.05)}).play;
(
	t=TempoClock.new.tempo_(3);
	r={Routine({
		var notes=[1,3,5,9]+17.rand;
		9.do{
			notes.do
			{|i x|
				var a=Array.newClear(4);
				a[x]=Synth(\default,[\freq,(i+60).midicps]);
				{rrand(0.3,1.0).wait;a[x].release}.fork;
				1.0.rand.wait;
			}
		}
	}).play(t)};
	{
		4.do{
			r.value;
			rrand(2.0,8.0).wait;
		}
	}.fork
)

ProxySpace.all
(
	p=ProxySpace.new;
	p.fadeTime=2;
	p[\white]={WhiteNoise.ar(0.1)};
	p[\pink]={PinkNoise.ar(0.3)};
)

p
p[\test].
(
{
	10.do{
		p.do{|i x|i.play(2.rand,fadeTime:2.rand)};
		5.rand.wait;
	};
	p.stop(fadeTime:9);
}.fork
)
(
	p=ProxySpace.new.push;
	~a={BrownNoise.ar(0.1!2)};
	~a.play([0,1]);
	~a[1]=\filter->{|in|PlateReverb.ar(in)*3};
	p.pop;
	//{4.wait;~a.stop(9)}.fork;p.pop
)
p.pop
(
	p=ProxySpace.new.push;
	p.pop
	p[\g]={VSTPlugin.ar(nil,2)};
	~c=VSTPluginController(p[\g].synth)
	p[\q]
)

(//nice wibble
	//~l={LFNoise2.kr(0.1,300,300)};
	~wibble=ProxySpace.new.push;
	~l={LFBrownNoise2.kr(0.1,2,0,300,300)};
	~o=[\freq:~l,dur:Pbrown(0.05,3),amp:0.8].p;
	~o[1]=\filter->{|in|CombC.ar(in,1.5,~l.abs/600+0.5,9).distort};
	~o[2]=\filter->{|i|PlateReverb.ar(Clip.ar(i,-0.2,0.25),mix:0.1)};
	
)
(
	//copypaste
	~m={LFBrownNoise2.kr(0.1,2,0,200,100)};
	~q=[\freq:~m,dur:Pbrown(0.05,3),amp:0.8].p;
	~q[1]=\filter->{|in|CombC.ar(in,1.5,~l.abs/600+0.5,9).distort};
	~q[2]=\filter->{|i|PlateReverb.ar(Clip.ar(i,-0.2,0.25),mix:0.1)};
	~q.play(1)
)
p.push
p.pop
q=No
currentEnvironment
~a=\default
~a.play
~a.send([\freq,349])
~a.clear(2)
Quarks.installed.do(_.postln)
Quarks.classesInPackage('wslib').do(_.postln);
BinauralDistance
KeyboardWindow
Note
Executor
ActionFunc
E
CoverMe
LessKeys
ProxySubmix
ProxyChain

Halo
BroadcastServer
EnvirDispatch
MasterFX

~o={PinkNoise.ar(0.1)}
~o.play
~a.gate=0

~a.release
~a={PinkNoise.ar(0.1)}
