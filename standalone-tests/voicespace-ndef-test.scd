// VoiceSpace Ndef voices: mapping, lazy busses, unmap-on-end, ownership, no lane
// fan-out, and the prepared-path end entry. Language-side only: busses, groups and
// proxy settings are client-side state here; nothing needs to sound.
// Run: sclang -D standalone-tests/voicespace-ndef-test.scd
(
var h = (thisProcess.nowExecutingPath.dirname +/+ "test-helpers.scd").load;
var check = h[\assert];
var p, vs, v, bus, vs2, k, sched, labels;

p = Ndef(\zzzVsNdef, { SinOsc.ar(\freq.kr(440), 0, \amp.kr(0.1)) * \lfo.ar(1) + \pair.kr([1, 2]).sum });
vs = VoiceSpace.new;

// live: first event starts the voice and maps only the keys it names
vs.fireLive((voice: \fx, ndef: p, amp: 0.2));
v = vs.voices[\fx];
check.(v.notNil and: { v[\ndef] == true }, "ndef: event starts an Ndef voice");
check.(v.syn.isKindOf(Group), "Ndef voice's node is a Group (ramps land \\addBefore it)");
bus = v.busses[\amp];
check.(bus.notNil and: { p.nodeMap[\amp] == bus.asMap }, "named control is mapped onto its bus");
check.(v.busses[\freq].isNil and: { p.nodeMap[\freq].isNil }, "unnamed controls are left alone");
check.(v.lastVal[\amp] == 0.2, "dispatch wrote the value");

// later events need no ndef: — the voice remembers its proxy
vs.fireLive((voice: \fx, freq: T(660, 1, \lin)));
check.(v.busses[\freq].notNil and: { p.nodeMap[\freq] == v.busses[\freq].asMap },
	"a later key maps lazily");
check.(v.lastVal[\freq] == 660, "ramp dest recorded");

// audio-rate / multichannel controls are not driven
vs.fireLive((voice: \fx, lfo: 0.5, pair: 3));
check.(v.busses[\lfo].isNil and: { v.busses[\pair].isNil }, "audio-rate and array controls skipped");

// end: gate 0 unmaps to plain numbers and drops the voice
vs.fireLive((voice: \fx, gate: 0));
check.(vs.voices[\fx].isNil, "gate: 0 ends the voice");
check.(p.nodeMap[\amp].isNumber and: { p.nodeMap[\freq].isNumber }, "controls handed back as numbers");

// a hand set during the voice's life is respected at the end
vs.fireLive((voice: \fx, ndef: p, amp: 0.3));
p.set(\amp, 0.9);
vs.release(\fx);
check.(p.nodeMap[\amp] == 0.9, "a hand-set control is not overwritten on end");

// ownership: a second voice takes over; ending the first leaves the second mapped
vs.fireLive((voice: \a, ndef: p, amp: 0.1));
vs2 = VoiceSpace.new;
vs2.fireLive((voice: \b, ndef: p, amp: 0.4));
vs.release(\a);
check.(p.nodeMap[\amp] == vs2.voices[\b].busses[\amp].asMap, "ending the old owner keeps the new mapping");
vs2.release(\b);

// no lane fan-out for Ndef voices
check.(vs.computeLaneCounts([(voice: \fx, ndef: p, amp: [0.1, 0.2])])[\fx] == 1,
	"arrays do not fan an Ndef voice into lanes");

// sugar + prepared path: the list stamps voice/ndef, and gate 0 schedules an end
k = p.asEventList(\zzzVsNdefList, VoiceSpace.new).clear;
k.add(0, amp: 0.1);
k.add(2, amp: T(0.5, 1, \lin));
k.add(4, gate: 0);
check.(k.events.every { |e| e[\ndef] === p and: { e[\voice] == \zzzVsNdef } },
	"asEventList stamps ndef: and voice:");
sched = k.prepare(0, 0);
labels = sched.collect(_[\label]);
check.(labels.includes(\voice), "prepared path starts the voice");
check.(labels.includes(\ndefEnd), "prepared path schedules the Ndef end");

// voice defaults to the ndef's key; later keyframes on that voice inherit ndef:
k = EventList.kf(\zzzVsNdefStamp, VoiceSpace.new).clear;
k.add(0, ndef: \zzzVsNdef, amp: 0.1);
check.(k.events[0][\voice] == \zzzVsNdef, "no voice: -> voice is the ndef's key");
k.add(1, voice: \zzzVsNdef, amp: 0.2);
check.(k.events[1][\ndef] == \zzzVsNdef, "voice-only keyframe inherits ndef: from the voice");
k.add(1, voice: \pad, freq: 300);
check.(k.events[2][\ndef].isNil, "other voices are not stamped");
k.add(2, ndef: p, amp: 0.3);
check.(k.events[3][\voice] == \zzzVsNdef, "a proxy object keys by its Ndef key");

// Symbol.add: name is the voice (beats ndef:'s key), so later adds by name inherit ndef:
EventList.current_(EventList.kf(\zzzVsNdefSym, VoiceSpace.new).clear);
\zzzFx.add(0, ndef: \zzzVsNdef, amp: 0.1);
\zzzFx.add(4, amp: 0.4);
check.(EventList.current.events[0][\voice] == \zzzFx, "name beats the ndef: key as voice");
check.(EventList.current.events[1][\ndef] == \zzzVsNdef
	and: { EventList.current.events[1][\voice] == \zzzFx },
	"\\sym.add(4, ...) lands on the same voice and inherits ndef:");
\zzzPad.add(0, defName: \default, freq: 220);
check.(EventList.current.events.last[\voice] == \zzzPad, "\\sym.add on a keyFrame list: voice = name");
check.(EventList.current.events.last[\ndef].isNil, "a plain synth voice is not stamped with ndef:");
EventList.current.add(0, newType: \note, freq: 440, name: \zzzNote);
check.(EventList.current.events.last[\voice].isNil, "non-keyframe events get no voice from name");

// solo ignores Ndef automation; mute skips it
k.solo_([\pad]);
check.(k.shouldPlay(k.resolveEvent(k.events[1])), "solo lets Ndef keyframes through");
check.(k.shouldPlay(k.resolveEvent(k.events[2])), "solo keeps the soloed voice");
k.solo_([\somethingElse]);
check.(k.shouldPlay(k.resolveEvent(k.events[2])).not, "solo still drops non-Ndef keyframes");
k.solo_(nil).mute_([\zzzVsNdef]);
check.(k.shouldPlay(k.resolveEvent(k.events[0])).not, "mute drops Ndef keyframes");
k.mute_(nil);
check.(k.shouldPlay(k.resolveEvent(k.events[0])), "unmuted plays");

// mod: is the plus-layer key; plus: stays an alias; mod: wins
check.((mod: 1).modEvent == 1 and: { (plus: 2).modEvent == 2 } and: { (mod: 1, plus: 2).modEvent == 1 },
	"mod: / plus: alias");

// T(dest, time) is a linear ramp
check.(T(1, 3).asRamp.isKindOf(Tuple3) and: { T(1, 3).asRamp.at3 == \lin }, "Tuple2 -> linear Tuple3");
check.(0.5.asRamp == 0.5, "non-ramps pass through asRamp");

h[\report].();
Server.all.do { |sv| sv.sendQuit = false };
0.exit;
)
