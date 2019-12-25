a=[4...8];
a=[3,5,6,7];
a=all{:x,x<-(36..60),x.isPrime};

b={|array| array.collect({|item| item*array}).flatten};
c=b.(a);
c.do({|item index| {SinOsc.ar(item/4,0,0.05)*(1/(index+1))}.play(s,1)});

,BE,BE
Event
(
	~play={i=currentEnvironment; all {:x,x<-i.keys,i.at(x).class!=Function,::x.postln}; };
	e=(a:1,b:3,d:{|self|(self.a+self.b).postln},play:~play,parent:());
	e.play;
)
e.a
e.d
~parseMe={|event|event.keysDo{|i|i.postln}};
Event.addEventType(\xxx,~parseMe())


Environment

(
	Pdef(\temp, Pmono(
		\pluckD,
		\degree,Pseq([ [1,3,5],[1,4,6] ])-1,
		\amp,0.025,
		\out,[0,1],
		\smooth,Pwhite(0.2,0.3,inf),
		\del,Pwhite(0.5,1,inf),
		\dur,Pseq(~three.parse(3,[ [1,1] ])++2,inf),
		\coef,0.1,//Pbrown(0.1,0.9,0.03),
		\lag,Pwhite(-0.01,0.01)
	)
);
)

(
	a=Song(\test,['why do you think that?',"a4 c e",'sd sd sd',"e f g",'were e',"g a b"] );
	a.stuff=4;
	a.resources;
	a.bassnotes9=Part(start:3,music:(note:3));
	a.bassnotes8=Part(start:2,music:(note:3));
	a.parts;
	a.bassnotes9;
)
a.play
a.play
a.cursor
a.bassnotes9.sched(2)
a.bassnotes9.music.play
a=Part(1,2,3,4)
a=Part(y:9)
a.class
a.syl
a.music.class
a.play
a.bassnotes8
all {:x,x<-a.resources,x.class==Part}


a.stuff=9
a=Song

a.lag

a.resources.stuff
resources.at(stuff)
a.resources.at(\stuff)
a.resources
a.stuff(4)
"ppp_".exclude($_)
a.stuff

a.part(\tt,3)
a.p
a.parts.put(\tt,6)
a.p
a.pbindFrom(0)
a.durTill(2,3)
a.durs
~xtreme.at(2)
a.pbind[2].play
~xtremeAlt.parts.strum1.p;~xtremeAlt.pbind[0].play;
~xtreme.resources.bassBus
a
1 !? {b=5}
b
~xtreme.cursor=1;
~xtreme.play2
~xtreme.play2
~xtreme.class
~alt.durs[10].list
~xtreme.durs[10].list
~alt.durTill(10,0)
~xtreme.durTill(10,0)
~alt.secDur[0]
~xtreme.secDur[0]
~xtremeAlt.bassBuss
~alt.cursor=10
~alt.play
~alt.parts.tremoChord.music.play;
~alt.parts.tremoChord2.music.play
~xtreme.tremoChord.p;
~xtreme.tremoChord2.p
~xtreme.resources.at(\bassBus)
~xtreme.resources.class
~xtreme.resources
~xtreme.play2
~xtreme.bassBus=3
~xtreme.bassBus={|a|a}
~xtreme.bassBus=Bus.audio(s,1)
~xtreme.bassBus
~xtreme.resources.put(\bassBus,Bus.audio(s,1))
~xtreme.foo=3
~xtreme.foo

~xtreme.strum1.p;~xtreme.pbind[0].play;
~xtreme.bassT2.play
~xtreme.infrastructure.value;~xtreme.play2

~xtreme.play2
~xtreme.pts.do(_.p);~xtreme.pbind[0].play
~xtreme.bassnote.play
s.latency=3
~xtremeAlt.parts.bassnote.music.play
a.song
(lag:~xtremeAlt.durs[1].list[3]/2,note:[-5,-2,0,4,7],strum:0.03,sustain:2).play
a={SinOsc.ar(300,0,0.1)}.play
s.reboot
a.lyrics[1].class
~xtreme.parts
~xtreme
(
	a=Part(start:1,music:(note:1),parent:~xtreme);
	b=Part(start:2,music:(note:0),parent:~xtreme);
	b.parent=~xtreme;
	a.parent=~xtreme;
	c=[a,b,~xtreme.parts.ddd];
	c.ply;
	~xtreme.parts.fff=(start:3,music:(note:23))
	~xtreme.parts.fff=a
	~xtreme.fff.p
	~xtreme.play
	~xtreme.pts.do{|i|i.p};//~xtreme.pbind[0].play
	~xtreme.weeeeuw.play
	s.bind{~xtreme.weeeeuw.music.play}
	~xtreme.weeeeuw.music.source
	~xtreme.cursor=0;
	~xtreme.bassnote.p
	~xtreme.bassnote.start
	~xtreme.durTill(0,0)
	~xtreme.pts.do{|i|i.start.post;' '.post;i.syl.postln}
	~xtreme.pts.do{|i|i.name.post;' '.post;i.syl.postln}
	~xtreme.strum1.play
	~xtreme.durTill(0,0)
	~xtreme.durs[0].list
	~xtreme.pts.do{|i|i.p}
	s.latency
	~xtreme.cursor=0
	~xtreme.
	~xtreme.bassnote.p
	~xtreme.pts.do{|i|i.class.postln}
	~xtreme.cursor
	~xtreme.play
	~xtreme.pts.do(_.name.postln)
	~xtreme.pts.do{|i|i.name.postln}
	~xtreme.bassnote.p
	
	a=(start:3,music:(note:23),syl:1,lag:1)
	b=~xtreme.asPart(a)
	b.play
	p=Part(s)
	a.keys.do{|i| n}
	p.syl=a.syl
	p.syl
	p.music_(2)
	p.music=3
	p.keys.do(_.postln)
	p.music
	p.lag
	p.syl
	~xtreme.asPart(())
	b=Part()
	b.start=a.start
	a.start
	~xtreme.fff
	~xtreme.parts
	~xtreme.resources.at(\fff)
	~xtreme.parts.class
	~xtreme.parts.fff
	~xtreme.ddd.class
	~xtreme.ddd.p
	~xtreme.fff.class
	~xtreme.parts.do(_.p)
	~xtreme.parts.strum3.p
	j
	~xtreme.foo=Part(start:0,music:(note:7)).play
	~xtreme.parts.foo=Part(start:3,music:(note:33)).play
	~xtreme.parts
	~xtreme.foo.play
	~xtreme.pts
	~xtreme.parts.foo.play
	~xtreme.resources.at(\foo)	
	c.do(_.p)
)
z=[2,3]
z.asdlkgj
c=PartArray.with(a,b)
c=PartArray.new(2)
c.class
c.add(a)
c.add(b)
c.parent
c.play
all{:x,x<-c,::x.p}

)
c.play
c.class
c.do(_.p)
~xtreme.addPart(\kkk,a)
~xtreme.parts
a.play
a.p
[a,b]
c[0].p
c.play
c=PartArray.newFrom(List[a,b])
Array
a.class
c.class
c.size
c.play
a.play
b.play
[a,b].do(_.p)
a.p
b.p
a.parent
c.do(_.p)
~xtreme.dur

(note:1).play
~xtreme.addPart.class
~xtreme.resources.do(_.postln)		
~xtreme.resources.do(_.postln)
