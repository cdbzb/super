(
	w = Window.new(bounds: Rect(0,0,500,500), border:false).front; // can't be manually closed
	w.view.background=Color.white;
	t=StaticText(w,w.bounds);
	t.string="";
	t.align=\center;
	t.font=Font("Monaco",64);
	w.front;
	CmdPeriod.doOnce({ w.close });

	w.drawFunc = { t.string=~words.next;};

	a=AppClock;
	//a.tempo=2;
	Pbind(	\instrument, \default,	
		\func,Pfunc({w.refresh}),
		\dur, 1.0,
		\degree, Pseq([1,3,2,3,1],inf)).play(a);
)	

(
	~words=Pseq([
		"Some-",
		"one"  ,
		"or"   ,
		"some-",
		"thing",
	],inf).asStream
)
