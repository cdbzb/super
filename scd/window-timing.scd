w=Window.new(bounds:Rect.new(0,0,500,100)).front;
w.alwaysOnTop_(true);
w.view;

(
	
	{
		(note:[1,2,3],amp:0.5,sustain:6).play;
		0.1.wait;
{		a=Image.open("/Users/michael/tank/super/Spock.png")}.defer;
		//a.bounds.postln;
		{w=a.plot(freeOnClose:true).alwaysOnTop_(true);}.defer;
		6.wait;
		(note:[1,2,3],amp:0.5).play;
		0.25.wait;
		{w.close}.defer;
	}.fork
	
)
