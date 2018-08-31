(
	SynthDef( \sargon1, { |i_out=12 fund=320 |
		var sig = TwoTube.ar(SoundIn.ar(0), 0.9 ,0.8 , fund,16*fund+5);
		Out.ar(i_out ,sig )}).add
)

a=Synth(\sargon);
s.meter;
MIDIIn.connect;

//set the action:
(
~noteOn = {arg src, chan, num, vel;
    x.set(\fund, (num-24).midicps );
};
MIDIIn.addFuncTo(\noteOn, ~noteOn);

//~noteOff = { arg src,chan,num,vel;
//    x.set(\gate, 0.0);
//};
//MIDIIn.addFuncTo(\noteOff, ~noteOff);
//
//~bend = { arg src,chan,val;
//    //(val * 0.048828125).postln;
//    x.set(\bwfreq, val * 0.048828125 );
//};
//MIDIIn.addFuncTo(\bend, ~bend);
)

//cleanup
MIDIIn.removeFuncFrom(\noteOn, ~noteOn);
MIDIIn.removeFuncFrom(\noteOff, ~noteOff);
MIDIIn.removeFuncFrom(\bend, ~bend);
