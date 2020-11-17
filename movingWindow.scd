~ttt = LambdaEnvir ((

	stills:~stills,
	fade:10,
	play:~stills.preview(~)

))


a=Still(~stills,'what is it you want',5,5,0,["lll,mmm"])
a.play
(
P(
	\blech,start:1,music:
	Still(~stills,'what is it you want',text:["lll,mmm", ""],fade:10,wait:8)
);
Song.currentSong.blech.play;
)
(
	a=Still(~stills,'what is it you want',text:["lll,mmm", ""],fade:10,wait:8).play;
	b=Still(~stills,'in the next room',text:["lll,mmm", ""],fade:10,wait:0).play;
//b.window
	c=Env.triangle(13,300).asStream;
	//c.next
	fork{
		(13/0.02).do{
			{ a.window.bounds_(Rect(0,c.next.floor,1500,890)) }.defer(0.1);
			{ b.window.bounds_(Rect(0,c.next.floor,1500,890)).front }.defer(0.1);
			0.02.wait;
		}
	}
	
)

