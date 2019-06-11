
	~ambience=NodeProxy.audio(s,2);
	~waves_3m;
	~ambience.source={|vol=0.5| PlayBuf.ar(2,~waves_3m,loop:1)*vol};
	~ambience[1]=\filterIn -> {|in| var sig=MembraneHexagon.ar(in,0.008,0.999)*0.70;HPF.ar(sig,300)};
	~ambience.set(\wet1,1);
	~ambience.set(\wet1,0);
	~lf=NodeProxy.control(s,1);
	//~lf.source={ SinOsc.kr(0.005,0,1) };
	~tighten={~lf.source={|dur=100| EnvGen.kr(Env.triangle(dur),gate:1,levelScale:0.9,levelBias:0.1)}};
	//~lf.set(\gate,0);
	//~lf.set(\gate,1,\dur,50);
	//OR//
	//~lf.source={ SinOsc.kr(0.005,0,1,mul:0.8,add:0.2) };
	~ambience.set(\wet1,~lf);
	//~lf.set(\gate,1,\dur,100);
	//~ambience.fadeTime_(30);
	//~ambience.lag(\wet1,30);
	//~ambience.play(vol:1,fadeTime:1);
