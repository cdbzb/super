(
	~fs=Array.newClear(16);
	~makeExpressionBus={ |instance chan=0 update=0.1|
		var mod=NodeProxy.control(s,1);
		mod.source={SinOsc.kr(0.1)};
		{
			loop({
				mod.bus.get({|value| ~fs[chan]=value+1*64});
				instance.expression(~fs[chan],chan);
				update.wait;
			})
		}.fork;
		mod;
	}

)

s.makeWindow;
( //add to synful
	~makeExpEnvs={ |instance|
		(
		node:Array.newClear(16),
		fs:Array.newClear(16),
		activate:{|self chan=0 update=0.1|
			chan.postln;
			self.node[chan]=NodeProxy.control(s,1);
			self.node[chan].source=64;
			{ var ch=chan;ch.postln;
				loop({
					self.node[ch].bus.get({|value| self.fs[ch]=value+1*64});
					instance.expression(self.fs[ch],ch);
					update.wait;
				});
			}.fork;
		}
	)
})

~aa=~makeExpEnvs.(~syn1);
~aa.activate(0);
~aa.node[2].source={LFBrownNoise2.kr(0.2,2)};
~aa.activate(2);
~aa.node[0].source={LFBrownNoise2.kr(0.2,1)};
~aa.node[0].source={SinOsc.kr(0.1)*0.5+0.2};
(midiout:~syn1.controller.midi,type:\midi,dur:95,chan:0,midinote:60,amp:0.5).play
(midiout:~syn1.controller.midi,type:\midi,dur:95,chan:1,midinote:60+12.rand,amp:0.5).play
(midiout:~syn1.controller.midi,type:\midi,dur:95,chan:2,midinote:60+12.rand,amp:0.5).play
(midiout:~syn1.controller.midi,type:\midi,dur:95,chan:3,midinote:60+12.rand,amp:0.5).play
~aa.node[3].scope;
~syn1.patch(\horn,\none,2);
~aa.make=nil;
~aa;


~syn1;
~syn1=(parent:~synful);
~syn1.init;

(
	~exp=Array.newClear(14);
	14.do{|i|
		~exp[i]=~makeExpressionBus.(~syn1,chan:i);
		~exp[i].source={SinOsc.kr(rrand(0.01,0.10))}
	}
)

(
	16.do{|i|
		~syn1.setprog( ~syn1.patches.choose, 0,i)
	};
)

(
16.do{|i|
	(dur:25+5.rand,midinote:rrand(30,90),type:\midi,midiout:~syn1.controller.midi,chan:i,amp:rrand(0.05,0.4)).play
}
)
~syn1.node[1]=\filter->{|in| PlateReverb.ar(in, 0.6, 0.4,  damping: 0.6,  diffusion: 1)}

~exp[0].source;



(type:\midi,dur:100,\midiout:~syn1.controller.midi).play

~bus0.source=100;
~bus0.source={Env.perc(5,10).kr(gate:1)};

g.free;
~synful.controller.loaded;
1;
~synful.init;
s.reboot;
~synful.expression(100);
~synful.patch(\trombone,\none,0);
(
	16.do{|i|
		~synful.setprog(~synful.patches.choose,0,i);
		(amp:(rrand(40,127).trunc),midinote:30+rand(60),dur:14,type:\midi,midiout:~synful.controller.midi,chan:i).play;
	}
)
~synful.node[1]=\filter->{|in| FreeVerb.ar(in,mix:0.8,room:0.8)};


<>  Pchain


{ PinkNoise.ar(0.1) }.play;

(
	{
		~synful.init;
		~synful.controller.loaded.not.while({0.1.wait;});
		~map=Dictionary.new;
		~group=[\violin,\viola,\cello,\bass];
		~group.do{|inst index| ~map.add(inst->index);~synful.patch(inst,\none,index);[inst,index].postln };
		(type:\midi,midiout:~synful.controller.midi,chan:~map.at(\violin)).play;
		(type:\midi,midiout:~synful.controller.midi,chan:~map.at(\viola)).play;
		(type:\midi,midiout:~synful.controller.midi,chan:~map.at(\cello)).play;
		(type:\midi,midiout:~synful.controller.midi,chan:~map.at(\bass)).play;
		~vn=(type:\midi,midiout:~synful.controller.midi,chan:~map.at(\violin));
		~va=(type:\midi,midiout:~synful.controller.midi,chan:~map.at(\viola));
		(proto:~vn).play

	}.fork
)
(
p=Pbind(*[
	proto:Prand([~vn,~va],inf),
	//midinote: Pwhite.new(30, 40,  length:90)*2,
	midinote: Pslide.new( (40..70),  repeats: inf,  len: Pwhite(3,5),  step: Prand([3,-7],inf),  start: 0,  wrapAtEnd: true),
	dur: Pwrand.new([0.2,0.3,0.4], [0.5,0.25,0.25],inf),
	dev:Pfunc({~synful.expression(rrand(20,120),[0,1].choose)}),
	legato:Pwhite(0.9,1.51,inf)
]).play
)
p.free;

~synful.controller.loaded;

~syn1=(parent:~synful);
~syn1.init;
(type:\midi,dur:10,midiout:~syn1.controller.midi).play;
~map.at(\vn);

~multi=(channels:[\vn,\va,\vc,\cb],players:);
~multi.parts[1]

~synful.init;
~synful.expEnv[0].source=90;
~synful.expEnv[0].source={SinOsc.kr(0.2).range(0.2,0.8)}
~synful.expEnv[1].source={SinOsc.kr(0.2111).range(0.1,0.2)}
~synful.activate(0); ~synful.activate(1);
~synful.activate(2);
~synful.activate(1);
(
~synful.patch(\horn,\none,1);
~synful.patch(\trombone,\none,2);
~synful.expEnv[1].source={LFBrownNoise1.kr(1,0.3,2)};
~synful.expEnv[2].source={LFBrownNoise1.kr(1,0.3,4)};
~synful.expEnv[0].source={LFBrownNoise1.kr(1,0.3,3)};

{
	~synful.node[1]=\filter->{|in| FreeVerb.ar(in, mix:0.8,room:0.8)};
		(midinote:60+rand(12.0),midiout:~synful.controller.midi,dur:30,chan:0,type:\midi).play;
		(midinote:60+rand(12.0),midiout:~synful.controller.midi,dur:30,chan:1,type:\midi).play;
		(midinote:30+rand(12.0),midiout:~synful.controller.midi,dur:30,chan:2,type:\midi).play;
		15.wait;
	10.do{
		(midinote:30+rand(22.0),midiout:~synful.controller.midi,dur:30+5.rand,chan:0,type:\midi).play;
		(midinote:60+rand(12.0),midiout:~synful.controller.midi,dur:30+7.rand,chan:1,type:\midi).play;
		(midinote:40+rand(22.0),midiout:~synful.controller.midi,dur:30,chan:2,type:\midi).play;
		26.rand.wait;
	}
}.fork
)
~synful.init;
s.makeWindow;


(
	~synful.activate(0); 
	(midinote:60+rand(12.0),midiout:~synful.controller.midi,dur:30,chan:0,type:\midi).play;
	//~synful.expEnv[0].source=1;
	~synful.expEnv[0].source={Env.perc(2,9).kr*2-1*0.5.rand}
)

s.reboot;
~syn1=~synful.();
~syn1;
~syn1.init;
~syn1.expEnv[9].scope;
~syn1=nil;
~syn1.shuffle.();
~syn1.proto;
~syn1.activate;
~syn3=~synful.();
~syn2
~syn1.node[1]=\filter->{|in|FreeVerb.ar(in,0.8,0.8)}
~syn1.node[2]=\filter->{|in|Phaser2.ar(in,rate:0.02)}
~syn1.node[2]=\filter->{|in| MembraneCircle.ar(in,0.005)}
~syn1.node[2]=\filter->{|in| in+MembraneHexagon.ar(in,0.019,0.99)/2}
~syn1.node[2]=nil;
(
	{
		20.do{
			16.do{|i|
				(midinote:30+rand(49.0),midiout:~syn1.controller.midi,dur:30,chan:i,type:\midi).play;
				//~syn1.activate(i);
			};
			30.rand.wait;
		}
	}.fork
)
~syn1.expEnv;
(
	16.do{|i|
		//~syn1.expEnv[i].source={SinOsc.kr(0.2.rand)}
		~syn1.expEnv[i].source={ LFBrownNoise1.kr(rrand(0.5,1.4),rand(0.9),5.rand)*2-1 }
	}
)


	(midinote:60+rand(12.0),midiout:~syn1.controller.midi,dur:30,chan:0,type:\midi).play;
	~syn1.expEnv[0].source={Env.perc(2,9).kr*2-1*0.5.rand}
	~syn1.activate(9);
	~syn1.patch(\horn,\none,9);
	
	~syn1.expEnv[9].source={Env.perc(2,9).kr*2-1*0.5.rand}
	~syn1.init;

	(
		~syn2=~synful.();
		~syn2.controller.loaded;
	)
