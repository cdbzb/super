"~/tank/super/More-Organized-Trek/Songs/Three-song.scd".load;
(//////test parts{{{

	~three.aa=Part(start:0,music:(note:0))
	~three.aa.play
	~three.play
	~three.gg=Part(start:0,music:(lag:s.latency-0.03,type:\vsti,controller:~g.controller,note:3))
	~three.gg.play
	~three.play(\aa,\gg)
	~three.cursor_(0).play(\aa,\gg)
	all {:x,x<-~three.parts,x.music.class==Event,::~three.play(x)}
	all {:x,x<-~three.parts,x.start>=2,x.start<=3,::~three.play(x)}
	~three.cursor_(2)
	~three.play
	s.latency=0.1;
	
)//}}}
~three.cursor_(3)//{{{
s.latency=1
~three.play
~three.at(4).do(_.p)
~three.slide
~three.cursor_(0).play
~three.at(4).do(_.postln)
~three.play
s.latency_(0.1)
~three.cursor_(3)
(
	~three.slide.p;
	~three.guitar4.p;
	//~three.guitarSetup.p;
	//s.latency_(1);
	//~three.guit4.p;
	
	////~three.guide3.p
	//(note:1).play
)


~three.chords1.play
~a
~three.at(1)
a=all{:x,x<-~three.parts,x.syl<>0}
~three.play2(a.array)
b=~three.getPartsList(a.array)
a.array[0].class
~three.play(a.array)
a.array
~three.play2(\)
	//////// make this
	//~three.play(\slide,\bass8)
	////////
~three@2	
play(~three@5)
~three.play
a=~three@5
a.song
a.play
a.array
play(~three@2)
~three.play(\guide2)
~three.resources.at("guide2")
~three.resources.at(\guit0).play
~three.guit0.play
~three.play(\guit0,\pf6)
~three.play(~three@3).array
(~three@3).play
~three.slide.lag
~three.slide.play
~three.resources
~three@3
play(~three@3)
(~three@2).array
~three.cursor_(3)
~three.play((~three@3).array)
s.latency=-0.1


~three.guide3.class
~three@2.play
play(~three@2)
~three.play(\guide2)

~three.play(( ~three@2 ).array)
a=~three@3
a.array
~three.slide.parent

~three.slide
~three@3.array
~three.play(a.array)
a.array.do({|i|~three.play(i)})
~three.pbind
a.array
a.song
a.postcs

~three.play(2,3)
b=PartArray([1,2],~three)
b.song
b.array
~three.play
play((~three@2).array.unpack)
Array
a={|...args| args.valueArray}
a.(1,2,3,[4,5])
~three.resources
(~three@3).array//}}}

~three.play
~three.slide.play
~three.cursor_(3).play
(~three.at(3)++~three.bass4).do(_.p)
~three.at(4)
