/* Per-note tempo follow — prototype (onset-gated-tempo-follow.md, retune §2e fork 3
   per-segment option). Runtime only: no class edits. Defines in topEnvironment:
     ~pnPlay.(\perNote)   segment boundaries at ByteDance note starts
     ~pnPlay.(\grid)      today's AudioItem.tempoFollowActions (0.25-beat grid)
   Both play only the vibes take, following EventList.current's clock from its when:.
   Cmd-. stops. */
(
var starts = File.readAllString(
	thisProcess.nowExecutingPath.dirname +/+ "vibes0-starts.txt"   // ByteDance note starts, chords merged (40 ms)
).split($ ).reject(_.isEmpty).collect(_.asFloat);

// Fade-in ends AT the attack (pre-roll), fade-out ends AT the next attack, so two
// synths overlap only in the `pre` window just before each attack.
SynthDef(\pnProtoRB, {
	|out=0, bufnum=0, amp=1, rate=1, startPos=0, sustain=1, fadeIn=0.008, fadeOut=0.008,
	 pitchShift=1, formant=1, pan=0|
	var sig, env, fi, fo;
	fi = fadeIn.min(sustain * 0.45);
	fo = fadeOut.min(sustain * 0.45);
	sig = RubberBand.ar(1, bufnum,
		rate: rate, pitchShift: pitchShift, trig: 1,
		startPos: startPos * BufSampleRate.kr(bufnum),
		loop: 0, doneAction: 0, formant: formant);
	env = EnvGen.kr(Env([0, 1, 1, 0], [fi, (sustain - fi - fo).max(0), fo], \sin), doneAction: 2);
	Out.ar(out, Pan2.ar(sig * env, pan) * amp)
}).add;

topEnvironment[\pnStarts] = starts;

topEnvironment[\pnActions] = { |ev, list, tempoEnv, starts, from = 0, pre = 0.008, minGap = 0.0625|
	var itemName = AudioItem.eventItemName(ev);
	var takeNum = ev[\take] ? 0;
	var path = AudioItem.takePath(AudioItem.folder +/+ itemName, takeNum);
	var buffer, sf, sourceDur, srcOffset, b0, startSec, endSec, fromBeat, fromSec, lastBeat;
	var wallAt, wallFrom, beats, bounds, actions, info;

	buffer = AudioItem.buffers.at(itemName.asSymbol, takeNum) ?? {
		AudioItem.buffers.put(itemName.asSymbol, takeNum, Buffer());
		AudioItem.buffers.at(itemName.asSymbol, takeNum)
	};
	(buffer.numFrames.isNil or: { buffer.numFrames == 0 }).if { buffer.allocRead(path).updateInfo };
	sf = SoundFile.openRead(path);
	sourceDur = sf.numFrames / sf.sampleRate;
	sf.close;

	ev = AudioItem.prResolveSourceMap(ev, itemName, takeNum);
	wallAt = { |bt| list.beatToWall(bt, tempoEnv) };
	b0 = ev[\when] ? 0;
	startSec = ev[\start] ? ev[\startPos] ? 0;          // the RESOLVED start (m.t0 on marks)
	srcOffset = AudioItem.prSrcOffset(ev, list, b0, takeNum);
	endSec = ev[\dur].notNil.if { (startSec + srcOffset.(b0 + ev[\dur])).min(sourceDur) } { sourceDur };
	fromBeat = from.max(b0);
	fromSec = startSec + srcOffset.(fromBeat);
	lastBeat = ev[\dur].notNil.if { b0 + ev[\dur] } {
		AudioItem.prSrcEndBeat(ev, list, b0, startSec, endSec, takeNum)
	};

	// note starts -> beats (exact inverse of srcOffset), inside the played range,
	// then the minimum-gap merge in beats
	beats = starts.select { |t| (t > fromSec) and: { t < endSec } }
		.collect { |t| AudioItem.prSrcEndBeat(ev, list, b0, startSec, t, takeNum) }
		.select { |b| (b > (fromBeat + 1e-6)) and: { b < (lastBeat - 1e-6) } };
	beats = beats.inject([], { |acc, b| (acc.isEmpty or: { (b - acc.last) >= minGap }).if { acc.add(b) } { acc } });
	bounds = [fromBeat] ++ beats ++ [lastBeat];

	wallFrom = wallAt.(from);
	actions = List[];
	info = List[];
	(bounds.size - 1).do { |i|
		var a = bounds[i], b = bounds[i + 1];
		var srcA = startSec + srcOffset.(a), srcB = (startSec + srcOffset.(b)).min(endSec);
		var wA = wallAt.(a), wB = wallAt.(b);
		var rate = (srcB - srcA) / (wB - wA).max(0.001);
		var pIn = (i == 0).if { 0.003 } { pre };
		var pOut = (i == (bounds.size - 2)).if { 0.02 } { pre };
		var delay = wA - pIn - wallFrom;
		var startPos = srcA - (pIn * rate);
		var sustain = (wB - wA) + pIn;
		// clamp: a negative delay or startPos just shortens the pre-roll
		(delay < 0).if { startPos = startPos - (delay * rate); sustain = sustain + delay; delay = 0 };
		(startPos < 0).if { delay = delay - (startPos / rate); sustain = sustain + (startPos / rate); startPos = 0 };
		info.add(rate);
		(sustain > 0.002).if {
			actions.add([delay, {
				Server.default.makeBundle((ev[\latency] ? Server.default.latency) + (ev[\lag] ? 0), {
					Synth(\pnProtoRB, [
						\bufnum, buffer.bufnum, \out, (ev[\out] ? 0).value, \amp, ev[\amp] ? 1,
						\rate, rate * (ev[\rate] ? 1), \startPos, startPos, \sustain, sustain,
						\fadeIn, pIn, \fadeOut, pOut,
						\pitchShift, ev[\pitchShift] ? 1, \formant, ev[\formant] ? 1, \pan, ev[\pan] ? 0
					])
				})
			}])
		};
	};
	topEnvironment[\pnLastInfo] = (segments: actions.size, notesUsed: beats.size,
		rateMin: info.minItem, rateMax: info.maxItem, rateMedian: info.asArray.sort[info.size div: 2],
		fromBeat: fromBeat, lastBeat: lastBeat, startSec: startSec, endSec: endSec);
	actions
};

// The vibes event as the list holds it (the followTrack: \marks one), forwarded the
// way EventList.prepare does, plus the list's lazy tempoEnv.
topEnvironment[\pnEvent] = {
	var list = EventList.current;
	var ev = list.events.detect { |e|
		((e[\item] ? "").asString == "vibes-test-1201") and: { e[\followTrack] == \marks } and: { AudioItem.stretchMode(e) != \env }
	};
	ev.isNil.if { Error("pnEvent: no vibes-test-1201 event with followTrack: \\marks in EventList.current").throw };
	[list.prForwardAudioFollow(ev.copy), list, list.prLazyTempoEnv]
};

topEnvironment[\pnPlay] = { |mode = \perNote, from|
	var ev, list, tempoEnv, actions;
	#ev, list, tempoEnv = topEnvironment[\pnEvent].value;
	from = from ? (ev[\when] ? 0);
	actions = (mode == \grid).if {
		AudioItem.tempoFollowActions(ev, list, tempoEnv, from)
	} {
		topEnvironment[\pnActions].(ev, list, tempoEnv, topEnvironment[\pnStarts], from)
	};
	"pnPlay %: % synths from beat %".format(mode, actions.size, from).postln;
	actions.do { |pair| SystemClock.sched(pair[0], { pair[1].value; nil }) };
	actions.size
};
"pn-proto loaded: % note starts".format(starts.size).postln;
)
