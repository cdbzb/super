(
var notes, on, off;

MIDIClient.init;
MIDIIn.connectAll;

notes = Array.newClear(128);    // array has one slot per possible MIDI note

on = MIDIFunc.noteOn({ |veloc, num| //, chan, src|
    notes[num] = Synth(\wobbly_stack, [\fundamental, num.midicps,
        \amp, veloc * 0.00315,\ir,~ir]);
});

off = MIDIFunc.noteOff({ |veloc, num| //, chan, src|
    notes[num].release;
});

q = { on.free; off.free; };
)

o=Server.local.options;
o.memSize;
o.memSize=8192*16;
s.reboot;

