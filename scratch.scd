a=[4...8];
a=[3,5,6,7];
a=all{:x,x<-(36..60),x.isPrime};

b={|array| array.collect({|item| item*array}).flatten};
c=b.(a);
c.do({|item index| {SinOsc.ar(item/4,0,0.05)*(1/(index+1))}.play(s,1)});



