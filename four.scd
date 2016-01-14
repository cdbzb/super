s.reboot
s.meter

( 
	a= {InFeedback.ar(5,1)};
	b= {InFeedback.ar(4,1)};
	c= {InFeedback.ar(3,1)};
	d= {InFeedback.ar(6,1)};
	//control LFOs hooked together
	{Out.ar(5,SinOsc.ar(0.01*d,0.3))}.play;
	{Out.ar(4,SinOsc.ar(0.01*a,0.01))}.play;
	{Out.ar(3,SinOsc.ar(0.01*b,0.02))}.play;
	{Out.ar(6,SinOsc.ar(0.01*c))}.play;
	//audio Oscs
	{
	e=Pan2.ar(SinOsc.ar(440+(100*a),1,0.1),b,c);
	e=FreeVerb.ar(e,d,0.5,0.5);
}.play;
{
	f=Pan2.ar(SinOsc.ar(340+(100*b),1,0.1),c,d); 
	f=FreeVerb.ar(f,a,0.5,0.5);
}.play;
{
	g=Pan2.ar(SinOsc.ar(240+(100*c),1,0.1),d,a);
	g=FreeVerb.ar(g,b,0.5,0.5);
}.play;
{
	h={Pan2.ar(SinOsc.ar(540+(100*d),1,0.1),a,b)};
	h=FreeVerb.ar(h,c,0.5,0.5);
}.play;
	//{Out.ar(5,SinOsc.ar(0.01*d))}.play;
	//FreeVerb.ar(e,b,0.5);
)
