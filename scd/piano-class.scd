	a=Piano.new;
	s.reboot;
(
	p=[type:\midi,midiout:a.controller.midi,midinote:Pwhite(30,70,inf),dur:Pwhite(0.1,1.2,inf)].p.play;
	//(type:set,id:a.synth.id,4)
	{ inf.do {a.controller.set(80.rand,1.0.rand);1.0.wait} }.fork
	//TODO post the settings - also keep a running array for grabbing
	//also TODO make a synthdef with the params exposed??
)
	b=Piano.new; //why do I get not ready!!
(
	[type:\midi,midiout:b.controller.midi,midinote:Pwhite(30,70,inf)].p.play;
	//(type:set,id:a.synth.id,4)
	{inf.do {b.controller.set(180.rand,1.0.rand);1.0.wait} }.fork
)

//params
a=Piano.new
a.controller.info.parameters.do{|i|i.name.postln}


( //	mapping controllers	{{{2
	~ctl=Bus.control;
	~ctl2=Bus.control;
	{Out.kr(~ctl,LFBrownNoise0.kr(1))}.play;
	{Out.kr(~ctl2,LFBrownNoise0.kr(5))}.play;
	a.controller.map('Strike Point',~ctl)
	a.controller.map('Sustain Pedal',~ctl2)
)

Pchain

( //Nice
	Event.addEventType(\vset,{~controller.set( ~param,~value )});
	a=Piano.new;
	p=[type:\midi,midiout:a.controller.midi,degree:Pwhite(0,22,inf),octave:4,root:Pbrown(0,12,0.2),dur:Pwhite(0.1,1.2,inf)].p.play;
	//[type:\set,id: [a.controller.synth.nodeID] ,'Sustain Pedal':Pwhite(1,1,inf)].p.play;
	[type:\vset,controller:a.controller,param:'Sustain Pedal',value:Pbrown()].p.play;
	[type:\vset,controller:a.controller,param:'Strike Point',value:Pbrown()].p.play;
	[type:\vset,controller:a.controller,param:'Blooming Energy',value:Pbrown()].p.play;
	[type:\vset,controller:a.controller,param:'Quadratic Effec',value:Pbrown()].p.play;
	[type:\vset,controller:a.controller,param:'String Length',value:Pbrown()].p.play;
	[type:\vset,controller:a.controller,param:'Sympa',value:Pbrown()].p.play;
)

Event.addEventType(\vset,{~controller.set( ~param,~value )});

(//how to access stupid environment
	~play={i=currentEnvironment; all {:x,x<-i.keys,i.at(x).class!=Function,::x.postln}; };
	e=(a:1,b:3,d:{|self|(self.a+self.b).postln},play:~play,parent:());
	e.play;
)

a=Piano.new;
(
	~play={i=currentEnvironment; 
		all {:x,x<-i.keys,
			i.controller.info.parameters.collect{|i|i.name.asSymbol}.asList.includes(x),
			::i.controller.set(x,i.at(x))
		};
		(type:\midi,midiout:i.controller.midi,midinote:i.midinote,note:i.note,degree:i.degree,amp:i.amp).play	};
	e=('Sustain Pedal':1,play:~play,controller:a.controller,midinote:39);
	Event.addEventType(\vv,~play,(parent:()));
	e.play
)
a.controller.info.parameters.collect{|i|i.name.postln}
a=Piano.new;
a.bus.scope
b=[midinote:Pwhite(25,90),'Q Factor',Pwhite(),'Impedance',Pwhite(),'Duplex',Pwhite(),controller:a.controller,type:\vv].p.trace.play;
a.node[1]=\filter->{|in| Phaser2.ar(in,fb:0.9)};
a.node.stop
a.node;
a.node.source={Saw.ar(400,0.05)};
a.node.isPlaying
b.free;
(
	SynthDef.new(\harp, { |gate=1 out=0 freq=400|
		var in=PinkNoise.ar(1);
		var sig=Pluck.ar(in: in,  gate: gate,  maxdelaytime: 0.02,  delaytime: 1/freq,  decaytime: 10,  coef: 0.5,  mul: 1,  add: 0);
		Out.ar( out,TwoTube.ar(sig*0.1,loss:0.9,d1length:1000,d2length:1111));
	},  rates: nil,  prependArgs: nil,  variants: nil,  metadata: nil).add;
	[instrument:\harp,strum:0.03,freq:Ptuple(Pwhite(60,2000,inf)!5),dur:2].p.play
)
[\instrument:\sawSynth,att:1,rel:5,dur:Pwhite(2,6),freq:Pexprand(100,2000,inf),amp:0.03].p.play;
(
	[note:Pwhite(-13,26),
	amp:0.05,
	'Sympa',Pbrown(),
	'Sustain Pedal',Pbrown(),
	'Q Factor',Pbrown(),
	'Cutoff',Pbrown(),
	'Impedance',Pbrown(),
	'Mute Pedal',Pbrown(),
	amp:Pgauss(0.3,0.05),
	'String Length',Pbrown(),
	'Unison Width':Pwhite(),
	'Quadratic Effec',Pwhite(),'Strike Point',Pwhite(),type:\vv,controller:a.controller,dur:Pexprand(0.1,1.8,inf)].p.trace.play
)

e.keys.do{|i|i.postln;e.at(i).postln}
e.at('Sustain Pedal')
e.do{|i| i.post}
//GOOD

Event
a.controller.synth
s.plotTree

b=(dur:20).play
b.id
b[\id]
a.controller.synth.nodeID
a.controller
a.synth
Event
Node
Synth
,
VSTPluginController
Prout
// 1,3,5,6,P8 7 6 *

//PUT THIS IN THE CLASS!!!
(event type
	midiEndPont: controller.midi
	note: {|self noteNum| (type:\midi,midiout:midiEndPont,note:noteNum)
	set: {|self param-name value }
 )

VSTPlugin
a=Piano.new;
a.controller.info
(
	SynthDef(\vsti2,{|out=0 sustain=0 info|
		var sig = VSTPlugin.ar(nil,numOut:2,params:[1,sustain]);
		Out.ar(out,sig)
	})
)


// HERE		{{{1
// Make an event that will either send a midi note AND/OR set a parameter...How??
//(midinote:3,'Sustain Pedal',1)
//=> a=[(\type,\midi,midinote:3),(type:\set,'Sustain Pedal',1)]
//=> PPar(a);
// Question: are there patterns that "deinterlace" ??

Event.addEventType(\piano,
	{| 
		(type:\midi,midinote:event.midinote,midiout:xxxxx).play
		(type:\set, id:...)
	});
(type:\e, note:2).play

//PSEUDO-CODE
Pbind(*[
	type:\piano,
	midinote:50,
	'Sustain Pedal':1
]).play
a=Piano.new
a.controller;
[type:\midi,midiout:a.controller.midi,note:Pwhite(0,12,6)].p.play
a.node.isPlaying

//	looking at help {{{1
VSTPlugin.search;
VSTPluginController(VSTPlugin)
(
	SynthDef(\pf,{ |out=0|
		var plugin = VSTPlugin.plugins['Pianoteq 5'];
		var sig = VSTPlugin.ar(nil,2,params:['Sustain Pedal',0],info:plugin);
		Out.ar(out,sig);
	})
)

b=

a.controller.gui

a=Piano.new

~piano=(
  new:{
	  
  }
)

( //// waaaaaay back
	n=NodeProxy.audio(s,2);
	b=Bus.audio(s,2);
	n.source={In.ar(b,2)};
	SynthDef(\ss,{Out.ar(b,VSTPlugin.ar(nil,2))}).add;
	p=VSTPluginController(Synth(\ss)).open('/Library/Audio/Plug-Ins/VST/Pianoteq 5.vst',info:true);
	[type:\midi,midiout:p.midi,midinote:Pwhite(30,70,1999)].p.play;
	n.play;
//	n[1]=\filter->{|in| CombN.ar(in,1,decaytime:3)}
	n[2]=\filter->{|in| Phaser1.ar(in,rate:0.2,fb:0.8,depth:0.8).fold(0.9)}
	n[3]=\filter->{|in| LPF.ar(in,1800)}
)

	(
		{
			inf.do{
				n[4]=\filter->{|in| in*0.7+PlateReverb.ar(in)*4};
				rrand(8,13).wait;
			}
		}.fork
	)
	p.set('Sustain Pedal',0.8);
)



(// pianoteq	
	var play =
	{ 
		i=currentEnvironment; 
		all {:x,x<-i.keys,
			i.controller.info.parameters.collect{|i|i.name.asSymbol}.asList.includes(x),
			::i.controller.set(x,i.at(x))
		};
		(type:\midi,midiout:i.controller.midi,midinote:i.midinote,note:i.note,degree:i.degree,amp:i.amp).play	
	};
	Event.addEventType(\piano,play,(parent:()));
	SynthDef(\vsti,{|out=0|
		var sig=VSTPlugin.ar(nil,2);
		Out.ar(out,sig)}
	).add;
	// make instance

	~piano={
		( //piano event
			new:{|self|
				var controller=VSTPluginController(Synth(\vsti));
				controller.open('/Library/Audio/Plug-Ins/VST/Pianoteq 5.vst',info:true)  //++self.plugin
		}
	)
	}
)
p=~piano.().new
p
(\type:\piano,\controller:p,note:3,dur:3).play


