~effect={ |function| // function->input bus
	var bus= Bus.audio;
	var definition={function=>Out.ar(bus,_)};

};

(
	~effect2={ |function out=0| // node proxy version 
		var numberOfChannels=function.value.numChannels;
		var bus= Bus.audio(numChannels:numberOfChannels);
		var node=NodeProxy.audio(numChannels:numberOfChannels).play(out);
		numberOfChannels.postln;
		node.reshaping_(\elastic);
		node.source={In.ar(bus,numberOfChannels)=>function};
		\evaluating.postln;
		(node:node,bus:bus)
//		bus;
	}
)
(note:1,pan:1).play
a=~effect2.( FreeVerb.ar(_,1,1) );

(
	~effect3={  }
)
{Saw.ar(LFBrownNoise2.kr(mul:300,add:200),0.1)=>Out.ar(a,_)}.play
{Saw.ar(LFBrownNoise2.kr(mul:300,add:200),0.1)}.play(s,a)
(
{Saw.ar(LFBrownNoise2.kr(20+(1.0.rand)!4,mul:200,add:200),0.1)
	=>LPF.ar(_,400+SinOsc.kr(0.23).range(0,1400))}.play
	(s,~effect2.({|in| FreeVerb.ar(in,1,1!4)=>Phaser1.ar(_,rate:(5.3!4).rand) }).bus.index)
)
(
	[
		pan:Pwhite(0,-1),
		midinote:Pwhite(10,107),
		dur:Pwhite(0.1,0.2),
		effect: 
		~effect2.(FreeVerb.ar(_,SinOsc.ar(1).range(0.5,1),1!4)) ,
		out: Pfunc({|i|i.effect.bus.index})+Pwhite(0,3),
		nw: [0].q(20)++[1].q(20),
		dev: Pfunc({|event|  (event.nw==1).if{event.effect.node.release(9);1.postln}{0.postln}}),
].pp
)
a=~effect2.( FreeVerb.ar(_,0.5,1!4) );
b={Impulse.ar(5)}.play(s,a.index+1)
a.scope
a
5.do({|i|{Impulse.ar(500.0.rand,0.01,0.04)}.play(s,i)})
s.options.numOutputBusChannels_(5)
s.reboot
a=~effect2.(FreeVerb.ar(_,1,1!5,mix:0.5),numberOfChannels:5).index


