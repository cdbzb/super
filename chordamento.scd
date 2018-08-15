( //setup 
	
	var chords;
	b=Array.newClear(4);
	4.do ({ arg i; 
		b[i]=NodeProxy.audio(s,1);
		b[i].source={arg f; SinOsc.ar(Lag.kr(f,5),0,0.1)};
		b[i].set(\f,(i*120));
		b[i].set(\out,i%2);
		b[i].play;
	});

	d={
		arg chord = [330,366,430,499];
		chord.do ({ arg item,index;
			b[index].set(\f,item);
		})
	};

	
	chords = Pseq ([
		[300,400,500,600],
		[330,400,530,900],
		[300, 400, 500, 650],
		[250,300,450,600]],inf);


	{
		chords.do({arg item,index;
			d.value(item);
			5.wait;
		})
	}.fork
)







