NNdef

[1..100]
(1..100).select(_.odd).select(_<20)
all {:x,x<-(1..100),x.odd,x<20}
Quarks.gui
NNdrg
NNdef
Piano
Fdef(\a,{|i|i.select(_.odd)})
Fdef(\b,{|i|i.select(_>50)})
Fdef(\c,Fdef(\a.value(Fdef(\b))))
Fdef(\b).value((1..100))
a={|i|i.select(_.odd)}
b={|i|i.select(_>50)}
b.((1..100))
c=a<>b
c.((1..100))
(
	a=Array.newClear( 2 );
	a[0]={|i|i.select(_.odd)};
	a[1]={|i|i.select(_>50)};
	a.inject((1..100),{|a b|b.(a)});
)
Function
{SinOsc.ar(300,0,0.1)}.asSynthDef(name:\test).add
Synth(\test)
b=(_.odd)
c=(_>50)
[b,c].inject((1..100),{|a b| a.select(b)})

