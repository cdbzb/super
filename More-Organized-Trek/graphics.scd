(
	~makeEm={

		var ev=();
		var counter=0;
		5.do{		
		var c = rrand(1.0!3,0)++[1];
		var myloop;
		var a=Synth(\default,[\freq,c.sum*300]);
		var w = Window("globes", 
			Rect(400.rand,500.rand,520,105)
			//Window.centerRect(520,105)
			//-[1500,0,0,0]
			, border:false
		)
		.background_(Color.clear)
		.front;
		v = UserView(w,w.view.bounds)
		.animate_(true)
		.frameRate_(20);
		v.drawFunc={ Pen.use {
			Pen.fillColor=Color.fromArray(c);
			5.do{|i|Pen.fillOval(Rect(i*105,0,100,100))}
		} };
		{ defer{w.close};a.release(2);myloop.stop }.sched(10);
		{ 
			myloop=Routine{
				1000.do{
					|i|
					c = [1,0,0,1]*i+( c*(1000-i) )/1000; 
					a.set(\freq,c.sum*300);
					0.03.wait;
				}
			}.play
		}.sched(4)
	};
	nil;
	}
)

	[0,( 60!4 ).rand].flatten.do{|x| AppClock.sched(x,~makeEm) };
	fork{5.do{defer { ~makeEm.();12.rand.wait } }}

(
		a={
				var circles = ();
				var screenWidth = Window.screenBounds.width;
				var bounds = Rect.new(0, 300,screenWidth,screenWidth/5);
				circles.dead = Color.gray;
				circles.henoch = Color.red;
				circles.thalassa = Color.green;
				circles.window = Window.new('aa ', bounds, false, false)
						.background_(Color.clear);
				circles.view = UserView.new(circles.window,circles.window.view.bounds)
						.animate_(true)
						.frameRate_(20)
						.drawFunc={ Pen.use {
								var colors=[\dead,\henoch,\dead,\thalassa,\dead];
//								Pen.fillColor=Color.red;
								5.do{|i|
										Pen.fillColor=circles.at(colors[i].asSymbol);
										Pen.fillOval( Rect.new(i*bounds.width/5,0,bounds.width/5,bounds.width/5))
								}
						}};
//				circles.window.front;
//				circles.refresh;
//				{ defer{circles.window.close} }.sched(7);
				circles;
		}.value;
		fork{
				var  steps=190, length=4.5;
				var  env = Env.linen(1,2,1).asStream;
				b=Synth(\default,[
						\pan,-1,
						\freq,300,
						\out:Effect.new(FreeVerb.ar(_,0.7,1)).bus.index
				]);
				c=Synth(\default,[
						\out,Effect.new(FreeVerb.ar(_,0.6,1),out:1).bus.index,
						\pan,-1,
						\freq,500
				]);
				{ a.window.front }.defer ( s.latency );
				2.wait;
				steps.do{
						|i| 
						var e=env.next;
						var color = Color.green.blend(Color.red,e)  ;
						var color2 = Color.red.blend(Color.green,e)  ;
						b.set(\freq,(e*200+300));
						c.set(\freq,500-(200*e));
						defer{ a.henoch= color2;a.thalassa= color } ;
						( length/steps ).wait
				};
				defer{a.window.fade(1)};
//				{ a.window.fade(1); }.defer;
				b.release(1);c.release(1)
		}
)
( // good one
		a={
				var circles = ();
				var screenWidth = Window.screenBounds.width;
				var bounds = Rect.new(0, 300,screenWidth,screenWidth/5);
				circles.dead = Color.gray;
				circles.henoch = Color.grey;
				circles.thalassa = Color.grey;
				circles.window = Window.new('aa ', bounds, false, false)
						.background_(Color.clear);
				circles.view = UserView.new(circles.window,circles.window.view.bounds)
						.animate_(true)
						.frameRate_(20)
						.drawFunc={ Pen.use {
								var colors=[\dead,\henoch,\dead,\thalassa,\dead];
								5.do{|i|
										Pen.fillColor=circles.at(colors[i].asSymbol);
										Pen.fillOval( Rect.new(i*bounds.width/5,0,bounds.width/5,bounds.width/5))
								}
						}};
				circles;
		}.value;
		fork{
				var  steps=190, length=4.5;
				var env = [ Env([0,0,1],[3,1]).asStream, Env([0,0,1],[1,1]).asStream ]
				;
//				var  env = Env.linen(1,2,1).asStream;
				b=Synth(\default,[
						\pan,-1,
						\freq,300,
						\out:Effect.new(FreeVerb.ar(_,0.7,1)).bus.index
				]);
				c=Synth(\default,[
						\out,Effect.new(FreeVerb.ar(_,0.6,1),out:1).bus.index,
						\pan,-1,
						\freq,500
				]);
				// to sink window and audio
				{ a.window.front }.defer ( s.latency );
////				2.wait;
				steps.do{
						|i| 
						var e=env.collect(_.next);
						var color = Color.grey.blend(Color.green,e[0])  ;
						var color2 = Color.grey.blend(Color.red,e[1])  ;
						b.set(\freq,(e[1]*200+300));
						c.set(\freq,500-(200*e[0]));
						defer{ a.henoch= color2;a.thalassa= color } ;
						( length/steps ).wait
				};
				{a.window.fade(1)}.defer(1);
//				{ a.window.fade(1); }.defer;
				1.wait;
				b.release(1);c.release(1)
		}
)
( //testing out Effect rewrite:
	[
		note:Pwhite(10,20.0,inf),
		dur:Pwhite(0.01,0.1),
		pan:Pwhite(-1,1),
		effect: Effect({|i|EchoCubic.ar(i,0.5,\len.kr(0.01,1),8) => DetectSilenceDry.ar(_,doneAction:2)},inputChannels:2) ,
		out:Pfunc({|e| e.effect.bus.index}),
		len:Pbrown(0.1,0.5,0.001),
		env: Pseg([0.1,0.5,0.1],[5,4],\lin,inf),
		fxA:Pfunc({|e| e.effect.synth.set(\len,e.env)})
	].p.fin(300).play;
	//s.plotTree;s.meter
)
s.reboot
