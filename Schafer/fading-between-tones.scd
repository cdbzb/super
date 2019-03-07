( //load IRs
	~forest=Library.at(\functions,\prep).("/Users/michael/tank/IR/Saane/Forest/Forest_2.wav");
	~speaker=Library.at(\functions,\prep).("/Users/michael/tank/IR/Saane/Speakers_&_Telephones/Very_small_speaker_stereo.wav");
	~doorOp=Library.at(\functions,\prep).("/Users/michael/tank/IR/Saane/Domestic/Upstairs_1_floor.wav"); //change these!
	~doorCl=Library.at(\functions,\prep).("/Users/michael/tank/IR/Saane/Domestic/Upstairs_2_floors.wav");
)

////////NodeProxy style
( //set up the nodes
	~dry=NodeProxy.new.fadeTime=2;
	~dry.fadeTime=2;
	~dry.source={PinkNoise.ar(0.5 )};
	~dry.numChannels;
	~dry.reshaping=\elastic;

	~wet=NodeProxy.new.play;
	~wet.fadeTime=3;
	~wet.source={PartConv.ar(~dry,4096,~speaker)};
	~altiverb={|ir| ~wet.source={PartConv.ar(~dry,4096,ir)}};
	~wet.numChannels;
	~wet.reshaping=\elastic;
	s.plotTree;

	a=NodeProxy.new.fadeTime=2;
	a.fadeTime;
)

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
