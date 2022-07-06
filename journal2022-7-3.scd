(
[
	dur:Pwhite(0.1,0.8,inf).stutter(Pwhite(1,3,inf)),
	instrument:\defaultPiano,
	t_trig:1,
	legato:Pwhite(0.9,3,inf),
	curve:8,
	degree:Pwhite(1,21,inf).stutter(Pwhite(0,3,inf)),
	octave:4,
	root:[1,5,7].choose,
	pedal:[1,1,1,0].q(inf)

].pm(\defaultRetrig) => Pdef(\piano,_) 
)
Pdef(\piano).play

(
r{
	var a=();
	var pitches = [300,300,350,375,380,350,300].q.asStream;
	

	3.do{
		10.do{
			var freq = 3.rrand(23).df(\c,octave:4);
			//var freq = pitches.next;
			a.keys.includes(freq).if{
				a.at(freq).set(\t_trig,1) 
			{
				a.put(freq, Synth(\defaultPiano,[\freq,freq,\curve,-4]));
			};
			0.2.rrand(0.8).wait
		};
		a.do( { |i| i.value.set(\pedal,0) }  );
	}

}.play
)
a.value(328)
Association
a.collect(_.value)
a=()
a.put(\c,\d)
a.keys.includes(\c)
a.at(\c)

