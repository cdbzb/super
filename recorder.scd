//	Diskin method	{{{1 
DiskIn
DiskOut
(
	SynthDef.new(\record_bus,{
		DiskOut.ar(\bufnum.ir,In.ar(0,2))
	}).add;
)
(
	r=
	(
		arm: {|self numChannels=2| 
			Buffer.alloc(s,2**16,numChannels)
				.write("~/diskouttest.aiff".standardizePath, "aiff", "int16", 0, 0, true);
	},

	)
)


b=r.arm(1);
// start something to record
x = Synth("bubbles");
x={Saw.ar(500)*0.02!2}.play;
x.free;

// allocate a disk i/o buffer
b= Buffer.alloc(s,2**16, 2).write("~/diskouttest.aiff".standardizePath, "aiff", "int16", 0, 0, true);
// create an output file for this buffer, leave it open
b.write("~/diskouttest.aiff".standardizePath, "aiff", "int16", 0, 0, true);
// create the diskout node; making sure it comes after the source
d = Synth.tail(nil, "record_bus", ["bufnum", b, \channels,{In.ar(0,2)}.play]);
//(addAction:1)
// stop recording
d.free;
// stop the bubbles
x.free;
// close the buffer and the soundfile
b.close;
// free the buffer
b.free;

// play it back
(
x = Synth.basicNew("help-Diskin-2chan");
m = { |buf| x.addToHeadMsg(nil, [\bufnum,buf])};

b = Buffer.cueSoundFile(s,"~/diskouttest.aiff".standardizePath, 0, 2, completionMessage: m);
)
x.free; b.close; b.free; // cleanup
( //	buffer method	{{{1
	SynthDef.new(\recc, {|bufnum|
		RecordBuf.ar(SoundIn.ar(), bufnum,  offset: 0,  recLevel: 1,  preLevel: 0,  run: 1,  loop: 0,  trigger: 1,  doneAction: 0)},
	  rates: nil,  prependArgs: nil,  variants: nil,  metadata: nil).add;

	~makeItem={ |seconds=4 channels=1| var buf= Buffer.alloc(s,s.sampleRate*seconds,channels);
	( 
		channels:channels,
		seconds:seconds,
		buffer: buf,
		// make a synthdef to keep the timing good
		ply:{|self| self.buffer.play},
		rec:{|self| Synth(\recc,[\bufnum,self.buffer.bufnum])},
		write:{|self path| self.buffer.write(path) },
	)
}
)
a=~makeItem.();
a.rec;
a.ply;
(
	a=~makeItem.();
	b=p({a.rec});
	Ptpar([
			0,Pbind(*[dur:Pseq([1],8)]),
			//4, p({a.ply}),
			4, Pseq([(note:61,dur:4,instrument:\recc,bufnum:a.buffer.bufnum)]),
			//4, (note:1,dur:4,instrument:\recc,bufnum:a.buffer.bufnum),
		]).play;
)
(
	//f=~makeItem.();
	Ptpar([
			0,Pbind(*[dur:Pseq([1],8)]),
			4+(0.12), p({a.ply}),
			4+(0.12), p({f.ply}),
			//4, Pseq([(note:61,dur:4,instrument:\recc,bufnum:f.buffer.bufnum)]),
			//4, (note:1,dur:4,instrument:\recc,bufnum:a.buffer.bufnum),
		]).play;
)
s.latency;
a.ply;
p({a.ply}).play;
a.buffer.play;
a.buffer;
a;
a.seconds;
a.buffer.write('/tmp/test.aiff');
a.buffer.play;
a.buffer.plot;
s.reboot;
(note:61,dur:4,instrument:\recc,bufnum:a.buffer.bufnum).play;
a.ply;


b.index;
(//record snip
	SynthDef(\playback,{|bufnum| Out.ar(1,PlayBuf.ar(1,bufnum))}).add;
{
	TempoClock.tempo=1;
	m=Pbind(\dur,1,\instrument,\hihat);
	y=Pbind(\instrument,\playback,\bufnum,b.bufnum,\dur,Pseq([Rest(4),5]));
	x={ 4.wait; d.play; };
	Ppar([m,y]).play
}.fork
)
(instrument:\playback,bufnum:b.bufnum).play;

(
{
	c=a.play;
	c.set(\run,1);
	5.wait;
	c.set(\run,0);
	c.free; a.free;n.free;
}.fork;
)
a.free;
b.play;
d=b;
b.plot;
( 
	{ 
		var amp=Amplitude.kr( PlayBuf.ar(1, b.bufnum ) );
		Saw.ar(440,amp);
	}.play
)

~s1=~synful.();
~s1.init;
~s1.activate(0);
s.meter;
~s1
(
	p=Pbind(*[type:\midi,midiout:~s1.controller.midi,degree:Pseq([1,3,5,8],30)],dur:0.5).play;
	(type:\midi,midiout:~s1.controller.midi,dur:10).play;
	//~s1.expr[0].source={Amplitude.kr( PlayBuf.ar(1, b.bufnum ) )};
	~s1.expr[0].source={Amplitude.kr(SoundIn.ar(),attackTime:0.1,releaseTime:0.5)*3-1};
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
b;

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
	s.meter;
