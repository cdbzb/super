Window.closeAll
	title { |window text|
		StaticText(window,Rect (0,600,1400,200))
		.string_(text[0])
		.stringColor_(Color.rand)
		.align_(\center)
		.font_(Font(\helvetica,90,bold:true))
		;
		StaticText(window,Rect (0,810,1400,200))
		.string_(text[1])
		.stringColor_(Color.rand)
		.align_(\center)
		.font_(Font(\helvetica,90,bold:true))
	}

	plot { |markerName monitor=(-1)|
		var image=this.mark(markerName);
		var w = Window(bounds:Rect(1500*monitor,200,1400,800),border:false)
		.background_( Color.black)
		.drawFunc_({Pen.drawImage(Point(100,100),image,operation:'sourceOver',opacity:1)})
		.front;  //}.defer(Server.default.latency);
		^w
	}
+ Window {
	fade { |fadeTime=1 alpha=1|
		fork{
			{alpha>0}.while{
				{this.alpha=(alpha-0.01)}.defer;
				alpha=alpha-0.01;
				(fadeTime/100).wait;
			};
			{this.close}.defer;
		}
	}
}
	play { defer{ window=stills.preview(markerName,wait,fade,monitor,text) } }

(
	w={|text|{ 
		var window = Window(bounds:Rect(500.rand,500.rand,100,100),border:false,).front.background_(Color.rand());
		{window.fade(2)}.defer(1);
		StaticText(window,Rect(0,0,100,100)).string_(text)
	}.defer(s.latency) 
};
		fork{
			10.do{
				var note = 20.0.rand;
				(note:note).play;
				w.(note);
				1.3.wait;

			}
		}
)

	w.()

	(
		~window = Window(bounds:Rect(500.rand,500.rand,100,100),border:false,).front.background_(Color.rand()).alwaysOnTop_(true);
		~text =  StaticText(~window,Rect(0,0,100,100)).string_("hello");
		~text.string_("goodbye")
	)
		~window.close
		~text.string_("goodbye")
		~text.bounds_(Rect(10,30,100,100))
