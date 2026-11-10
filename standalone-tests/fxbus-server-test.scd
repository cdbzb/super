// FxBus live half: needs a scsynth. Boots its OWN server on port 57190 (never
// the default 57110) on BlackHole 2ch, so it can run beside a live session.
// Run inside a sandbox that denies 57110 (see memory: headless sclang).
// Checks: arm on first send, one Effect shared by every send and by copies,
// re-arm after free / group freeAll / the silence timeout, prArmForPlay with a
// server, and the asOSCArgArray path Event msgFuncs and Synth args use.
(
var h = (thisProcess.nowExecutingPath.dirname +/+ "test-helpers.scd").load;
var assert = h[\assert];
var srv = Server(\fxtest, NetAddr("127.0.0.1", 57190));
Server.all.do { |sv| (sv !== srv).if { sv.sendQuit = false } };
srv.options.device = "BlackHole 2ch";
srv.options.sampleRate = 48000;
srv.options.numOutputBusChannels = 2;
srv.options.numInputBusChannels = 2;
Server.default = srv;
srv.waitForBoot {
	var fx, i1, i2, n1, copy, amp, ev, args, l;
	"== FxBus server tests ==".postln;
	fx = Effect.fx({ |i| i }, time: 0.3);
	assert.(fx.isLive.not, "not live before the first send");

	i1 = fx.asControlInput; srv.sync;
	assert.(i1.isInteger and: { fx.isLive }, "first asControlInput starts the Effect (bus %)".format(i1));
	n1 = fx.effect.synth.nodeID;
	assert.(fx.asControlInput == i1 and: { fx.effect.synth.nodeID == n1 }, "second send: same Effect, same bus");
	copy = [(out: fx)].deepCopy[0][\out];
	assert.(copy !== fx and: { copy.asControlInput == i1 }, "a deep copy answers the same bus");
	args = [\out, fx].asOSCArgArray;
	assert.(args == [\out, i1], "asOSCArgArray (Synth args / Event msgFunc) gives the bus (got %)".format(args));

	fx.effect.synth.free; 0.3.wait;
	assert.(fx.isLive.not, "isLive false once the synth is freed");
	i2 = fx.asControlInput; srv.sync;
	assert.(fx.isLive and: { fx.effect.synth.nodeID != n1 }, "re-arms with a new synth after free");

	n1 = fx.effect.synth.nodeID;
	srv.defaultGroup.freeAll; 0.3.wait;   // what MyFree's freeMyDefaultGroup does
	assert.(fx.isLive.not, "defaultGroup.freeAll kills it");
	fx.asControlInput; srv.sync;
	assert.(fx.isLive and: { fx.effect.synth.nodeID != n1 }, "re-arms after freeAll");

	// silence timeout: DetectSilence waits for a first sound, then frees after time
	n1 = fx.effect.synth.nodeID;
	{ Out.ar(fx.asControlInput, SinOsc.ar(440, 0, 0.1) * Line.kr(1, 1, 0.1, doneAction: 2)) }.play;
	1.5.wait;
	assert.(fx.isLive.not, "frees itself after the silence timeout");
	fx.asControlInput; srv.sync;
	assert.(fx.isLive and: { fx.effect.synth.nodeID != n1 }, "re-arms after the silence timeout");
	fx.free; srv.sync;
	assert.(fx.isLive.not and: { fx.effect.isNil }, "free stops it and forgets it");

	// prArmForPlay walks nested params and a take's per-note params
	ev = (params: (coef: 0.2, out: fx));
	EventList.prArmForPlay([ev]); srv.sync;
	assert.(fx.isLive, "prArmForPlay arms an FxBus inside params:");
	fx.free;
	l = MIDIItemPlayer([(midicmd: \noteOn, type: \mk, timestamp: 0, midinote: 60, dur: 0.5,
		sustain: 0.5, amp: 0.5)], nil).setParams([out: fx]).filter(key: \amp, func: _ * 2);
	EventList.prArmForPlay([(type: \mi2, player: l)]); srv.sync;
	assert.(fx.isLive, "prArmForPlay arms through player.setParams + filter");
	fx.free;

	// prepare arms before anything is sent
	l = EventList.new; l.beatDur = 1;
	l.events.add((when: 0, type: \note, instrument: \default, out: fx, dur: 0.1));
	l.prepare(thisThread.seconds, 0); srv.sync;
	assert.(fx.isLive, "EventList.prepare arms an event's out: FxBus");
	fx.free;

	// AmpSim.fx: Proteus Effect starts and answers a bus
	amp = AmpSim.fx("Filmosound_with_cab", inputChannels: 1, drive: 0.8);
	i1 = amp.asControlInput; srv.sync; 0.3.wait;
	assert.(amp.isLive and: { i1.isInteger }, "AmpSim.fx starts a Proteus Effect (bus %)".format(i1));
	amp.free;

	srv.sync;
	h[\report].();
	srv.quit;
	1.wait;
	0.exit;
};
)
