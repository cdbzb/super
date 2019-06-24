(
	Window.closeAll;
	w=Window(\gui,Rect(0,300,500,120))
	.front
	.alwaysOnTop_(true);

	~slider = Slider2D.new(w,Rect(0,0,120,120));
	~slider.background_(Color(0.2,0.2,0.05));
	
)

(
~slider.action = {
 var cf = ~slider.x.value.linexp(0,1,100,4000);
 var freq=~slider.y.value.linexp(0,1,100,2000);
 x.set(\cf,cf);
 x.set(\freq,freq);
};
)

(
	SynthDef(\gui,{ |freq=440 cf=600 |
		var sig =Blip.ar(freq.lag(0.2),50,0.2!2); 
		sig=BPF.ar(sig,cf.lag(0.1));
		sig=FreeVerb.ar(sig);
		Out.ar(0,sig);
	}).add
)

x=Synth.new(\gui);
(
	~button = Button.new(w, Rect(150,60,30,30))
	.states_([
		[\OFF , Color.black , Color.grey(0.8)],
		[\ON  , Color.black, Color(0.2,0.75,0.9)]
	])
	.action_({ |obj|
		if( obj.value == 1,{x=Synth.new(\gui)},{x.free})
	})
)

s;
s.reboot;
