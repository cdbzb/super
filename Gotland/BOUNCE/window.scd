(//window
	~windowSetup = { |height=500, width=500, fontsize=64|
		var text;
		w = Window.new(bounds: Rect(0,0,200,120), border:false).front; // can't be manually closed
		w.view.background=Color.grey;
		text=StaticText(w,w.bounds);
		text.string=" ";
		text.align=\center;
		text.font=Font("Monaco",48);
		w.front;
		CmdPeriod.doOnce({ w.close });
		w.drawFunc = { text.string=~t.beats.asInt.asString};
	};


	~windowSetup.();
	//w.front;
	w.alwaysOnTop=true;

	{while { w.isClosed.not } { w.refresh; 0.04.wait; } }.fork(AppClock);
)


