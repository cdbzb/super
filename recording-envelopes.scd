
(
~makeEne = { | time length=4 |
	var size = 1024 * length;
	var path = "/tmp" +/+ "env" ++ time ++ ".wav";
	b= Buffer.alloc(s,size);
	fork{
		{ BufWr.ar( 
			SoundIn.ar(0) => Amplitude.ar(_), 
			b, 
			Line.ar(0,size,length,doneAction:2)
			loop: 0
		);nil}.play;
		length.wait;
		b.write(path,"wav","int16");
		b.path_(path);
	};
	b
};
~getEnv = { | time |
	var length;
	var path = "/tmp" +/+ "env" ++ time ++ ".wav";
	var b = Buffer.read(s, path, action: { |b|
		length = b.numFrames / 1024
	});
	b;
};
~playEnv =  { |b rate|
		 { PlayBuf.ar(1,b, rate: ( BufDur.kr( b) / (b.numFrames / 1024) ) * rate => _.lag(0.03) ) }
	 };
)


//a=~makeEnv.("20220513_111230")
b= ~getEnv.("20220513_111230");
b.plot

(
var env;

fork{ 0.02.wait;
	{
		//Gendy1.arWidth(freq:{ 400.rand }!3) * 4
		Saw.ar(freq:{ 400.rand }!3) 
		* ~playEnv.(b, 2.0.rand) 
		=> Pan2.ar(_,rrand(-1,1.0)) 
		* Env.linen(0,4,8).kr(2,gate:1) 
		=> FreeVerb.ar(_,0.6,1)
	}.play
}
)

