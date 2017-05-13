s.reboot
s.quit

// octave divided in fifths
{SinOsc.ar(400,0,0.1)}.play;
{SinOsc.ar((400*(2**0.2)),0,0.1)}.play;
{SinOsc.ar((400*(2**0.4)),0,0.09)}.play;
{SinOsc.ar((400*(2**0.6)),0,0.07)}.play;
{SinOsc.ar((400*(2**0.8)),0,0.06)}.play;



( //play here - record if deired below
~pitches = [400, 400*(2**0.2), 400*(2**0.4), 400*(2**0.6), 400*(2**0.8),800, 800*(2**0.2) ]; //initial
//r.play;
t.play;
a = {                                            //single note
	var vol=0.1;
	var env, envGen;
	env=Env.triangle(dur: 12); // dur, lev
	envGen=EnvGen.kr(env,doneAction:2,levelScale:vol);
	Pan2.ar(
		SinOsc.ar(~pitches.choose,mul:envGen),
		rrand(0,1));
};

t=Task({ |delta|                  //play notes at random intervals
	loop {
		a.play;
		delta=rrand(0,5); //pause between notes
		delta.wait;
	}
});
)


b=Task({                                        //change chords
	z=[1,2,3];
	loop{
	9.wait;
	switch(z.choose)
		{1}	{~pitches = [400,(400*2^0.2),402,680,450,451,612];
			1.postln}
		{2}	{~pitches = [300,400,402,680,450,451,612];
			2.postln}
		{3}     {~pitches = [800,400,900,680,450,451,612];
			3.postln};
}});
t.play; b.play;
)

t.play
t.stop
b.play
b.stop

s.reboot
//record
       	Task({
	s.recChannels_(2);
	s.recHeaderFormat_("wav");
	s.recSampleFormat_("int16");
	~path="/home/michael/myhack/Volumes/tank/SuperCollider/";
	Server.default=s=Server.local;
	s.prepareForRecord(~path++"Triangle.wav");
	1.wait;
	s.record(~path++"Triangle.wav");
	t.play;
	b.play;
	600.wait;
	t.stop;
	b.stop;
	3.wait;
	s.stopRecording;
}).play
