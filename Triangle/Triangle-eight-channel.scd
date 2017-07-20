s.reboot
s.quit

(
o = Server.local.options;
o.devices;
o.numOutputBusChannels = 5;
o.device="USBStreamer ";
s.reboot;
)

( //play here - record if deired below
~pitches = [300, 400, 402, 680,  450, 451, 612]; //initial
~volumes = [1, 1, 1, 0.3,  1, 1, 0.3]; //initial
a = {                                            //single note
	var vol=0.1;
	var env, envGen;
	var num;
	num = rrand(0,5);
	env=Env.triangle(dur: 3); // dur, lev
	envGen=EnvGen.kr(env,doneAction:2,levelScale:vol);

	Out.ar(rrand(0,4),
		SinOsc.ar(~pitches[num],mul:envGen*~volumes[num]),
		rrand(0,1));
};

t=Task({ |delta|                  //play notes at random intervals
	loop {
		a.play;
		delta=rrand(0,5)*0.5; //tempo multiplier
		delta.wait;
	}
});

b=Task({                                        //change chords
	z=[1,2,3];
	loop{
	9.wait;
	switch(z.choose)
		{1}	{~pitches = [800,400,402,680,450,451,612];
			~volumes = [0.2, 1, 1, 0.3,  0.9, 0.9, 0.45]; 
			1.postln}
		{2}	{~pitches = [300,400,402,680,450,451,612];
			~volumes = [1, 1, 1, 0.3,  0.9, 0.9, 0.45]; 
			2.postln}
		{3}     {~pitches = [800,400,900,680,450,451,612];
			~volumes = [0.3, 1, 0.3, 0.3,  0.9, 0.9, 0.4]; 
			3.postln};
}});
t.play; b.play;
)

t.play
t.stop
b.play
b.stop

Task ({ //record 5-chans
  var path="/tmp/";
  var length=3600;
	s.recChannels_(5);
	s.recHeaderFormat_("wav");
	s.recSampleFormat_("int16");
	s.prepareForRecord(path++"Triangles-5chans");
	1.wait;
	s.record(path++"Triangles-5chans");
	t.play;
	b.play;
	3600.wait;
	t.stop;
	b.stop;
	3.wait;
	s.stopRecording;
}).play;


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
