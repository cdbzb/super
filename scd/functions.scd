( ///functions
	~adsr={SynthDef.wrap ( { |a=1, d=0.0, s=1, r=2, gate=1| EnvGen.kr(Env.adsr(a,d,s,r, 800),gate, doneAction: 2)})};
	~lfo={SynthDef.wrap ( { |rate=4 ,depth=0.05 | SinOsc.kr(rate, 0, mul:depth, add:1-(depth/2))})};
	~filter={arg in, cutoff ; SynthDef.wrap({ |in, cutoff, add|  LPF.ar(in, cutoff+add+1) },[],[in,cutoff]); };
	~verb={arg in; SynthDef.wrap({ | in, mix=0.9, room=0.5  | FreeVerb.ar(in, mix, room)},[],[in])}; 
	~out2={arg in; SynthDef.wrap({ | in, i_bus=0| Out.ar([i_bus, i_bus+1],in )},[],[in])};
	~pan={arg in, pan; SynthDef.wrap({|in, pan=0| Pan2.ar(in,pan)},[],[in])};
	~busMapper={ | synth param initial_value  | var bus;  bus=Bus.control(s).set(initial_value); synth.map(param, bus); bus.index; };
)

( ///synthdef
d=SynthDef(\bbb, {| freq=350| var sig, in; 
	in=Saw.ar(freq*~lfo.(),\amp.kr(0.2,0.05)); 
	in= ~verb.(in);
	in = ~filter.(in, ~adsr.());
	~out2.(~pan.(in));
	//Out.ar(0,Pan2.ar(in,\pan.kr(0, 0.1), \amp.kr(0.2)));	
}).add
)

d.allControlNames;

(//a little piece
{ var whoosh, wibble, harsh, rise, bkl, risefreq ,bklvib ;
	whoosh=Synth(\bbb,[\freq, 350, \rate, 5, \a, 6, \cutoff, 500,\mix, 0.8, \room, 0.8]);
3.wait;
	wibble=Synth(\bbb,[\freq, 450, \rate, 10, \a, 0.5, \d, 1, \s, 0.3, \mix, 0.5]);
	whoosh.set(\gate, -8);
3.wait;
	harsh=Synth(\bbb,[\freq, 400,\cutoff, 500,\rate, 101,\depth, 0.2,\a,4, \d, 2,\s, 0.6,\r,8, \mix, 1, \room, 0.9,]);
	wibble.release;
4.wait;
	harsh.release;
3.wait;
	rise= Synth(\bbb,[\freq, 500, \rate, 7,\depth,0.02, \r, 8, \amp,0.1, \pan, 1]);
		risefreq=~busMapper.(rise, \freq, 500);
2.wait;
	{Out.kr(risefreq,Line.kr(500,2500,18, doneAction: 2	))}.play;
3.wait;
	rise.release;
	bkl=Synth(\bbb,[\freq, [400, 410] ,\cutoff, 1500,  \rate, 151, \depth, 0.2, \a,4, \d, 2,\s, 0.6,  \r,18, \mix, 1, \room, 0.9,\gate, 1, \amp, 0.07]);
		bklvib=~busMapper.(bkl, \amp, 0.05);
	{Out.kr(bklvib, SinOsc.kr(3.3)*0.01+0.045)}.play;
4.wait;
	bkl.release;
}.fork
)

( /////// as a function
~test= { |freqs| var whoosh, wibble, harsh, rise, bkl, risefreq ,bklvib, f ;
	freqs=Pseq(freqs).asStream;
	Routine({
		whoosh=Synth(\bbb,[\freq,freqs.next, \rate, 5, \a, 6, \cutoff, 500,\mix, 0.8, \room, 0.8]);
	3.wait;
		wibble=Synth(\bbb,[\freq,freqs.next, \rate, 10, \a, 0.5, \d, 1, \s, 0.3, \mix, 0.5]);
		whoosh.set(\gate, -8);
	3.wait;
		harsh=Synth(\bbb,[\freq,freqs.next,\cutoff, 500,\rate, 101,\depth, 0.2,\a,4, \d, 2,\s, 0.6,\r,8, \mix, 1, \room, 0.9,]);
		wibble.release;
	4.wait;
		harsh.release;
	3.wait;
		f=freqs.next;
		rise= Synth(\bbb,[\freq,f, \rate, 7,\depth,0.02, \r, 8, \amp,0.1, \pan, 1]);
			risefreq=~busMapper.(rise, \freq,f);
	2.wait;
		{Out.kr(risefreq,Line.kr(f,2500,18, doneAction: 2	))}.play;
	3.wait;
		rise.release;
		f=freqs.next;
		bkl=Synth(\bbb,[\freq, [f, f+10] ,\cutoff, 1500,  \rate, 151, \depth, 0.2, \a,4, \d, 2,\s, 0.6,  \r,18, \mix, 1, \room, 0.9,\gate, 1, \amp, 0.07]);
			bklvib=~busMapper.(bkl, \amp, 0.05);
		{Out.kr(bklvib, SinOsc.kr(3.3)*0.01+0.045)}.play;
	4.wait;
		bkl.release;
	})}
)

