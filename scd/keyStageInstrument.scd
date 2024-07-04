MIDIClient.init
KeyStage.id
(
var notes = Array.fill(128, nil);
    MIDIIn.connect;    // init for one port midi interface
    ~noteOn = { arg src, chan, num, vel;    notes[num] = Synth(\default, [freq: num.midicps, amp: vel/128]) };
    ~noteOff = { arg src, chan, num, vel;    notes[num].release(0.5)} ;
    ~polytouch = { arg src, chan, num, vel;    notes[num].set(\freq, num.midicps * (vel/128).midiratio); };
    MIDIIn.addFuncTo(\noteOn, ~noteOn);
    MIDIIn.addFuncTo(\noteOff, ~noteOff);
    MIDIIn.addFuncTo(\polytouch, ~polytouch);
)

