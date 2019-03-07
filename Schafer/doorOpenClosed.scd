( //load IRs
	~forest=Library.at(\functions,\prep).("/Users/michael/tank/IR/Saane/Forest/Forest_2.wav");
	~speaker=Library.at(\functions,\prep).("/Users/michael/tank/IR/Saane/Speakers_&_Telephones/Very_small_speaker_stereo.wav");
	~doorOp=Library.at(\functions,\prep).("/Users/michael/tank/SchaferHouse/Next-Door/01-open-door.wav"); //change these!
	~doorCl=Library.at(\functions,\prep).("/Users/michael/tank/SchaferHouse/Next-Door/02-closed-door.wav");
	~ambiStreet= Buffer.read(path:"/Users/michael/tank/SchaferHouse/Freesound/139023__lossius__agotnes-terminal-b-format.flac");
	~street=Library.at(\functions,\prep).("/Users/michael/tank/SchaferHouse/Next-Door/Street-smooth-intimate.wav");
	~decoder = FoaDecoderMatrix.newPanto(7, k: 'dual')         // psycho optimised 7;
)

( //this first!
	o=s.options;
	o.memSize=2**17;
	s.reboot;
)

~speakers=Array.series(8,10);
(
	~dry=NodeProxy.new(rate: \audio, numChannels: 8);
	~dry.source={FoaDecode.ar(PlayBuf.ar(4,~ambiStreet,loop:1)*1,~decoder)};
	~wet=NodeProxy.new(rate: \audio, numChannels: 8).play(~speakers[0]);
	~wet.fadeTime=0.1;
	~wet.source={PartConv.ar(~dry,4096,~doorOp)};
	~wet.source={PartConv.ar(~dry,4096,~doorCl)};
	~wet.source=~dry;
)
~wet.source={PartConv.ar(~dry,4096,~doorCl)};
(	
	Routine.new({  
	~wet.source=~dry;
	7.wait;
	{Out.ar(~speakers,PlayBuf.ar(1,[~doors[10],~doors[11]])*0.6)}.play;
	4.wait;
	~wet.source={PartConv.ar(~dry,4096,~doorCl)*1.3};
	}).play
)
(
	~wetsteps=NodeProxy.new(s,\audio,2);
	~drysteps=NodeProxy.new(s,\audio,2);
	~wetsteps.source={PartConv.ar(~drysteps,4096,~street)};
	~wetsteps.source={PartConv.ar(~drysteps,4096,~forest)};
	~wetsteps.play(~speakers[1]);
	~drysteps.source={PlayBuf.ar(2,~footsteps[0])*0.7};
	~wetsteps.play(~speakers[3,5],fadeTime:19);
	~wetsteps.play(~speakers[5],fadeTime:9);
	~wetsteps.play(~speakers[0],fadeTime:9);
)
s.freeAll;



s.plotTree;
o.memSize=2**17;
o.memSize;
s.reboot;
////////NodeProxy style
( //set up the nodes
	~dry=NodeProxy.new.fadeTime=2;
	~dry.fadeTime=0.2;
	~dry.source={PinkNoise.ar(0.5 )};
	~dry.numChannels;
	~dry.reshaping=\elastic;

	~wet=NodeProxy.new.play;
	~wet.fadeTime=0.1;
	~wet.source={PartConv.ar(~dry,4096,~doorOp)};
	~setIR={|ir| ~wet.source={PartConv.ar(~dry,4096,ir)}};
	~bypass={~wet.source=~dry};
	~wet.numChannels;
	~wet.reshaping=\elastic;
)

//~wet.play(1,1,fadeTime: 1);

~setIR.(~doorCl);
~setIR.(~doorOp);
~bypass.();

( //moveit
	Routine.new({
		20.do({
		~altiverb.(~forest).play;
		4.wait;
		~altiverb.(~speaker).play;
		4.wait;
		~wet.play(0,1,fadeTime: 5);
		});
	}).play;

	Routine.new({
		20.do({
		~dry.source={BrownNoise.ar(0.2)};
		3.1.wait;
		~dry.source={WhiteNoise.ar(0.2)};
		3.1.wait;
		~wet.play(1,1,fadeTime: 5);
		});
	}).play
)

//Ndef style
)
Ndef.new(\altiverb,{ PartConv.ar(Ndef.ar(\a),4096,~speaker)}).play;
Ndef.new(\a,{PinkNoise.ar(1)});

Ndef(\a,{WhiteNoise.ar(1)});
Ndef(\altiverb).play([0,1],2);
Ndef(\a).fadeTime = 2;
Ndef.new(\altiverb,{ PartConv.ar(Ndef.ar(\a),4096,~speaker)}).play;
Ndef(\altiverb).fadeTime=3;
Ndef(\altiverb,{ PartConv.ar(Ndef.ar(\a),4096,~speaker)});
Ndef(\altiverb,{ PartConv.ar(Ndef.ar(\a),4096,~forest)});
Ndef.clear(8);

(
Ndef(\a ,{ |freq = 440, rate = 2|
    SinOsc.ar(freq * [1, 1.625]) * SinOsc.kr(rate).max(0) * 0.2
})
);

~altiverb={|ir| Ndef(\altiverb,{ PartConv.ar(Ndef.ar(\a;),4096,ir)})};
~altiverb.(~forest).play;
~altiverb.(~speaker).play;
Ndef(\a,{BrownNoise.ar(1)});



~aa[0]=NodeProxy.new;
~aa=NodeProxy.new;
~aa[0].source ={PinkNoise.ar(0.2)};
~aa[1].source.Saw.ar(400,0.1)};
~aa.objects[1].source.postcs;
~aa[1].play;
~aa=nil;
~aa.play;
