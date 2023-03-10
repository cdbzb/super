(
	SynthDef( \sargon1, { |i_out=12 fund=320 | var env;
		var sig = TwoTube.ar(SoundIn.ar(0), 0.9 ,0.8 , fund,16*fund+5);
	env=EnvGen.kr(Env.asr(0.01,1,6),\gate.kr(1), doneAction:2);
		Out.ar(i_out ,sig*env )}).add
)

a=Synth(\sargon1, [\fund, 320]);
a.release;

MIDIClient.init;


(

var notes, on, off;
MIDIFunc.noteOn({|a b c d| a.postln;b.postln;c.postln;d.postln},nil,1);
MIDIFunc.noteOff({|e f g h| "releasing".postln;},nil,1);

MIDIIn.connectAll;

~notes = Array.newClear(128);    // array has one slot per possible MIDI note

on = MIDIFunc.noteOn({ |veloc, num, chan, src|
	    ~notes[num] = Synth(\sargon1, [\fund, (48000/num.midicps)]); 48000/num.midicps.postln;
},nil,1);

off = MIDIFunc.noteOff({ |veloc, num, chan, src|
    ~notes[num].release;
});

q = { on.free; off.free; };
)

~notes[60].release;
s.meter;
