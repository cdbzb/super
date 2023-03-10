(
	w = Window.new(bounds: Rect(0,0,500,500), border:true).front; // can't be manually closed
	a=Image.open("/Users/michael/tank/super/Spock.png");
	t=StaticText(w,w.bounds);
	t.string=" ";
	t.align=\center;
	t.font=Font("Monaco",96);
	w.front;
	w.drawFunc_({
		Pen.drawImage( Point(200,200), a, operation: 'sourceOver', opacity:1;
	)});
	w.refresh;
	t.string="rrr";
	w.front;
	CmdPeriod.doOnce({ w.close });

	~words=Pseq([ "Some-", "one"  , "or"   , "some-", "thing", ],inf).asStream
	(
		Pbind(\instrument,\default,\dur,0.5).play;
		{~words.do({ |i|
			t.string=i;
			0.5.wait;
		})}.fork(AppClock)
	)
)
