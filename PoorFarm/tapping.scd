s.boot;

b=SoundFile.collectIntoBuffers("/Users/michael/tank/super/PoorFarm/samples/*");

(
c= {
		var env,envGen;
		env=Env.perc(0.01,Rand(1,6)); // attack, release 
		envGen=EnvGen.kr(env,doneAction:2,levelScale:0.2);
		Pan2.ar( PlayBuf.ar(1, rrand(0,b.size), 1, 1.0, 0.0, 0.0, 2) , Rand(-1,1) , envGen*Rand(0.1,0.5) );
}
)	
	
c.play;
(t=Task({
	loop{
		(0.03*(rrand(1,15)/3)).wait;
		c.play;
	}
})
)

t.start;
t.stop;
d=c.value;
o

d={rrand(-1,1).postln};
d.play;

rrand(-1,1).postln;


