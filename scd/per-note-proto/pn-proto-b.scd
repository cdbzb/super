/* Option B: ONE RubberBand synth, rate stepped only at note starts (Env.step).
   Needs pn-proto.scd loaded first (reuses ~pnEvent, ~pnStarts). Adds:
     ~pnPlay.(\oneSynth)            and   ~pnPlay.(\oneSynth, fromBeat)
   Block-rounded boundaries: each segment's rate is computed from its ROUNDED wall
   duration, so the source position is exact at every note start (no drift). */
(
topEnvironment[\pnOneSynth] = { |ev, list, tempoEnv, starts, from = 0, minGap = 0.0625|
	var itemName = AudioItem.eventItemName(ev);
	var takeNum = ev[\take] ? 0;
	var path = AudioItem.takePath(AudioItem.folder +/+ itemName, takeNum);
	var buffer, sf, sourceDur, srcOffset, b0, startSec, endSec, fromBeat, fromSec, lastBeat;
	var wallAt, beats, bounds, walls, srcs, blk, w0, rounded, durs, levels, keep, total, fade = 0.02;

	buffer = AudioItem.buffers.at(itemName.asSymbol, takeNum) ?? {
		AudioItem.buffers.put(itemName.asSymbol, takeNum, Buffer());
		AudioItem.buffers.at(itemName.asSymbol, takeNum)
	};
	(buffer.numFrames.isNil or: { buffer.numFrames == 0 }).if { buffer.allocRead(path).updateInfo };
	sf = SoundFile.openRead(path); sourceDur = sf.numFrames / sf.sampleRate; sf.close;

	ev = AudioItem.prResolveSourceMap(ev, itemName, takeNum);
	wallAt = { |bt| list.beatToWall(bt, tempoEnv) };
	b0 = ev[\when] ? 0;
	startSec = ev[\start] ? ev[\startPos] ? 0;
	srcOffset = AudioItem.prSrcOffset(ev, list, b0, takeNum);
	endSec = ev[\dur].notNil.if { (startSec + srcOffset.(b0 + ev[\dur])).min(sourceDur) } { sourceDur };
	fromBeat = from.max(b0);
	fromSec = startSec + srcOffset.(fromBeat);
	lastBeat = ev[\dur].notNil.if { b0 + ev[\dur] } {
		AudioItem.prSrcEndBeat(ev, list, b0, startSec, endSec, takeNum)
	};
	beats = starts.select { |t| (t > fromSec) and: { t < endSec } }
		.collect { |t| AudioItem.prSrcEndBeat(ev, list, b0, startSec, t, takeNum) }
		.select { |b| (b > (fromBeat + 1e-6)) and: { b < (lastBeat - 1e-6) } };
	beats = beats.inject([], { |acc, b| (acc.isEmpty or: { (b - acc.last) >= minGap }).if { acc.add(b) } { acc } });
	bounds = [fromBeat] ++ beats ++ [lastBeat];

	walls = bounds.collect(wallAt);
	srcs = bounds.collect { |b| (startSec + srcOffset.(b)).min(endSec) };
	blk = Server.default.options.blockSize / (Server.default.sampleRate ? 48000);
	w0 = walls.first;
	rounded = walls.collect { |w| ((w - w0) / blk).round * blk };
	// drop boundaries that collapse onto the previous block
	keep = [0] ++ (1..rounded.size - 1).select { |i| rounded[i] > rounded[i - 1] };
	rounded = rounded[keep]; srcs = srcs[keep];
	durs = rounded.differentiate.drop(1);
	levels = durs.collect { |d, i| (srcs[i + 1] - srcs[i]) / d };
	total = rounded.last;
	topEnvironment[\pnLastInfo] = (segments: durs.size, rateMin: levels.minItem, rateMax: levels.maxItem,
		srcSpan: srcs.last - srcs.first, integrated: (levels * durs).sum, wallDur: total);

	[[walls.first - wallAt.(from), {
		Server.default.makeBundle((ev[\latency] ? Server.default.latency) + (ev[\lag] ? 0), {
			{
				var rate = EnvGen.kr(Env.step(levels, durs)) * (ev[\rate] ? 1);
				var sig = RubberBand.ar(1, buffer.bufnum, rate: rate,
					pitchShift: ev[\pitchShift] ? 1, trig: 1,
					startPos: srcs.first * BufSampleRate.kr(buffer.bufnum),
					loop: 0, doneAction: 0, formant: ev[\formant] ? 1);
				var amp = EnvGen.kr(Env([0, 1, 1, 0], [0.003, (total - 0.003 - fade).max(0), fade]), doneAction: 2);
				Out.ar((ev[\out] ? 0).value, Pan2.ar(sig * amp, ev[\pan] ? 0) * (ev[\amp] ? 1))
			}.play
		})
	}]]
};

topEnvironment[\pnPlay] = { |mode = \perNote, from|
	var ev, list, tempoEnv, actions;
	#ev, list, tempoEnv = topEnvironment[\pnEvent].value;
	from = from ? (ev[\when] ? 0);
	actions = switch(mode,
		\grid, { AudioItem.tempoFollowActions(ev, list, tempoEnv, from) },
		\oneSynth, { topEnvironment[\pnOneSynth].(ev, list, tempoEnv, topEnvironment[\pnStarts], from) },
		{ topEnvironment[\pnActions].(ev, list, tempoEnv, topEnvironment[\pnStarts], from) });
	"pnPlay %: % synths from beat %".format(mode, actions.size, from).postln;
	actions.do { |pair| SystemClock.sched(pair[0], { pair[1].value; nil }) };
	actions.size
};
"pn-proto-b loaded".postln;
)
