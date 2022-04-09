( //defs
	{
		SynthDef(\strang,{|freq=400,gate=1,mistune=1.008,coupling=0.01,strings=0.55|
			var env = Env.new([0,1, 1, 0],[0.001,0.006, 0.0005],[5,-5, -8]);
			var inp = env.kr(gate:gate)*LFClipNoise.ar(2000)*0.1;
			var sig = DWGPlucked2.ar(freq:freq,  amp: 0.5,  gate: 1,  pos: 0.14,  c1: 1,  c3: 30,  inp: inp,  release: 0.1,  mistune: mistune,  mp: strings,  gc: coupling);
			Out.ar(\out.kr(1),sig)
		}).add;
		SynthDef(\strang_pos,{|gate=1,pos=0.2,mistune=1.008,amp=0.5 c3=30 c1=1,coupling=0.01,strings=0.55|
			var env = Env.new([0,1, 1, 0],[0.001,0.006, 0.0005],[5,-5, -8]);
			var down = env.kr(gate:gate-pos)*PinkNoise.ar(20)*amp;
			var speed = (gate - Delay2.kr(gate)).abs*5;
			//var down = env.kr(gate:gate-pos)*LFClipNoise.ar(2000)*amp;
			var up = env.kr(gate:pos-gate)*LFClipNoise.ar(2000)*amp;
			var inp= (up+down)*speed;
			var sig = DWGPlucked2.ar(mp:strings,gc:coupling,freq:\freq.kr(400,0.01),  amp:speed*amp,  gate: 1,  pos: 0.14,  c1: c1,  c3:c3 ,  inp: inp,  release: 0.1,  mistune: 1.008,  mp: 0.55,  gc: 0.01);
			Out.ar(\out.kr(1),sig*0.05)
		}).add;
	}.fork;

	~modes1=#[90, 140, 185, 211, 250, 363, 427];
	~modes2=[ 103,188,202,223,231,262,315,385,481,749 ];

	SynthDef(\sbrd,{| out=0 array=#[90, 140, 185, 211, 250, 363, 427]|
		var in = In.ar(out);
		var sig = DWGSoundBoard.ar(inp: in,  c1: 20,  c3: 20,  mix: 0.8,  d1:array[0],  d2:array[1],  d3:array[2],  d4:array[3],  d5:array[4],  d6:array[5],  d7:array[6],  d8:array@@7);
		ReplaceOut.ar(out,sig)
	}).add
)

(//nice
		d !? {d.free};
		d=Bus.control;
		h=6.collect{|i|Synth(\strang_pos,[\c1,1.3,\c3,180,\out,1,\amp,0.1,\freq,rrand(43,80).midicps,\pos,i*0.1+0.2])};
		g=6.collect{|i|Synth(\strang_pos,[\c1,1.3,\c3,180,\out,0,\amp,0.1,\freq,rrand(43,80).midicps,\pos,i*0.1+0.2])};
		~sb=Synth(\sbrd,addAction:\addToTail);
		~sb.set(\array,~modes2);
		b={var sig=SinOsc.kr(SinOsc.kr(0.2*LFBrownNoise0.kr(),mul:10,add:0.1),mul:1);Out.kr(d,sig)};
		c=b.play(addAction:\addToHead);
		g.do{|i|i.map(\gate,d)};
		h.do{|i|i.map(\gate,d)};
	~changeNotes=Routine{
		loop{
			var change=Pbrown(0.2,10).asStream;
			[g,h].choose.choose.set(\freq,rrand(43.0,80.0).midicps.postln);
			change.next.wait;
		}
	}.play;
	//~changeNotes.stop
	//[g,h].do(_.do(_.release))
)

(//derek bailey
	g=Array.newClear(6);
	~sb=Bus.audio(s,1).index;
	{
		[0,5,10,15,19,24].do{|i x| g[x] = Synth(\strang,[\freq,(i+40).midicps,\out,~sb])};
		{var sig=In.ar(~sb);sig=DWGSoundBoard.ar(sig,mix:0.4);Out.ar(1,sig.softclip)}.play(addAction:\addToTail);
		3.wait;
		loop{
			g[6.rand].set(\gate,[0,1].choose);
			0.4.rand.wait;
			//g[6.rand].set(\freq,rrand(40,76).midicps)
			g[6.rand].set(\freq,rrand(100,900))
		}
	}.fork
)
(
	g=Array.newClear(6);
	~sb=Bus.audio(s,1).index;
		[0,5,10,15,19,24].do{
			|i x| g[x] = Synth(\strang,[ 
				\freq,(i+40).midicps,
				\out,~sb,
				\gate,0
			])};
		{var sig=In.ar(~sb);sig=DWGSoundBoard.ar(sig,mix:0.0)
		//=>CrossoverDistortion.ar(_,smooth:0.99)
		;
		Out.ar(1,sig.softclip)}.play(addAction:\addToTail);
		~strings = [0,5,10,15,19,24] + 40 ;
)
(
		~frets=[0,2,2,1,0,0];
		~frets=[~frets,[0,0,2,2,2,0]].choose;
		g.do{|i x| i.set(\freq,~strings+~frets => _.midicps => {|i| i[x]})};
		fork{g.do{|i| i.postln;i.set(\gate,1); 0.02.rand.wait}}
)

(
b= Bus.control(s,1);
b.set(0);
a.map(\gate,b);

)


a=Synths(\strang_pos,\out,Effect(CrossoverDistortion.ar(_,smooth:0.98),out:[0,1]).bus.index,\mistune,1.508,\coupling,0.0008,\freq,[ 52,62, 69 ].midicps,\pos,[0.2,0.5,0.7],\gate,0)
a.map(\gate,b);
{SinOsc.kr(3,phase:pi)*3 =>Out.kr(b.index,_)}.play; "x.x.x.x.".asDrumPat(reps:inf)=>[dur:_,instrument:\sn_808]=>_.pp
a.set(\freq,[300,150,720])

