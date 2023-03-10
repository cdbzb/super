(
	b=Bus.control;
	{
		var sig=Amplitude.kr(SoundIn.ar,releaseTime:0.4);
		Out.kr(b,sig)
	}.play;
Bus(b.index).scope
)

(
	c={
		Saw.ar(100)*(In.kr(b))
	}.play
)
c.free;

(

)
s.reboot;
( //recorder
	b=Buffer.alloc(s,(44100*5), 1);
	//grab audio into buffer
	a={|run=1|
		RecordBuf.ar( SoundIn.ar(),  bufnum: b.bufnum,  offset: 0,  recLevel: 1,  preLevel: 0,  run: run  loop: 1,  trigger: 1,  doneAction: 0)
	}
	// play back tune
	//stop and store
)
b.index;
(//record snip
{
	m={Impulse.ar(1)*0.1};
	n=m.play;
	4.wait;
	c=a.play;
	c.set(\run,1);
	5.wait;
	c.set(\run,0);
	c.free; a.free;n.free;
}.fork;
)
a.free;
b.play;
( 
	{ 
		var amp=Amplitude.kr( PlayBuf.ar(1, b.bufnum ) );
		Saw.ar(440,amp);
	}.play
)

~s1=~synful.();
~s1.init;
~s1.activate(0);
(
	p=Pbind(*[type:\midi,midiout:~s1.controller.midi,degree:Pseq([1,3,5,8],30)],dur:0.5).play;
	(type:\midi,midiout:~s1.controller.midi,dur:10).play;
	//~s1.expr[0].source={Amplitude.kr( PlayBuf.ar(1, b.bufnum ) )};
	~s1.expr[0].source={Amplitude.kr(SoundIn.ar(),attackTime:0.1,releaseTime:0.5)*2-1};
)
(//little song{{{
	{
		b=Buffer.read(s,"/Users/michael/tank/super/dum-dum.aiff");
		x.play;
		m={MembraneHexagon.ar(Impulse.ar(1!2)*0.1)};
		n=m.play;
		4.wait;
		8.do{
			b.play;
			{TwoTube.ar(PlayBuf.ar(1, b.bufnum)!2,0.5,0.6,1900.rand,1878.rand)}.play;
			8.wait;
		}
	}.fork
)//}}}
Server.killAll;
s.reboot;
b.write("/Users/michael/tank/super/dum-dum.aiff");
b=Buffer.read(s,"/Users/michael/tank/super/dum-dum.aiff");

b.plot;
Buffer

(//prep tamboura{{{
	w=Buffer.alloc(s, 512, 1);
	w.cheby([1,0,1,1,0,1]);
	w.cheby([1,0.01,1,1,0.1,0.8,0.5,0.05,0.1,0.1,0.1,0.3,0.4,0.1,0,0.5]);
)//}}}
(//tamboura-esque{{{
	x = {[300,360,400,540].do{|i|
		{
			Phaser1.ar(
				FreeVerb.ar(
					Shaper.ar(
						w.bufnum, 
						SinOsc.ar(i!2, 0, SinOsc.kr(rrand(0.05,0.12))),
						0.1
					),
					0.7,0.7),
					rate:0.05+LFBrownNoise1.kr(mul:0.1)) 
				}.play 
				//(s,(3.rand+1));
			}
};
x.play;
	//x.free; b.free;
)//}}}
( //record ~b{{{
	~b={
		[
			{b=Buffer.alloc(s,40100*4,1).bufnum}.value,
			{SoundIn.ar()=>RecordBuf.ar(_,b,run:1,doneAction:2,loop:0)}.play
		]
	}.value
)//}}}
( //formant pitchfollower{{{
	//{PlayBuf.ar(1,~b[0])}.play

	SynthDef("pitchFollow1",{|in=4|
		var amp, freq, hasFreq, out;

		in = In.ar(in);

		amp = Amplitude.kr(in, 0.05, 0.05);

		# freq, hasFreq = Tartini.kr(in);

		//out = Mix.new(VarSaw.ar(freq * [0.5,1,2], 0, LFNoise1.kr(0.3,0.1,0.1), amp))
		//out = Formants.ar(Vibrato.kr([freq,freq*2],rrand(5!4,6)),Vowel())*amp;
		out = Formants.ar(Vibrato.kr(Scale.major.degreeToRatio([1,3,5,7]-1)*freq,rrand(5!4,6)),Vowel())*amp
		=>Splay.ar(_)
		=>FreeVerb.ar(_,0.8,0.5);

		Out.ar(1,out)
	}).play;
)//}}}
(// play a chorus after recording ~b{{{
	{PlayBuf.ar(1,~b[0])}.play(s,1).dur(4);
	{PlayBuf.ar(1,~b[0])}.play(s,10).dur(4);
	Synth(\pitchFollow1,[\in,10])

)//}}}
( //original pitchFollow1 with AllpassN{{{
SynthDef("pitchFollow1",{//{{{
    var in, amp, freq, hasFreq, out;
    in = Mix.new(SoundIn.ar([0,1]));
    amp = Amplitude.kr(in, 0.05, 0.05);
    # freq, hasFreq = Tartini.kr(in, 0.93,1024,512,512);
    //freq = Lag.kr(freq.cpsmidi.round(1).midicps, 0.05);
    out = Mix.new(VarSaw.ar(freq * [0.5,1,2], 0, LFNoise1.kr(0.3,0.1,0.1), amp));
    6.do({
        out = AllpassN.ar(out, 0.040, [0.040.rand,0.040.rand], 2)
    });
    Out.ar(0,out)
}).play(s);}}}
)
//}}}
( //volume grabber{{{
	{
		//add amplitude in here......
		b=Coyote.kr(SoundIn.ar());
		d=DelayN.ar(b,1,0.15);
		c=DelayN.ar(b,1,0.145);
		a= RunningMax.ar(SoundIn.ar()*0.1,d);
		Poll.ar(c-0.1,a);
	}.play
)//}}}


(
	a=NodeProxy.audio.play;
	a.source= {PinkNoise.ar(Decay.kr(Coyote.kr(SoundIn.ar(),fastMul:0.5)))!2};//.scope;
	a[1]=\filter->{|in| LPF.ar(in,Tartini.kr(SoundIn.ar())*8+500,5)};
	a[2]=\filter->{|in| NHHall.ar(in,4)};
)


//reset peak follower when coyote hits zero

a={ SoundIn.ar()+NHHall.ar(Pan2.ar(SoundIn.ar(),\pan.kr(0.5)),5,stereo:\stereo.kr(0.5)) }.play;
a.set(\stereo,0.99)
a.set(\pan(0.9));
(
	
		SynthDef(\hall,{|out wet=1 lorat=1 |
			var in=In.ar(out,2);
			var sig = NHHall.ar(in,4,lowRatio:lorat,stereo:1);
			XOut.ar(out, wet, sig)}
		).add;
)
( //happy happy{{{
	{
		10.do{
			Pfxb(
				Pbind(*[
					degree:Pseq([1,1,2,1,[4,6],[3,5,8]])-1,
					amp:Pseq([23,17.5,20,18,17,19])/100,
					dur:Pseq([3,1,4,4,4,8])/4,
					root:10.rand,
					lag:Pwhite(0.00,0.02),
					pan:Pseries.new(-1,0.32,6)
				]).pad,\hall,\wet,0.4,\lorat,2).play;
				rrand(3,7).wait;
			};
		}.fork;
)//}}}


