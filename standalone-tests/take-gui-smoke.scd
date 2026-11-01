// TakeGui smoke test (audio-beat-marking-plan.md step 5). OPENS A WINDOW for ~10 s:
// builds a fixture take, waits for NRT transient detection, then drives the
// window through its own mouse/key handlers — select two ticks, e, alt-drag a
// free pin, w, m Q W — and checks the marks versions it writes. The NRT render
// runs in its own scsynth; the live server is not needed.
// Run: /Applications/SuperCollider.app/Contents/MacOS/sclang standalone-tests/take-gui-smoke.scd
(
var name = "zzz-takegui-smoke", dir = AudioItem.folder +/+ name, p = dir +/+ "0.wav";
var sig, sf, tg, cleanup, ok = { |c, m| (c.if("  ok - ", "FAIL - ") ++ m).postln };
cleanup = {
	[TakeArchive.dir(name, 0), TakeTransients.dir(name, 0), dir].do { |d|
		(d +/+ "*").pathMatch.do(File.delete(_)); File.exists(d).if { File.delete(d) } }
};
cleanup.();
File.mkdir(dir);
sig = Signal.fill(48000 * 4, { |i| ((i % 24000) < 600).if { 0.7 * sin(i * 0.13) * exp((i % 24000).neg / 300) } { 0.001.rand2 } });
sf = SoundFile.new.headerFormat_("WAV").sampleFormat_("float").numChannels_(1).sampleRate_(48000);
sf.openWrite(p); sf.writeData(sig); sf.close;
fork {
	tg = Take(name, 0).gui;
	8.wait;   // NRT detection + window
	{
		ok.(tg.transients.size == 8, "TakeGui: transients arrived (%)".format(tg.transients.size));
		// select two ticks by clicking them, then e
		tg.prMouseDown(tg.nav.xOf(tg.transients[0][\timestamp]), 300, 0, 0, 1);
		tg.prMouseDown(tg.nav.xOf(tg.transients[1][\timestamp]), 300, 0, 0, 1);
		ok.(tg.beatMark.selectedIndices.size == 2, "TakeGui: click selects ticks");
		tg.prKey($e);
		ok.(tg.beatMark.extrapolateMode, "TakeGui: e builds a grid");
		ok.(tg.beatTimes.size >= 8, "TakeGui: beatTimes from the grid (%)".format(tg.beatTimes.size));
		// drag line 2 off-note with alt -> free pin
		tg.prMouseDown(tg.nav.xOf(tg.beatMark.gridLines[2][\time]), 300, 0, 0, 1);
		tg.prMouseUp(tg.nav.xOf(tg.beatMark.gridLines[2][\time] + 0.05), 300, 524288);
		ok.(tg.beatMark.gridLines[2][\pinned] == true, "TakeGui: alt-drag makes a free pin");
		// keyboard nudge of the current line: one pixel, only that line
		{ var l3 = tg.beatMark.gridLines[3][\time], l4 = tg.beatMark.gridLines[4][\time];
			while { tg.beatMark.currentLine < 3 } { tg.beatMark.nextLine };
			tg.prKey($]);
			ok.((tg.beatMark.gridLines[3][\time] - l3 - tg.nudgeStep).abs < 1e-9,
				"TakeGui: ] nudges the current line one pixel");
			ok.(tg.beatMark.gridLines[4][\time] == l4, "TakeGui: ] leaves the next line alone");
		}.value;
		tg.prKey($w);
		ok.(TakeArchive.loadMarks(name, 0).notNil, "TakeGui: w writes a marks version");
		ok.(Take(name, 0).tempoMap.notNil, "TakeGui: take.tempoMap reads it back");
		tg.prKey($m); tg.prKey($Q); tg.prKey($W);
		ok.(TakeArchive.loadMarks(name, 0)[\edited] == true, "TakeGui: m Q W saves an edited map");
		// transient hand edits, no grid up
		tg.prKey($m); tg.prKey($e); tg.prKey($r);
		{ var t3 = tg.transients[3][\timestamp], n = tg.transients.size, mid;
			tg.prMouseDown(tg.nav.xOf(t3), 300, 0, 0, 1);
			tg.prKey($}); tg.prKey($});
			ok.((tg.transients[3][\timestamp] - t3 - (2 * tg.nudgeStep(true))).abs < 1e-9,
				"TakeGui: } nudges the picked transient ten pixels");
			ok.(TakeTransients.loadEdits(name, 0).size == 1, "TakeGui: nudges saved as one hand edit");
			ok.((TakeTransients.load(name, 0, tg.path)[3][\timestamp] - tg.transients[3][\timestamp]).abs < 1e-9,
				"TakeGui: TakeTransients.load applies the edit");
			mid = (tg.transients[4][\timestamp] + tg.transients[5][\timestamp]) / 2;
			tg.prMouseDown(tg.nav.xOf(mid), 300, 0, 0, 1);
			tg.prKey($a);
			ok.(tg.transients.size == (n + 1) and: { tg.beatMark.selectedIndices == [5] },
				"TakeGui: a adds a picked transient at the cursor");
			tg.prKey($x);
			ok.(tg.transients.size == n, "TakeGui: x deletes the picked transient");
			ok.(TakeTransients.loadEdits(name, 0).size == 1, "TakeGui: add then delete leaves no edit");
		}.value;
		tg.prKey($t); tg.prKey($t);
		tg.prKey($?);
		ok.(Window.allWindows.any { |w| w.name == "Take Window Help" }, "TakeGui: ? opens the help window");
		Window.allWindows.do { |w| (w.name == "Take Window Help").if { w.close } };
		tg.refresh;
	}.defer;
	2.wait;
	{ tg.prKey($q) }.defer;
	1.wait;
	"== smoke done ==".postln;
	cleanup.();
	Server.all.do { |sv| sv.sendQuit = false };
	0.exit;
};
)
