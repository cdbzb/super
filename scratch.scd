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
s.reboot
