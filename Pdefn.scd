
s.boot;
Pdefn(\pitches,Pseq([200,300,400,500,600],inf));
(
a=Pbind(\dur, Pseq([1,2,3],inf),
      \freq, Pdefn(\pitches)
));
b=a.play;

Pdefn(\pitches,Pseq([150,300,450,500,600],inf));
