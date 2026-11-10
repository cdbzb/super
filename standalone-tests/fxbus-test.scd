// FxBus (FxBus.sc): the replayable effect bus. Pure language — no server.
// What it must keep true without a synth: prints/stores as its source, every
// copy (setParams + filter deep-copy midiEvents) shares ONE Effect,
// compares by recipe, and EventList.prArmForPlay is a no-op without a server.
// The live half (arm, re-arm after free, one Effect shared by notes) is
// fxbus-server-test.scd.
// Run: sclang standalone-tests/fxbus-test.scd
(
var h = (thisProcess.nowExecutingPath.dirname +/+ "test-helpers.scd").load;
var assert = h[\assert];
var a, b, c, e, ev, notes, player, filtered, outs, chained;

"== FxBus tests ==".postln;

a = AmpSim.fx("Filmosound_with_cab", inputChannels: 1, drive: 0.8);
assert.(a.isKindOf(FxBus), "AmpSim.fx answers an FxBus");
assert.(a.asString == "AmpSim.fx(\"Filmosound_with_cab\", inputChannels: 1, drive: 0.8)",
	"prints as its source, defaults left out (got %)".format(a.asString));
assert.(a.asCompileString == a.asString, "stores as its source");
assert.(a.asCompileString.interpret == a, "source round-trips to an equal FxBus");

e = Effect.fx({ |i| FreeVerb.ar(i, 1, 1) }, time: 4);
assert.(e.asString == "Effect.fx({ |i| FreeVerb.ar(i, 1, 1) }, time: 4)",
	"Effect.fx prints its function (got %)".format(e.asString));
assert.(Effect.fx({ |i| i }).asString == "Effect.fx({ |i| i })", "Effect.fx: all defaults left out");

assert.(a.copy === a and: { a.deepCopy === a } and: { a.shallowCopy === a },
	"copy / deepCopy / shallowCopy answer the same object");
ev = (coef: 0.2, out: a);
assert.(ev.deepCopy[\out].sharesEffectWith(a), "deepCopy of an Event: the copy shares a's Effect");
assert.([a, [a]].deepCopy.flat.every { |x| x.sharesEffectWith(a) }, "deepCopy of nested Arrays: copies share it");
assert.(ev.deepCopy[\out] == a, "a nested copy is == the original");

b = AmpSim.fx("Filmosound_with_cab", inputChannels: 1, drive: 0.8);
c = AmpSim.fx("Filmosound_with_cab", inputChannels: 1, drive: 0.7);
assert.(a == b and: { a.hash == b.hash }, "same recipe: == and hash agree");
assert.(a !== b and: { a.sharesEffectWith(b).not }, "same recipe, separate FxBus: separate Effects");
assert.(a != c, "different recipe: not equal");
assert.(a != 0 and: { (a == nil).not }, "never equal to a non-FxBus");
assert.((x: a).asCompileString == (x: b).asCompileString, "stable compile string for cache keys");

chained = AmpSim.fx("Filmosound_with_cab", out: Effect.fx({ |i| i * 0.5 }));
assert.(chained.asString == "AmpSim.fx(\"Filmosound_with_cab\", out: Effect.fx({ |i| i * 0.5 }))",
	"chained out: prints the downstream recipe (got %)".format(chained.asString));

// setParams streams each value per note and filter deep-copies midiEvents: every
// note must still hold the ONE FxBus, or each would start its own Effect.
notes = [0, 1, 2].collect { |ts| (midicmd: \noteOn, type: \mk, timestamp: ts, midinote: 60,
	dur: 0.5, sustain: 0.5, amp: 0.5) };
player = MIDIItemPlayer(notes, nil).setParams([coef: 0.4, out: e]);
filtered = player.filter(key: \amp, func: _ * 2);
outs = filtered.midiEvents.collect { |n| n[\params] !? { |p| p[\out] } }.reject(_.isNil);
assert.(outs.size == 3, "setParams put out: on every note (got %)".format(outs.size));
assert.(outs.every { |o| o.sharesEffectWith(e) }, "every note shares e's Effect after setParams + filter");

// no server: arming must not touch anything (headless suites stay pure language)
assert.(Server.default.serverRunning.not, "precondition: no server in this run");
EventList.prArmForPlay([(out: a), (params: (out: e))]);
assert.(a.effect.isNil and: { e.effect.isNil }, "prArmForPlay without a server starts nothing");
assert.(a.isLive.not, "isLive false before any Effect");

h[\report].();
Server.all.do { |sv| sv.sendQuit = false };
0.exit;
)
