(
f = {"foo".postln };
g = {"bar".postln };
CmdPeriod.add(f);
CmdPeriod.add(g);
)

f={SinOsc.ar(400,0,0.1)}.play;
f.stop;
s.meter;
// Now press Cmd-.

CmdPeriod.remove(g);

// Now press Cmd-. Only f executes

CmdPeriod.remove(f); // must explicitly cleanup


// Now press Cmd-.

CmdPeriod.add(g); // one object is added only once.
CmdPeriod.add(g); // one object is added only once.


// Now press Cmd-.

// remove it again.
CmdPeriod.remove(g);


// note that often you want to automatically remove the function once it is evaluated
// instead of

f = { "foo".postln; CmdPeriod.remove(f) };
CmdPeriod.add(f);

// you can write:

CmdPeriod.doOnce { "foo".postln }

// a typical example:
(
w = Window.new("close on cmd-.").front;
CmdPeriod.doOnce { w.close };
)


// in some cases you might need to defer the function by a short amount of time
a = { Synth(\default)};
a.value;
CmdPeriod.add({{a.value}.defer(0.01)});

// remove all
CmdPeriod.removeAll
