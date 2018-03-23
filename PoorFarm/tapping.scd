s.reboot;

b=SoundFile.collectIntoBuffers("/Users/michael/tank/super/PoorFarm/samples3/*");

(
c= {
		var env,envGen;
		env=Env.perc(0.01,Rand(1,6)); // attack, release 
		envGen=EnvGen.kr(env,doneAction:2,levelScale:8);
		Pan2.ar( PlayBuf.ar(1, rrand(0,(b.size-1)), 1, 1.0, 0.0, 0.0, 2) , Rand(-1,1) , envGen*Rand(0.05,0.2) );
}
)	
	
(t=Task({
	loop{
		(0.03*(rrand(3,15)/3)).wait;
		c.play;
	}
})
)

t.play;
t.start;
s.meter;

(	
Task ({ //record
  var path="/Users/michael/tank/poorfarm-renders/";
  var length=600;
	s.recChannels_(2);
	s.recHeaderFormat_("wav");
	s.recSampleFormat_("int16");
	s.prepareForRecord(path++"tapping.wav");
	1.wait;
	s.record(path++"tapping.wav");
	t.start;
	length.wait;
	s.stopRecording;	
	t.stop;
}).play;
)


s.reboot;
t.stop;
d=c.value;
o

d={rrand(-1,1).postln};
d.play;

rrand(-1,1).postln;


