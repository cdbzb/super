// Beat-marking controller — the "where are the beats" half of the piano-roll
// editor, lifted out of AbstractMidiEvents.gui (quantize-tempomap-project.md
// §9c step 1, built together with MapEditor as §12c step 5).
//
// It owns the whole marking MODEL and none of the view: the extrapolate / DP
// grid, the current line, the pin set, the hand-picked notes, and the selected
// note indices. It knows nothing about takes, windows, Pen or MIDI — it reads
// only `timestamp` off the note events (plus whatever MIDIBeatTracker's
// salienceFunc asks for), which is exactly why the same controller can sit over
// the MIDI piano roll now and the audio waveform later (§9c step 3): a
// RetuneItem's notes satisfy the same protocol.
//
// Host hooks (all optional, all plain Functions):
//   onChange      { }             the view moved — refresh
//   onGridChange  { }             the GRID moved — drop derived caches, refresh
//   ensureVisible { |time| }      scroll so `time` is on screen
//   onSave        { |selEvent| }  persist a selection Event (abstracts away the
//                                 respondsTo(\takes) dance the 'w' handler used
//                                 to carry inline)
//
// Two hooks rather than one because they cost differently: h/l line navigation
// changes nothing derived (onChange), while a re-pick changes the beat grid that
// the click schedule and the tempo lane are computed from (onGridChange), and
// rebuilding those on every arrow press would re-derive a tempo map per keystroke.
//
// Keys owned (see keyDown): e / E always; h l j k only while a grid is up.
BeatMarkMode {
	var <notes, <>end;
	var <>selectedIndices;
	var <extrapolateMode = false, <dpMode = false;
	var <gridLines, <currentLine = 0;
	var <anchorPair, <manualIndices, <pinSet, <beatTracker;
	var <>onChange, <>onGridChange, <>ensureVisible, <>onSave;

	*new { |notes, end| ^super.new.prInit(notes, end) }
	prInit { |someNotes, endTime|
		notes = someNotes.asArray;
		end = endTime;
		gridLines = [];
		selectedIndices = [];
		^this
	}

	// effective beat time of a grid line: the chosen note's onset, or the line's
	// own extrapolated time; -1 and -2 address the anchor pair (the last two
	// hand-picked notes), which is how rebuildGrid seeds itself at line 0.
	effTime { |i|
		^case
		{ i == -2 } { anchorPair[0] }
		{ i == -1 } { anchorPair[1] }
		{
			gridLines[i][\noteIndex].notNil.if {
				notes[gridLines[i][\noteIndex]].timestamp
			}{
				gridLines[i][\time]
			}
		}
	}

	// recompute every line after lineIdx from the pair (lineIdx-1, lineIdx):
	// constant spacing forward, auto-adopting a note when one falls within a
	// fifth of a beat of the extrapolated time.
	rebuildGrid { |lineIdx = -1|
		var prevT = this.effTime(lineIdx - 1);
		var curT = this.effTime(lineIdx);
		var delta = curT - prevT;
		var tol = delta / 5;
		var t = curT + delta;
		gridLines = gridLines.keep(lineIdx + 1);
		(delta > 0.001).if {
			while { t <= end } {
				var nearIdx, nearDist = inf;
				notes.do { |e, i|
					var d = (e.timestamp - t).abs;
					(d < nearDist).if { nearDist = d; nearIdx = i };
				};
				(nearDist > tol).if { nearIdx = nil };
				gridLines = gridLines.add((time: t, noteIndex: nearIdx));
				t = t + delta;
			}
		};
		^this
	}

	// the selection IS the hand picks plus every note the grid landed on
	updateSelection {
		selectedIndices = manualIndices ++ gridLines.collect { |l| l[\noteIndex] }.reject(_.isNil);
		^this
	}

	// manual ('e') correction: change this line's note, re-extrapolate after it
	applyManualPick { |line, newIdx|
		line[\noteIndex] = newIdx;
		line[\time] = notes[newIdx].timestamp;
		this.rebuildGrid(currentLine);
		this.updateSelection;
		this.prGridChanged;
		("Line %: note % at %".format(currentLine, newIdx, line[\time].round(0.001))).postln;
		^this
	}

	// DP ('E') correction: pin the note as a forced beat and re-run the tracker;
	// earlier lines may also move, since the optimization is global
	repin { |oldIdx, newIdx|
		oldIdx.notNil.if { pinSet.remove(oldIdx) };
		pinSet.add(newIdx);
		beatTracker.pins = pinSet.asArray;
		gridLines = beatTracker.track;
		currentLine = gridLines.detectIndex { |l| l[\noteIndex] == newIdx }
			? currentLine.min(gridLines.size - 1).max(0);
		this.updateSelection;
		ensureVisible !? { ensureVisible.value(notes[newIdx].timestamp) };
		this.prGridChanged;
		("Pinned note % — % lines".format(newIdx, gridLines.size)).postln;
		^this
	}

	// 'e' / 'E': leave the mode when a grid is up, otherwise build one — greedy
	// last-pair extrapolation, or the globally optimal DP tracker.
	toggleMode { |dp = false|
		extrapolateMode.if { ^this.exitMode };
		^dp.if { this.startDP }{ this.startManual }
	}

	exitMode {
		extrapolateMode = false;
		dpMode = false;
		gridLines = [];
		this.prGridChanged;
		("Extrapolate mode off. Selected: " ++ selectedIndices).postln;
		^this
	}

	startManual {
		var sorted;
		(selectedIndices.size < 2).if {
			"Extrapolate mode needs at least 2 selected notes".postln;
			this.prGridChanged;
			^this
		};
		sorted = selectedIndices.copy.sort { |a, b| notes[a].timestamp < notes[b].timestamp };
		manualIndices = sorted;
		anchorPair = sorted.keep(-2).collect { |i| notes[i].timestamp };
		gridLines = [];
		this.rebuildGrid(-1);
		(gridLines.size == 0).if {
			"Extrapolate: could not build grid (pair interval zero or past end)".postln;
			this.prGridChanged;
			^this
		};
		extrapolateMode = true;
		dpMode = false;
		currentLine = 0;
		this.updateSelection;
		ensureVisible !? { ensureVisible.value(gridLines[0][\time]) };
		this.prGridChanged;
		("Extrapolate mode: % lines, beat = %s"
			.format(gridLines.size, (anchorPair[1] - anchorPair[0]).round(0.001))).postln;
		^this
	}

	startDP {
		var sorted;
		(selectedIndices.size < 2).if {
			"Extrapolate mode needs at least 2 selected notes".postln;
			this.prGridChanged;
			^this
		};
		sorted = selectedIndices.copy.sort { |a, b| notes[a].timestamp < notes[b].timestamp };
		manualIndices = sorted;
		anchorPair = sorted.keep(-2).collect { |i| notes[i].timestamp };
		pinSet = Set[];
		beatTracker = MIDIBeatTracker(notes, anchorPair[1] - anchorPair[0], sorted.last);
		gridLines = beatTracker.track;
		(gridLines.size == 0).if {
			"Extrapolate (DP): no beats found after the anchor".postln;
			this.prGridChanged;
			^this
		};
		extrapolateMode = true;
		dpMode = true;
		currentLine = 0;
		this.updateSelection;
		ensureVisible !? { ensureVisible.value(gridLines[0][\time]) };
		this.prGridChanged;
		("Extrapolate (DP): % lines, prior beat = %s"
			.format(gridLines.size, (anchorPair[1] - anchorPair[0]).round(0.001))).postln;
		^this
	}

	prevLine {
		currentLine = (currentLine - 1).max(0);
		ensureVisible !? { ensureVisible.value(gridLines[currentLine][\time]) };
		onChange !? { onChange.value };
		^this
	}

	nextLine {
		currentLine = (currentLine + 1).min(gridLines.size - 1);
		ensureVisible !? { ensureVisible.value(gridLines[currentLine][\time]) };
		onChange !? { onChange.value };
		^this
	}

	// 'j': the note one earlier than the current line's pick (or the last note
	// before the line, when the line is a ghost)
	pickEarlier {
		var line = gridLines[currentLine];
		var idx = line[\noteIndex];
		var newIdx;
		newIdx = idx.notNil.if {
			(idx - 1).max(0)
		}{
			var after = notes.detectIndex { |e| e.timestamp > line[\time] };
			after.isNil.if { notes.size - 1 }{ (after - 1).max(0) }
		};
		dpMode.if { this.repin(idx, newIdx) }{ this.applyManualPick(line, newIdx) };
		^this
	}

	// 'k': the note one later (or the first note after a ghost line)
	pickLater {
		var line = gridLines[currentLine];
		var idx = line[\noteIndex];
		var newIdx;
		newIdx = idx.notNil.if {
			(idx + 1).min(notes.size - 1)
		}{
			notes.detectIndex { |e| e.timestamp > line[\time] } ? (notes.size - 1)
		};
		dpMode.if { this.repin(idx, newIdx) }{ this.applyManualPick(line, newIdx) };
		^this
	}

	// 'r': back to nothing marked. State only — the host posts and refreshes,
	// since it also owns the caches this invalidates.
	clear {
		selectedIndices = [];
		extrapolateMode = false;
		dpMode = false;
		pinSet = nil;
		gridLines = [];
		^this
	}

	// The live grid's beat times, or nil when no grid is up. This is the host's
	// FIRST choice of beat source for clicks / snapping / the tempo lane — what
	// the eye is looking at beats what a saved selection remembers.
	gridTimes {
		^(extrapolateMode and: { gridLines.notNil and: { gridLines.notEmpty } }).if {
			gridLines.collect(_[\time])
		}
	}

	// Resume beat-mark editing from a saved selection. DP saves (anchor + pins)
	// rebuild the tracker — the DP is deterministic given periodPrior/anchor/pins,
	// so the saved grid reappears exactly, editable again (h/l/j/k). Manual ('e')
	// saves rebuild lines from the saved picks: ghost lines are re-interpolated
	// between picks (their extrapolated times were not saved) and trailing empty
	// lines re-extrapolated at the last line spacing.
	//
	// `selectedIndices` must already hold the saved indices — the host loads them
	// (and posts about them) before calling. Answers true when a grid came back.
	resume { |savedSel|
		var restored = false;
		(savedSel.isNil or: { savedSel[\periodPrior].isNil }).if { ^false };
		manualIndices = savedSel[\manual] ?? {
			savedSel[\anchor].notNil.if {
				// older DP saves lack \manual: the hand-picked notes are the ones
				// at or before the anchor (tracking runs strictly forward from it)
				var anchorT = (notes[savedSel[\anchor]] !? _.timestamp) ? inf;
				selectedIndices.select { |i| notes[i].timestamp <= anchorT }
			}{
				// older manual saves: the true manual set is unrecoverable; the
				// first two picks give rebuildGrid a working anchor pair
				selectedIndices.select(_ < notes.size)
					.sort { |a, b| notes[a].timestamp < notes[b].timestamp }.keep(2)
			}
		};
		anchorPair = manualIndices.keep(-2).collect { |i| notes[i].timestamp };
		(savedSel[\anchor].notNil and: { savedSel[\anchor] < notes.size }).if {
			pinSet = Set.newFrom(savedSel[\pins] ? []);
			beatTracker = MIDIBeatTracker(notes, savedSel[\periodPrior],
				savedSel[\anchor], pinSet.asArray);
			gridLines = beatTracker.track;
			dpMode = gridLines.size > 0;
			restored = dpMode;
		}{
			var sorted = selectedIndices.select(_ < notes.size)
				.sort { |a, b| notes[a].timestamp < notes[b].timestamp };
			var cum = [0] ++ (savedSel[\beats] ? []).integrate; // beat coord per sorted note
			var nManual = manualIndices.size.clip(1, sorted.size);
			var prevBeat, prevT, delta, tEx;
			gridLines = [];
			(sorted.size > nManual).if {
				prevBeat = cum[nManual - 1] ? (nManual - 1);
				prevT = notes[sorted[nManual - 1]].timestamp;
				(nManual .. sorted.size - 1).do { |si|
					var idx = sorted[si];
					var b = cum[si] ? (prevBeat + 1);
					var t = notes[idx].timestamp;
					var gap = (b - prevBeat).max(1).asInteger;
					(gap - 1).do { |k|
						gridLines = gridLines.add((
							time: prevT + ((t - prevT) * (k + 1) / gap),
							noteIndex: nil));
					};
					gridLines = gridLines.add((time: t, noteIndex: idx));
					prevBeat = b; prevT = t;
				};
				// trailing empty lines to the end of the take
				delta = (gridLines.size >= 2).if {
					gridLines.last[\time] - gridLines[gridLines.size - 2][\time]
				}{ savedSel[\periodPrior] };
				(delta > 0.001).if {
					tEx = gridLines.last[\time] + delta;
					while { tEx <= end } {
						gridLines = gridLines.add((time: tEx, noteIndex: nil));
						tEx = tEx + delta;
					};
				};
			}{
				// no grid picks saved (all-manual selection): fresh extrapolation
				(anchorPair.size == 2).if { this.rebuildGrid(-1) };
			};
			restored = gridLines.size > 0;
		};
		restored.if {
			extrapolateMode = true;
			currentLine = 0;
			this.updateSelection;
			("Resumed % beat grid: % lines"
				.format(dpMode.if { "DP" }{ "manual" }, gridLines.size)).postln;
		};
		^restored
	}

	// The persisted form of the current marking (the 'w' payload): the selected
	// note indices in time order, plus the beat GAP from each to the next. Hand
	// picks count one beat apiece; grid picks sit at their line index, so a ghost
	// line widens the gap it spans. nil when nothing is selected.
	//
	// `contentStart` is §12B's throat-clearing mark: an explicit one wins,
	// otherwise the first selected note IS the first anchor and therefore the
	// natural content start (which makes quantize's intro drop a no-op).
	selectionEvent { |contentStart|
		var sel, beatPos, sortedSel, positions;
		(selectedIndices.size == 0).if { ^nil };
		beatPos = Dictionary.new;
		extrapolateMode.if {
			manualIndices.do { |idx, i| beatPos[idx] = i };
			gridLines.do { |l, i|
				l[\noteIndex].notNil.if { beatPos[l[\noteIndex]] = manualIndices.size + i }
			};
		};
		sortedSel = selectedIndices.copy.sort { |a, b| notes[a].timestamp < notes[b].timestamp };
		positions = List[];
		sortedSel.do { |idx|
			positions.add( beatPos[idx] ?? { (positions.last ? -1) + 1 } )
		};
		sel = (
			indices: sortedSel,
			beats: positions.asArray.differentiate.drop(1).collect(_.max(1))
		);
		sel[\contentStart] = contentStart ?? { sortedSel.first !? { |i| notes[i].timestamp } };
		extrapolateMode.if {
			sel[\periodPrior] = anchorPair[1] - anchorPair[0];
			sel[\manual] = manualIndices;
		};
		dpMode.if {
			sel[\pins] = pinSet.asArray.sort;
			sel[\anchor] = beatTracker.anchorIndex;
		};
		^sel
	}

	// 'w': build the selection Event and hand it to the host's persistence hook
	// (which knows whether it is looking at a MIDIItem take or a player). Answers
	// the Event, or nil when there was nothing to save.
	save { |contentStart|
		var sel = this.selectionEvent(contentStart);
		sel.isNil.if {
			"nothing selected — not saved".postln;
			^nil
		};
		onSave !? { onSave.value(sel) };
		^sel
	}

	// Standard beat-mark keybindings; answers true when the key was consumed, so
	// the host can fall through to its own switch. e / E always (enter or leave
	// the mode); h l j k only while a grid is up, where they mean line navigation
	// and note picking instead of the host's scroll / take switching.
	keyDown { |char|
		((char == $e) or: { char == $E }).if {
			this.toggleMode(char == $E);
			^true
		};
		extrapolateMode.if {
			^case
			{ char == $h } { this.prevLine; true }
			{ char == $l } { this.nextLine; true }
			{ char == $j } { this.pickEarlier; true }
			{ char == $k } { this.pickLater; true }
			{ false }
		};
		^false
	}

	// ---- view: the mode paints its own grid, the host only lends coordinates.
	// `xOf` maps note-time to pixels, `visible` answers whether a time is on
	// screen, `h` is the roll's pixel height.
	draw { |xOf, visible, h = 1600|
		extrapolateMode.not.if { ^this };
		gridLines.do { |l, i|
			var t = l[\time], x;
			visible.value(t).if {
				x = xOf.value(t);
				Pen.width = (i == currentLine).if { 3 }{ 1 };
				Pen.color = (i == currentLine).if { Color.red(1, 0.9) }{ Color.green(0.5, 0.6) };
				Pen.line(x@0, x@h);
				Pen.stroke;
			};
		};
		Pen.width = 1;
		Pen.stringAtPoint(this.statusString, Point(10, 30),
			Font("Helvetica", 14), Color.red);
		^this
	}

	statusString {
		^"%  line %/%  h/l: move  j/k: %  w: write  e: exit".format(
			dpMode.if { "EXTRAPOLATE (DP)" }{ "EXTRAPOLATE" },
			currentLine + 1, gridLines.size,
			dpMode.if { "pin note" }{ "pick note" })
	}

	prGridChanged {
		onGridChange !? { onGridChange.value };
		onGridChange ?? { onChange !? { onChange.value } };
		^this
	}
}
