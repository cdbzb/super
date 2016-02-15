s.reboot
s.boot
s.free

	Server.default=s=Server.local;

f.value // random Rampup
x= Synth.new("EnvPlus",[\dur, 50, \bufnum, (rand(5)+1).postln, \out , [0,1].choose.postln  ])
x= Synth.new("EnvOnly",[,\dur, 35, \bufnum, rand(5).postln, \out , [0,1].choose.postln  ])



~label="shorter"
~path = "/Volumes/tank/SuperCollider/SampleRamper/";
s.prepareForRecord(~path++"trainramps_"++~label++".wav");
s.record(~path++"trainramps_"++~label++".wav");
s.stopRecording

(  //Start Here
       	(
	s.recChannels_(2);
	s.recHeaderFormat_("wav");
	s.recSampleFormat_("int24");
	);

   //more compactly (Chromebook)

//b=SoundFile.collectIntoBuffers("~/myhack/Users/michael/Shares/home/Sound_Library/sfx/trains - mission road train collage/media/*");

b=SoundFile.collectIntoBuffers("~/Shares/home/Sound_Library/sfx/trains - mission road train collage/media/*");


// accelerating pitch mono for now
SynthDef.new("RiseUp", { arg out=0,bufnum=0;
	var rate;
	rate = XLine.kr(0.1, 50, 90);
	Out.ar(out, 
		PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum)*rate, 1.0, 0.0, 0.0, 2)
	)
}).send;

SynthDef.new("EnvPlus", { arg out=0,bufnum=0,dur=5;
	var rate;
	rate = XLine.kr(0.1, 50, 90);
	Out.ar(out, 
		EnvGen.kr(Env.triangle(dur:dur), doneAction:2) *
		PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum)*rate, 1.0, 0.0, 0.0, 2)
	)
}).send;

SynthDef.new("EnvOnly", { arg out=0,bufnum=0,dur=5;
	Out.ar(out, 
		EnvGen.kr(Env.triangle(dur:dur), doneAction:2) *
		PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum), 1.0, 0.0, 0.0, 2)
	)
}).send;

f = { //Rise up on a random file
	var buf,outt;
	buf=rand(5).postln;
	outt=rand(2).postln;
x= Synth.new("RiseUp",[\out,outt,\bufnum, buf]);
}
)

b = Buffer.read(s, ~sounds.at(2));
b.numChannels
b.bufnum
b.play


b[1]
x=b[0].play
x.free


x= Synth.new("RiseUp",[\out,0,3]);

//old ways
//on mac 
~sounds = "/Users/michael/Shares/home/Sound_Library/sfx/trains - mission road train collage/media/*".pathMatch;

//on chromebook
~sounds = "~/myhack/Users/michael/Shares/home/Sound_Library/sfx/trains - mission road train collage/media/*".pathMatch;
~sounds.size;

~sounds.do({ |item,i| 
	Buffer.read(s,item,0,-1,i);
});

b = Array.fill(~sounds.size,{arg i; Buffer.read(s,~sounds.at(i),0,-1,i)});

