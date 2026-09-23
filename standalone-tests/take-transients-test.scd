// TakeTransients (audio-beat-marking-plan.md step 3): transient detection for
// audio takes — NRT Onsets + leading-edge backtrack + per-take cache.
//
// A synthetic hit train (sharp-attack decaying sines at known times, plus a
// quiet noise floor) is written to a temp file; detection must find every hit,
// within 1 ms after backtrack. The NRT render runs in its own scsynth (-N), not
// the live server.
//
// Run: /Applications/SuperCollider.app/Contents/MacOS/sclang standalone-tests/take-transients-test.scd
(
var h = (thisProcess.nowExecutingPath.dirname +/+ "test-helpers.scd").load;
var assert = h[\assert];
var assertClose = h[\assertClose];
var sr = 48000, dur = 3.2;
var hits = [0.5, 1.0, 1.37, 2.1, 2.62];
var path = PathName.tmp +/+ "zzz-take-transients-test.wav";
var name = "zzz-take-transients-test";
var sig, sf, cleanup, cond, result, cached, nearestErr;

"== TakeTransients tests ==".postln;

cleanup = {
	var dir = TakeTransients.dir(name, 0);
	(dir +/+ "*").pathMatch.do(File.delete(_));
	File.exists(dir).if { File.delete(dir) };
};
cleanup.();

// ------------------------------------------------------------ fixture file
sig = Signal.fill((sr * dur).asInteger, { 0.002.rand2 });   // noise floor
hits.do { |t|
	var start = (t * sr).round.asInteger;
	(sr * 0.08).asInteger.do { |i|
		var env = exp(i.neg / (sr * 0.015));
		sig[start + i] = sig[start + i] + (0.8 * env * sin(2pi * 1000 * i / sr));
	}
};
sf = SoundFile.new.headerFormat_("WAV").sampleFormat_("float").numChannels_(1).sampleRate_(sr);
sf.openWrite(path);
sf.writeData(sig);
sf.close;

// ------------------------------------------------------------ pure: pick
result = TakeTransients.pick([
	Signal[0, 0, 1, 0, 0, 0, 1, 0],
	Signal[0, 0.1, 0.5, 0.9, 0.2, 0.3, 0.4, 0.1],
	Signal[0, 0, 0.7, 0.6, 0, 0, 0.3, 0]
], 100, ());
assert.(result.size == 2, "pick: one event per trigger frame");
assertClose.(result[0][\timestamp], 0.02, "pick: frame -> seconds");
assertClose.(result[0][\strength], 0.9, "pick: strength = ODF max within +-2 frames");
assertClose.(result[0][\amp], 0, "pick: amp two frames after the trigger (Amplitude lags)");
result = TakeTransients.pick([
	Signal[0, 1, 1, 1, 0, 0, 1, 1, 0, 1, 0],
	Signal.fill(11, 0.5),
	Signal[0, 0, 0, 0.8, 0, 0, 0, 0, 0.001, 0, 0]
], 100, ());
assert.(result.size == 1, "pick: held triggers count once; a noise-floor hit is dropped (got %)"
	.format(result.collect(_[\timestamp])));

// ------------------------------------------------------ pure: backtrack
result = TakeTransients.backtrack(path, hits.collect { |t| (timestamp: t + 0.009) }, ());
nearestErr = result.collect { |e, i| (e[\timestamp] - hits[i]).abs }.maxItem;
assert.(nearestErr < 0.001, "backtrack: late hits walk back to the attack (max err % ms)"
	.format((nearestErr * 1000).round(0.01)));

// ------------------------------------------------ NRT detect + cache
cond = Condition.new;
fork {
	var fresh;
	TakeTransients.forTake(name, 0, path, { |t| result = t; cond.unhang });
	cond.hang;
	assert.(result.size == hits.size, "detect: one transient per hit (got %: %)"
		.format(result.size, result.collect(_[\timestamp]).round(0.0001)));
	(result.size == hits.size).if {
		nearestErr = result.collect { |e, i| (e[\timestamp] - hits[i]).abs }.maxItem;
		assert.(nearestErr < 0.001, "detect: within 1 ms of the true attacks (max err % ms)"
			.format((nearestErr * 1000).round(0.01)));
	};
	assert.(result.every { |e| e[\strength].notNil and: { e[\strength] > 0 } },
		"detect: every transient has a positive strength");
	assert.(result.collect(_[\timestamp]).differentiate.drop(1).every(_ > 0),
		"detect: time order");

	cached = TakeTransients.forTake(name, 0, path, { |t| fresh = t });
	assert.(cached.notNil and: { fresh.notNil },
		"cache: second call answers synchronously and fires action at once");
	assert.(cached.size == result.size, "cache: same transients");
	assert.(TakeTransients.load(name, 0, path, (thresh: 0.9)).isNil,
		"cache: another parameter set misses");
	assert.(TakeTransients.dir(name, 0).contains("_transients"),
		"cache: lives under _transients/, not _retune/");
	assert.(TakeArchive.versionIds(name, 0).isEmpty,
		"cache: no archive versions created");

	assertClose.(TakeTransients.salienceFor(result).(result.maxItem { |e| e[\strength] }), 1,
		"salienceFor: the strongest hit has salience 1");

	// a non-zero clientID: OfflineProcess targets Server.default's default group,
	// which the NRT server lacks unless detect creates it (it rendered silence)
	Server.default.serverRunning.not.if {
		var savedId = Server.default.clientID, again;
		Server.default.clientID = 1;
		assert.(Server.default.defaultGroup.nodeID != 1, "precondition: clientID 1 moves the default group");
		cond = Condition.new;
		TakeTransients.forTake(name, 0, path, { |t| again = t; cond.unhang }, true);
		cond.hang;
		assert.(again.size == hits.size, "detect as clientID 1: still finds every hit (got %)".format(again.size));
		Server.default.clientID = savedId;
	} {
		"  -- skipped clientID-1 check: this sclang is attached to a running server (clientID %)"
			.format(Server.default.clientID).postln
	};

	cleanup.();
	File.delete(path);
	h[\report].();
	0.exit;
};
)
