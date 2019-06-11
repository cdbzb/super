(//window
	~windowSetup = { |height=500, width=500, fontsize=64|
		w = Window.new(bounds: Rect(0,0,200,120), border:false).front; // can't be manually closed
		w.view.background=Color.grey;
		t=StaticText(w,w.bounds);
		t.string=" ";
		t.align=\center;
		t.font=Font("Monaco",48);
		w.front;
		CmdPeriod.doOnce({ w.close });
		w.drawFunc = { t.string=~t.beats.asInt.asString};
	};


	~windowSetup.();
	//w.front;
	w.alwaysOnTop=true;


{while { w.isClosed.not } { w.refresh; 0.04.wait; } }.fork(AppClock);

)


