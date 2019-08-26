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
(//little song
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
)
Server.killAll;
s.reboot;
b.write("/Users/michael/tank/super/dum-dum.aiff");
b=Buffer.read(s,"/Users/michael/tank/super/dum-dum.aiff");

b.plot;
Buffer

(
	w=Buffer.alloc(s, 512, 1);

	w.cheby([1,0,1,1,0,1]);
	w.cheby([1,0.01,1,1,0.1,0.8,0.5,0.05,0.1,0.1,0.1,0.3,0.4,0.1,0,0.5]);

)
(//tamboura-esque
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
				}.play;
			}
		})
	//x.free; b.free;
