s.reboot
s.quit

( //play here - record if deired below
~pitches = [300, 400, 402, 680,  450, 451, 612]; //initial
a = {                                            //single note
	var vol=0.1;
	var env, envGen;
	env=Env.triangle(dur: 3); // dur, lev
	envGen=EnvGen.kr(env,doneAction:2,levelScale:vol);
	Pan2.ar(
		SinOsc.ar(~pitches.choose,mul:envGen),
		rrand(0,1));
};

t=Task({ |delta|                  //play notes at random intervals
	loop {
		a.play;
		delta=rrand(0,5)*0.5;
		delta.wait;
	}
});

b=Task({                                       //change chords
	z=[1,2,3];
	loop{
	9.wait;
	switch(z.choose)
		{1}	{~pitches = [800,400,402,680,450,451,612];
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
