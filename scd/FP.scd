Reaper.open
Reaper.new
Reaper.play
Reaper.go(2)
Reaper.stop
Reaper.address
Reaper.h


SCMovieView
\gui.help
(
	var thalassaBus;
	thalassaBus.isNil.if(thalassaBus=Bus.audio);
	{
		var len=1;
		var sig=WhiteNoise.ar();
		var env= Env.linen(0.01,len-0.02,0.01).kr(2,gate:1);
		var fenv= Env.linen(len-0.21,0.18,0.03).kr(2,gate:1);
		sig=RHPF.ar(sig,fenv.range(200,2000),rq:5);
		Pan2.ar(sig*env,Line.kr(0.2,1,len));
	}
	.asSynthDef(name:\door).add;
	//.play
	
		{ |freq=400|
			var sig=Splay.ar ( Saw.ar( (10.0!4).rand+freq-5,0.2) );
			var env= Env.perc(0.2,6!4.rand).kr(2,gate:1);
			sig=sig.distort*env;
			sig=sig+CombN.ar(sig,1,0.3,3);
			sig=sig/1.5+Phaser2.ar(sig,rate:0.2	);
			Out.ar(thalassaBus.index,sig)
		}
		.asSynthDef(name:\sawTw).add;
	//.play;
		{|in| var sig= In.ar(in,2);
		sig=PlateReverb.ar(sig,mix:0.8);
		Out.ar(0,sig);
		DetectSilence.ar(sig,doneAction:2)
	}.asSynthDef(name:\verbb).add;

	Synth(\verbb,[in:thalassaBus.index]);

	{
		Reaper.go(38*60+2.81);//kirk face
		2.wait;
		Synth(\door);
		0.8.wait;
		(instrument:\sawTw,degree:[4-7,6-7,8-7,10-7,4,6,8,10]-1,strum:0.1,octave:[5],sustain:4).play;
		0.3.wait;
	//Reaper.go(38*60+3.11)//enter Thalassa
	Reaper.go(37*60+54.30)//door open
	}.fork
)

///////markers
	Reaper.go(38*60+2.81) //waiting


	Reaper.go(38*60+8.58)//Sargon what's wrong??
	Reaper.go(37*60+54.30)//door open
