s.pkill
Monitors.airpods
().play
(
a=List[];
b=List[];
c=List[];
2.do{|x|
	a.add( SynthVVST( \xuan2, version:2, params:(
		lyrics: "hi how are you r elephant + + chicken +",
		midinote: [1, 3, 5, 4].dm(\c),
		dur: "e e x e e ex x e x xe".beats,
		lag:0.2.dup(4)
	)) 
	.morphPhonemes([\korean, \english, \mandarin], randomSeed:4 + x)
	.build)
	;
	b.add(SynthVVST( \uni, version:2, params:(
		lyrics: "hi how are you r elephant + + chicken +",
		midinote: [1, 3, 5, 4, 5, 4, 3, 3, 2].dm(\c),
		dur: "e e x e e ex x e x xe".beats,
		lag:0.2.dup(4)
	))
	.morphPhonemes([\korean, \english, \mandarin], randomSeed:4 + x)
	.build)
	;
	c.add( SynthVVST( \uni, version:2, params:(
		lyrics: "hi how are you r elephant + + chicken +",
		midinote: [1, 3, 5, 4, 5, 4, 3, 3, 2].dm(\g),
		pitchTake:3,
		dur: "e e x e e ex x e x xe".beats,
		lag:0.2.dup(4)
	)) 
	.morphPhonemes([\korean, \english, \mandarin], randomSeed:4 + x)
	.build
)
	;
};
 
[
	instrument: [\bd_808, \bd_808, \sn_808].q(6),
	dur: "e e q".beats.q(6),
	amp:4
].pp;
{|x|
	a[x].play(func:{|i| FreeVerb.ar(i,0.2, 1) => Pan2.ar(_,0) });
	b[x].play(func:{|i| FreeVerb.ar(i,0.2, 1) => Pan2.ar(_, 1) });
	c[x].play(func:{|i| FreeVerb.ar(i,0.2, 1) => Pan2.ar(_, -1) *2});
	(latency:0.05,instrument:\cymbalsDS, amp:0.02).play;
	(freq:[1, 4, 6].df(\c), lag: "eex".beats).play;
	(freq:[1, 3, 6].df(\c), ).play
} => {|i|
	fork{
		i.(0);
		6.wait;
		i.(1)

	}
}
 )
  {
	  aVST.bus
	  .kr =>  FreeVerb.ar(_,1,1)}.play
aVST.controller.setTransportPos(0);
  aVST.controller.setPlaying(true);
  aVST
    a.project.tracks[0].groups[0].database
	(

		~build=false;
c = SynthVVST( \uni, version:2, params:(
	lyrics: "hi how are you r elephant + + chicken +",
	midinote: [1, 3, 5, 4, 5, 4, 3, 3, 2].dm(\c),
	pitchTake:3,
	dur: "e e x e e ex x e x xe".beats,
	lag:0.2.dup(4)
))
.morphPhonemesVST([\korean, \english, \mandarin], randomSeed:4);
(~build ? false).if{c.build}{c.playVST}

	)
	 (
		 (
			 sv:
			 SynthVVST( \xuan2, version:2, params:(
				 lyrics: "hi how are you r elephant + + chicken +",
				 midinote: [1, 3, 5, 4].dm(\c),
				 dur: "e e x e e ex x e x xe".beats,
				 lag:0.2.dup(4)
			 )) 
			 .morphPhonemes([\korean, \english, \mandarin], randomSeed:4 )
			 .build
			 ,
			 
			 play: {~sv.play}
		).play
	)
		Event.addEventType(type:\sv, func:{topEnvironment[\build].isNil.if{~sv.play}});
	(
		~build=true;
		( 
			type:\sv,
			sv: SynthVVST( \xuan2, version:2, params:(
				lyrics: "hi how are you r elephant + + chicken +",
				midinote: [1, 3, 5, 4, 4, 5, 6, 4, 3, 6 ].dm(\c),
				dur: "e e x e e ex x e x xe".beats,
				lag:0.2.dup(4)
			)) 
			.morphPhonemes([\korean, \english, \mandarin], randomSeed:4 )
			.build
		).play;
		~build=nil
		

		)
	)
