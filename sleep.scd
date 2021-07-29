(
o=s.options;
o.outDevice="TREKZ Titanium by AfterShokz";
o.inDevice="Built-in Microph";
s.reboot;
)
(
a="/Users/michael/tank/Nothing Much/Edited/*.wav".pathMatch;
b=a.collect{
	|i| 
	var file = SoundFile.openRead(i);
	var full = Buffer.read(s,i);
	var length = file.numFrames;
	( bufnum: Buffer.cueSoundFile(s,i,0,1) ,length:length,full:full)
};
~stories={
	fork{
		loop{
			b.scramble.do{ |c|

				//c=b.choose;
				//c.full.plot
				//{DiskIn.ar(1,c.bufnum)}.play(s,1);
				{
					//PlayBuf.ar(1,c.full.bufnum,rate:1,startPos:120*s.sampleRate)
					PlayBuf.ar(1,c.full.bufnum,rate:1)
					//PlayBuf.ar(1,c.full.bufnum,rate:48/44,startPos:120*s.sampleRate)
					=> Pan2.ar(_,0)
				}.play;
				\waiting.postln;
				( c.length / s.sampleRate /60).round(1).postln;
				( c.length /s.sampleRate).wait;
			}
		}
	}
}
)
~stories.value
s.meter
c.length/s.sampleRate/60
s.reboot

(
	var scale = Scale.choose(5).name.postln;
	scale = Scale.shang;
	~stories.value;
	//Hirajoshi nice
	//gong
	//Minor Pentatonic
	// Shang nice
	SynthDef(\saw,{
		Saw.ar(
			\freq.kr(400)
			// + LFBrownNoise2.kr(0.2)
		)
		=>Pan2.ar(_,\pan.kr(0))
		* Env.triangle(\length.ir(20)).kr(doneAction:2)
		* \amp.kr(0.1)
		=> LPF.ar(_,rrand(1500,8000))
		=>Out.ar(\out.kr,_)
	}).add;

	[
		dur: [ [0,2,4,6].q,Pwhite(1,15,inf) ].q,
		instrument: \saw,
		degree: Pwhite(-8,4,inf),
		length:Pwhite(5,60,inf),
	

		pan:Pwhite(-0.5,0.5,inf),
		rawAmp:Pgauss(0.06,0.01),
		amp:Pfunc{|e| e.rawAmp.min(0.12)},
		out:Effect(FreeVerb.ar(_,1,1)*0.1,inputChannels:2)
	].pp;


	


	~noise=();
	~noise.pink={PinkNoise.ar};
	~noise.white={WhiteNoise.ar(0.1)};
	~noise.crunch={ LFNoise2.ar(Rand(100, 1000)) };

	~filter=();
	~filter.bpf= {|dummy in freq=800|  BPF.ar(in * 15, freq , 0.2) };
	~filter.rhpf= { |dummy in freq=800| RHPF.ar(in, freq, 0.2) };



	Routine.new({
	inf.do({
	{ Pan2.ar(
	       	~filter.bpf(~noise.white, 375+rand(50))*EnvGen.kr(Env([0,1,0.9,0],[3.9,3,8]),doneAction:2) *0.05 ,
	rrand(-0.8,0.1))
	}.play;
	{ Pan2.ar(
		~filter.rhpf(~noise.white, 800)*EnvGen.kr(Env([0,1,0.9,0],[5.1,3,5]),doneAction:2)*0.03 ,
	rrand(0.8,-0.1))
	}.play;
	rand(3.5).wait;
	})}).play;

	//n={Out.ar(1,SinOsc.ar(440,0,0.05) )}.play;
	s.makeWindow
	//s.meter
)



