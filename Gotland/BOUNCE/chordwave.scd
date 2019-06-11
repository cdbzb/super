(// chordwave version 2 TODO panning also seperate voices
	SynthDef(\triangle,{ |freq len=300 vol=0.005 pan=0.5 bus=0|
		var env=EnvGen.kr(Env.triangle(len));
		var sig = SinOsc.ar(freq,0,env*vol);
		Out.ar(bus,Pan2.ar(sig,pan));
	},[1136,0,16]).add; //long lags

	~tri={|freq len=300 vol=0.005 pan=0.5 bus=0| 
		Synth.new(\triangle,[\freq,freq,\vol, vol,\len,len,\bus,bus,\pan,pan])};

	~playme={ |chord=#[360,460,520,660] len=300 pause=25 vol=1 pan=0.5 bus=0|
		var notes=Array.newClear(chord.size);
		Routine.new({ 
			chord.do({|item index| 
				index.postln;notes[index].postln;
				notes[index]=~tri.(item,len,bus:bus,vol:vol);
				pause.wait;
			});
		}).play;
		notes;
	};

	~chord=[440,500,400,564,604];
	~chords=[[440,500,400,564,604]];
	~chordWave={ |vol=0.005 tempo=1 |
		t=TempoClock.new.play;
		t.tempo=tempo;

//todo allow chords to be brought in
//todo try letting spaces happen 

	{
		var notes=~playme.(~chords.choose,len:90,pause:15,pan:0.9,vol:vol,bus:~out);
		SystemClock.beats.postln;
		//~playme.(~chords.choose,len:90,pause:15,pan:0.9,vol:0.5,bus:63);

		~reset={ |noteNum=0 target=600 |
			{
				var note=notes[noteNum];
				note.set(\freq,target,\vol,0);
				16.wait; //decay time after movement starts
				note.free;
				//notes[noteNum]=~tri.(~chord[noteNum]*[0.9,1,1,1.11].choose,bus:~out,vol:vol, len:90)
				notes[noteNum]=~tri.(~chord[noteNum]*[0.9,1,1,1.11].choose,bus:~out,vol:vol ) //LEN WAS 300!
			}.fork(t)
		};
		//TempoClock.tempo=10;
		//TempoClock.tempo=0.5;
		45.wait;
		3.do({
			~reset.(2,600); 15.wait;
			~reset.(1.500); 15.wait;
			~reset.(3.10); 15.wait;
			~reset.(0.1000); 15.wait;
			~reset.(4,400); 15.wait;
		});
		'releasing'.postln;
		notes.do({|item| item.set(\vol,vol*0.5)});
		12.wait;
		notes.do({|item| item.set(\vol,0.0)});
		SystemClock.beats.postln;
	}.fork(t);
	}
)



