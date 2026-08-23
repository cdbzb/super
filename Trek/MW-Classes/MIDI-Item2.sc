MIDIItem2 : MIDIItem{
	*new { |...args|
		^MIDIItem(*args)
	}
	*value{ |func|
		^MIDIItemPlayer(this.midiEvents, this).copyBounds(this)
	}
}
AbstractMidiEvents { // class for MIDIItem and MIDIItemPlayer
// §12c step 5: this method is now a HOST, not a monolith. Two controllers do the
// editing work and this gui only lends them a window, a transport and pixels:
//
//   beatMark (BeatMarkMode) — "where are the beats": the extrapolate/DP grid, the
//     current line, the pin set, the hand picks, and THE selection
//     (`beatMark.selectedIndices` is the one copy; there is no gui-local mirror).
//   mapEd (MapEditor) — "what should the tempo be": the tempo lane, plus an
//     immutable AnchorMap over it with an undo stack and the §12b A span algebra.
//
// Both are media-agnostic (they touch `timestamp` and seconds and nothing else),
// which is the point: the audio editor of §9c step 3 rehosts them instead of
// growing a third copy of this code.
gui { |take|
    var notes, start, end, width, height, window, view;
    var startMidiNote = 36; // Starting MIDI note for display range
    var viewStart, viewEnd, zoomFactor = 1; // Horizontal view and zoom variables
    var ensureLineVisible;
    var savedSel;
    var cursorTime, playClock, isPlaying = false, playhead, playStartWall, playOriginTime, activeMks = [];
    var viewedPlayer, playFrom, stopPlay, togglePlay;
    var clickEnabled = false, clickClock, scheduleClicks, currentNoteTime;
    var contentStart; // §12B: "content starts here" — everything before it is throat clearing
    var countInBeats = 0, clickTimes, beatGrid, localPeriod; // §12C: clicks/snap/count-in
    var beatMark, mapEd, laneSource, invalidateLane;

    this.respondsTo(\takes).if{
        take = take ? (this.takes.size - 1);
        (take < 0).if { take = this.takes.size + take };
        notes = this.take(take).notes;
        savedSel = this.selections(take) !? _.last;
    }{
        notes = this.notes;
        take = 0;
        savedSel = this.tryPerform(\currentSelection);
    };

    start = notes[0].timestamp;
    end = notes.last.timestamp + (notes.last.sustain ? 0);
    width = 1400;
    height = 800;

    beatMark = BeatMarkMode(notes, end);
    mapEd = MapEditor.new;

    savedSel.notNil.if {
        beatMark.selectedIndices = (savedSel[\indices] ? []).copy;
        ("Loaded saved selection: % notes".format(beatMark.selectedIndices.size)).postln;
        // §12B: restore the content start, so reopening the gui doesn't put the
        // cursor back on the junk intro this selection already decided to ignore
        contentStart = savedSel[\contentStart];
        contentStart !? { ("Content starts at " ++ contentStart.round(0.001)).postln };
    };

    // Initialize horizontal view
    viewStart = start;
    viewEnd = end;

    // Playback cursor / transport
    cursorTime = contentStart ? start;   // cursor begins at the content, not at the junk intro
    playhead = cursorTime;
    playClock = TempoClock(1, queueSize: 1024); // dedicated so stop can .clear cleanly
    clickClock = TempoClock(1, queueSize: 1024); // beat clicks, cleared independently of notes

    // the player whose notes are on screen (the viewed take, or this)
    viewedPlayer = {
        this.respondsTo(\takes).if { this.take(take) }{ this.player }
    };

    // note-time at the cursor right now (un-clamped, no latency offset) — for scheduling
    currentNoteTime = { playOriginTime + (SystemClock.seconds - playStartWall) };

    // §12C: the click grid, in note-time. Priority: the live extrapolate/DP grid
    // (what the eye sees), else every beat of the loaded selection's tempomap — so a
    // selection reloaded WITHOUT tracker state (plain \selBeat markers, no gridLines)
    // still clicks, snaps and counts in. Memoized: the saved selection can only
    // change through 'w', which clears the memo.
    clickTimes = {
        beatMark.gridTimes ?? {
            beatGrid ?? {
                var p = viewedPlayer.();
                // take() hands back an unmarked player — stamp the selection we loaded
                (p.selectedNotes.isEmpty and: { (savedSel !? (_[\indices])).notNil }).if {
                    p.prStampSelection(savedSel)
                };
                beatGrid = p.beatTimes
            }
        }
    };

    // §12D: the beat grid the tempo lane / MapEditor read their map off — the SAME
    // source the clicks use (live extrapolate/DP grid first, else the loaded
    // selection's tempomap), answered as [times, subdiv]. MapEditor calls this
    // lazily and memoizes, so the mutation sites only have to invalidate.
    laneSource = {
        var times, sub = 1, p;
        times = beatMark.gridTimes;
        times.isNil.if {
            p = viewedPlayer.();
            (p.selectedNotes.isEmpty and: { (savedSel !? (_[\indices])).notNil }).if {
                p.prStampSelection(savedSel)
            };
            times = p.beatTimes;
            // a curved map's slope varies WITHIN the beat: sample finer so the
            // staircase reads as the curve it is
            (times.size > 1 and: {
                (p.tryPerform(\tempomap) !? { |tm| tm.tryPerform(\curved) }) == true
            }).if {
                sub = 4;
                times = p.beatTimes(sub);
            };
        };
        [times, sub]
    };
    mapEd.sourceFunc = laneSource;

    // an edited map is NOT dropped by this (MapEditor.invalidate keeps it) — only
    // an untouched lane re-reads its source
    invalidateLane = { mapEd.invalidate };

    // grid spacing at (or just after) note-time `t` — the count-in's beat length.
    // nil when there is no usable grid.
    localPeriod = { |times, t|
        var i, period;
        (times.size >= 2).if {
            i = (times.detectIndex { |gt| gt >= (t - 1e-9) } ? (times.size - 1))
                .clip(0, times.size - 1);
            period = (i < (times.size - 1)).if {
                times[i + 1] - times[i]
            }{
                times[i] - times[i - 1]
            };
        };
        (period.notNil and: { period > 0.001 }).if { period };
    };

    // schedule a hihat click at every grid time from `fromTime` forward, on clickClock,
    // shifted `delay` seconds later (the count-in). (instrument:\hihat).play bundles
    // with Server latency, matching the note playback.
    scheduleClicks = { |fromTime, delay = 0, clear = true|
        clear.if { clickClock.clear };
        clickTimes.().do { |gt|
            (gt >= fromTime).if {
                clickClock.sched(delay + (gt - fromTime), { (instrument: \hihat).play; nil })
            }
        }
    };

    // start playback from the cursor; tracks which MicroKeys we started so stop can release them
    playFrom = { |t|
        var p, before, latency, times, period, offset = 0, startNotes;
        isPlaying.if { stopPlay.() };
        times = clickTimes.();
        // §12C count-in: N clicks at the LOCAL beat length before the notes start
        (countInBeats > 0).if {
            period = localPeriod.(times, t);
            period.isNil.if {
                "count-in: no beat grid — starting immediately".postln
            }{
                offset = countInBeats * period
            }
        };
        p = viewedPlayer.();
        p.start = t; p.end = end;
        before = MIDIItemPlayer.playing.copy;
        playClock.clear;
        clickClock.clear;
        startNotes = {
            p.play(clock: playClock);
            activeMks = (MIDIItemPlayer.playing - before).asArray; // the voices we just launched
        };
        isPlaying = true;
        latency = Server.default.latency ? 0; // notes sound this far after they're scheduled
        // note-time epoch: the count-in happens BEFORE it, so the playhead sits still
        // (see the .max(t) clamp below) until the music actually starts
        playStartWall = SystemClock.seconds + offset;
        playOriginTime = t;
        // count-in clicks sound whether or not clicks are enabled during playback —
        // a count-in without clicks is nothing. Same event form as the notes, so they
        // bundle with the server latency identically.
        (offset > 0).if {
            countInBeats.do { |i|
                clickClock.sched(i * period, {
                    (instrument: \hihat, amp: (i == 0).if { 0.2 }{ 0.1 }).play; nil
                })
            }
        };
        (clickEnabled and: { times.size > 0 }).if {
            scheduleClicks.(t, offset, false)   // count-in clicks are already queued
        };
        (offset > 0).if {
            playClock.sched(offset, { isPlaying.if { startNotes.() }; nil })
        }{
            startNotes.()
        };
        playhead = t;
        Routine({
            while { isPlaying and: { playhead <= end } } {
                // offset by server latency so the playhead tracks the audio, not the scheduling;
                // clamp to the cursor while the first bundle is still in the latency window
                playhead = (t + (SystemClock.seconds - playStartWall - latency)).max(t);
                view.refresh;
                (1/30).wait;
            };
            isPlaying.if { stopPlay.() }; // reached the end on its own
        }).play(AppClock);
    };

    stopPlay = {
        isPlaying = false;
        playClock.clear;
        clickClock.clear;
        activeMks.do { |mk|
            mk.sounding.copy.do(_.release); // release any voices still ringing
            mk.restoreCCValues;
            MIDIItemPlayer.playing.remove(mk);
        };
        activeMks = [];
        view.refresh;
    };

    // §12B: playback never starts inside the ignored intro — the cursor itself is
    // left alone (alt-click may still point anywhere), only the play origin clamps.
    // §12C: playFrom takes the CLAMPED origin, so the count-in counts into the
    // content start, not into the cursor's position inside the junk.
    togglePlay = {
        var t = cursorTime;
        isPlaying.if { stopPlay.() }{
            (contentStart.notNil and: { t < contentStart }).if { t = contentStart };
            playFrom.(t)
        }
    };

    // The one view-shaped helper that stays here: only the host knows about the
    // horizontal window. Handed to beatMark as its ensureVisible hook below.
    ensureLineVisible = { |t|
        var duration = viewEnd - viewStart;
        (t < viewStart or: (t > viewEnd)).if {
            viewStart = (t - (duration / 2)).max(start);
            viewEnd = viewStart + duration;
            (viewEnd > end).if {
                viewEnd = end;
                viewStart = (end - duration).max(start);
            };
        };
    };

    // Resume beat-mark editing from a saved selection — DP saves rebuild the
    // tracker exactly, manual saves re-interpolate their ghost lines
    // (BeatMarkMode.resume). Model-only and it posts what it found, so it is safe
    // before the window exists.
    beatMark.resume(savedSel);

    // Create a window and UserView
    window = Window("Piano Roll", Rect(100, 100, width, height)).front;
    window.onClose_({ isPlaying.if { stopPlay.() }; playClock.stop; clickClock.stop }); // don't leak the transport clocks
    view = UserView(window, Rect(0, 0, width, 1600))
    .background_(Color.white);
    
    // ---- controller hooks. The gui keeps the window, the transport and the
    // pixels; the two controllers keep the model and ask for these back.
    // onChange vs onGridChange: line navigation only needs a redraw, while a
    // re-pick changes the beat grid that the click schedule and the tempo lane
    // are derived from, and re-deriving a tempo map per arrow press is what the
    // split avoids.
    beatMark.onChange = { view.refresh };
    beatMark.onGridChange = { invalidateLane.(); view.refresh };
    beatMark.ensureVisible = ensureLineVisible;
    // the respondsTo(\takes) dance the 'w' handler used to carry inline
    beatMark.onSave = { |sel|
        this.respondsTo(\takes).if {
            this.addSelection(take, sel)
        }{
            this.tryPerform(\takeIndex).notNil.if {
                this.source.addSelection(this.takeIndex, sel)
            }{
                "no take context — open the gui from a MIDIItem (or via .take) to save selections".postln
            }
        }
    };
    mapEd.onChange = { view.refresh };
    // audition (§12b D phase 2): click through the CANDIDATE map before
    // committing, on the click clock, same event form as the count-in
    mapEd.audition = { |times|
        var t0 = times.first;
        clickClock.clear;
        times.do { |t, i|
            clickClock.sched(t - t0, {
                (instrument: \hihat, amp: (i == 0).if { 0.2 }{ 0.1 }).play; nil
            })
        };
    };

    // Define the keyboard actions. Order: beatMark first (it owns e/E always and
    // h l j k while a grid is up), then mapEd (m always, its edit keys while map
    // edit is on), then this gui's own switch — each answers whether it consumed
    // the key, so nothing is handled twice.
view.keyDownAction_({ |view char|
    var handled = beatMark.keyDown(char);

    handled.not.if { handled = mapEd.keyDown(char, cursorTime) };

    handled.not.if {
    switch (char,
        $ , {togglePlay.()}, // space: toggle play/stop from the cursor
        $c, { // toggle hihat clicks on the beat grid
            var now;
            clickEnabled = clickEnabled.not;
            clickEnabled.if {
                isPlaying.if { // catch up mid-playback (during a count-in: from its end)
                    now = currentNoteTime.();
                    scheduleClicks.(now.max(playOriginTime), (playOriginTime - now).max(0))
                };
            }{
                clickClock.clear; // drop any pending clicks
            };
            ("Beat clicks " ++ clickEnabled.if("on", "off")
                ++ ((clickEnabled and: { clickTimes.().isEmpty }).if {
                    " (no beat grid — select notes, or e/E)" }{ "" })).postln;
        },
        $C, { // §12C: count-in before playback — 0 / 2 / 4 beats
            countInBeats = (countInBeats + 2) % 6;
            ("Count-in " ++ (countInBeats == 0).if { "off" }{
                countInBeats.asString ++ " beats" }).postln;
        },
        $q, {window.close; "open -a WezTerm.app".unixCmd},
        $0, {window.close; this.gui(0)},
        $1, {window.close; this.gui(1)},
        $2, {window.close; this.gui(2)},
        $j, {window.close; take = take - 1; this.gui(take: take)},
        $k, {window.close; take = take + 1; this.gui(take: take)},
        $J, {startMidiNote = (startMidiNote - 12).max(0); view.refresh; ("Scrolled down to MIDI note " ++ startMidiNote).postln}, 
        $K, {startMidiNote = (startMidiNote + 12).min(115); view.refresh; ("Scrolled up to MIDI note " ++ startMidiNote).postln}, 
        $h, { // Scroll left - FIXED
            var duration, scrollAmount, newViewStart, newViewEnd;
            duration = viewEnd - viewStart;
            scrollAmount = duration * 0.1;
            newViewStart = viewStart - scrollAmount;
            newViewEnd = viewEnd - scrollAmount;
            
            // Ensure we don't scroll past the beginning
            if(newViewStart < start) {
                newViewStart = start;
                newViewEnd = start + duration;
            };
            
            viewStart = newViewStart;
            viewEnd = newViewEnd;
            view.refresh;
            ("Scrolled left to " ++ viewStart.round(0.01)).postln;
        },
        $l, { // Scroll right - FIXED
            var duration, scrollAmount, newViewStart, newViewEnd;
            duration = viewEnd - viewStart;
            scrollAmount = duration * 0.1;
            newViewStart = viewStart + scrollAmount;
            newViewEnd = viewEnd + scrollAmount;
            
            // Ensure we don't scroll past the end
            if(newViewEnd > end) {
                newViewEnd = end;
                newViewStart = end - duration;
            };
            
            viewStart = newViewStart;
            viewEnd = newViewEnd;
            view.refresh;
            ("Scrolled right to " ++ viewStart.round(0.01)).postln;
        },
        $H, { // Zoom out horizontally - FIXED (anchored to left)
            var newDuration, newViewStart, newViewEnd;
            newDuration = (viewEnd - viewStart) * 1.2;
            newViewStart = viewStart; // Keep left boundary fixed
            newViewEnd = viewStart + newDuration;
            
            // Constrain to the bounds of the actual data
            if(newViewStart < start) {
                newViewStart = start;
                newViewEnd = start + newDuration;
            };
            if(newViewEnd > end) {
                newViewEnd = end;
                // Only adjust start if we hit the right boundary
                newViewStart = (end - newDuration).max(start);
            };
            
            viewStart = newViewStart;
            viewEnd = newViewEnd;
            view.refresh;
            ("Zoomed out, duration: " ++ (viewEnd - viewStart).round(0.01)).postln;
        },
        $L, { // Zoom in horizontally - FIXED (anchored to left)
            var newDuration, minDuration, newViewStart, newViewEnd;
            newDuration = (viewEnd - viewStart) * 0.8;
            minDuration = 0.1; // Minimum zoom level
            
            // Ensure minimum duration
            if(newDuration < minDuration) {
                newDuration = minDuration;
            };
            
            newViewStart = viewStart; // Keep left boundary fixed
            newViewEnd = viewStart + newDuration;
            
            // Ensure we stay within bounds
            if(newViewStart < start) {
                newViewStart = start;
                newViewEnd = start + newDuration;
            };
            if(newViewEnd > end) {
                newViewEnd = end;
                // Only adjust start if we hit the right boundary
                newViewStart = (end - newDuration).max(start);
            };
            
            viewStart = newViewStart;
            viewEnd = newViewEnd;
            view.refresh;
            ("Zoomed in, duration: " ++ newDuration.round(0.01)).postln;
        },
        $r, {beatMark.clear; invalidateLane.(); view.refresh; "Selection cleared".postln},
        $t, {mapEd.toggleLane}, // §12D: toggle the tempo lane
        $g, {("Selected note indices: " ++ beatMark.selectedIndices).postln;
             beatMark.selectedIndices},
        $x, { // §12B: mark the cursor as the content start — everything left of it
              // is throat clearing, dimmed here and dropped by quantize/fromSelection
            contentStart = cursorTime;
            view.refresh;
            ("Content starts at " ++ contentStart.round(0.001) ++ " — 'w' to save").postln;
        },
        $X, { // un-mark: the whole take is content again
            contentStart = nil;
            view.refresh;
            "Content start cleared".postln;
        },
        $w, { // persist selection — immutable, appends a new version if changed.
              // BeatMarkMode builds the Event (indices + beat gaps + tracker
              // state) and the onSave hook above knows where to put it.
            beatMark.save(contentStart) !? { |sel|
                // §12C: the click grid follows the selection just saved
                savedSel = sel;
                beatGrid = nil;
                invalidateLane.();
            }
        },
        $?, {
            // Show help menu
            var helpWindow = Window("Piano Roll Help", Rect(200, 200, 460, 760)).front;
            var helpText = StaticText(helpWindow, Rect(10, 10, 440, 740))
                .string_("Piano Roll Keyboard Shortcuts:\n\n" ++
                    "q - Close window and open WezTerm\n" ++
                    "0, 1, 2 - Switch to take 0, 1, or 2\n" ++
                    "j - Previous take\n" ++
                    "k - Next take\n" ++
                    "J - Scroll down one octave\n" ++
                    "K - Scroll up one octave\n" ++
                    "h/l - Scroll horizontally left/right\n" ++
                    "H/L - Zoom out/in horizontally\n" ++
                    "r - Clear note selection\n" ++
                    "g - Get selected note indices\n" ++
                    "x - Mark content start at the cursor (intro before it is dimmed,\n" ++
                    "      dropped by quantize/fromSelection, and skipped by playback)\n" ++
                    "X - Clear the content start\n" ++
                    "w - Save selection to the MIDIItem (immutable, new version per change)\n" ++
                    "space - Play/stop from the cursor\n" ++
                    "c - Toggle hihat clicks on the beat grid (the e/E grid if one is up,\n" ++
                    "      otherwise every beat of the loaded selection's tempo map)\n" ++
                    "C - Count-in before playback: cycles 0 / 2 / 4 beats (clicks at the\n" ++
                    "      local beat length; sounds even when 'c' clicks are off)\n" ++
                    "t - Toggle the tempo lane (bpm step line over the beat grid, mean\n" ++
                    "      bpm dashed; hidden when there is no grid and no selection)\n" ++
                    "e - Toggle extrapolate mode (tempo grid from last 2 selected notes)\n" ++
                    "E - Same, but DP beat tracker (globally optimal; j/k pin notes)\n" ++
                    "      h/l - previous/next grid line\n" ++
                    "      j/k - pick earlier/later note at current line (re-extrapolates)\n" ++
                    "m - Toggle MAP EDIT mode (edits the tempo map in the lane; the keys\n" ++
                    "      below act only while it is on — everything else is unchanged)\n" ++
                    "      i/o - span start/end at the cursor; drag across the lane also\n" ++
                    "      A   - select the whole map (the default span)\n" ++
                    "      Q   - straighten the span to one constant tempo (quantize)\n" ++
                    "      V   - curve the span (monotone cubic through its anchors)\n" ++
                    "      N   - clump: keep every 2nd anchor in the span\n" ++
                    "      S/F - slower/faster: stretch the span's time by ±5%\n" ++
                    "      B   - set the span to the grid's mean bpm\n" ++
                    "      P   - audition: click through the candidate map\n" ++
                    "      u/U - undo/redo    Z - back to the loaded map\n" ++
                    "      W   - commit: MapEditor.last, for warpTo / sourceTempoMap:\n" ++
                    "? - Show this help menu\n\n" ++
                    "Mouse:\n" ++
                    "Click notes to select/deselect them\n" ++
                    "Alt-click to place the playback cursor (snaps to the nearest beat)\n" ++
                    "Shift-alt-click to place it freely (no snap)\n" ++
                    "In map edit mode, drag across the tempo lane to select a beat span\n" ++
                    "Selected notes appear in red\n\n" ++
                    "Visual Guide:\n" ++
                    "Gray shading = Black keys\n" ++
                    "C note labels on left side\n" ++
                    "MIDI note range: 36-127 (scrollable)")
                .font_(Font("Helvetica", 12))
                .align_(\left);
            helpWindow.onClose_({helpWindow = nil});
        }
    )
    };
});

    // Add mouse click handling
    view.mouseDownAction_({ |view, x, y, mod|
        var noteRange = 92; // Display 92 notes at a time
        var noteHeight = 1600 / noteRange;
        var timeScale = width / (viewEnd - viewStart);
        var clickedNoteIndex = nil;
        var altDown = (mod bitAnd: 524288) > 0; // 0x80000 = alt/option
        var shiftDown = (mod bitAnd: 131072) > 0; // 0x20000 = shift
        // §12b D phase 2: a plain click inside the tempo-lane strip, in map-edit
        // mode, starts a beat-span drag. Checked FIRST and only consumed there,
        // so with the mode off (the default) the lane is inert and every click
        // behaves exactly as before.
        var onLane = altDown.not and: {
            mapEd.mouseDown(x, y, viewStart, viewEnd, width)
        };

        // alt-click: place the playback cursor at the clicked time (skip note selection).
        // §12C: snap to the NEAREST click-grid time when a grid exists, so playback
        // starts on a beat; shift-alt-click places the cursor freely.
        altDown.if {
            var t = (viewStart + (x / timeScale)).clip(start, end);
            var times = shiftDown.if { [] }{ clickTimes.() };
            var best;
            (times.size > 0).if {
                best = 0;
                times.do { |gt, i| ((gt - t).abs < (times[best] - t).abs).if { best = i } };
                t = times[best];
            };
            cursorTime = t;
            isPlaying.not.if { playhead = cursorTime };
            view.refresh;
            ("Cursor at " ++ cursorTime.round(0.001)
                ++ (best.notNil.if { " (beat %)".format(best) }{ "" })).postln;
        };

        // Check if click is on a note
        (altDown.not and: { onLane.not }).if {
        notes.do { |e, idx|
            var noteY = height - ((e.midinote - startMidiNote) * noteHeight);
            var noteX = (e.timestamp - viewStart) * timeScale;
            var noteWidth = (e.sustain ? 100) * timeScale;
            var noteRect = Rect(noteX, noteY, noteWidth, noteHeight);
            
            // Check if click is within note rectangle
            if(noteRect.contains(Point(x, y))) {
                clickedNoteIndex = idx;
            };
        };
        
        // If we found a note, toggle its selection
        if(clickedNoteIndex.notNil) {
            if(beatMark.selectedIndices.includes(clickedNoteIndex)) {
                beatMark.selectedIndices.remove(clickedNoteIndex);
                ("Note " ++ clickedNoteIndex ++ " deselected").postln;
            } {
                beatMark.selectedIndices = beatMark.selectedIndices.add(clickedNoteIndex);
                ("Note " ++ clickedNoteIndex ++ " selected").postln;
            };
            view.refresh;
        };
        }; // end altDown.not
    });

    // the drag half of the lane's span selection — inert unless mouseDown
    // started one, so ordinary note clicking never sees these
    view.mouseMoveAction_({ |view, x, y| mapEd.mouseMove(x, y, viewStart, viewEnd, width) });
    view.mouseUpAction_({ |view, x, y| mapEd.mouseUp });

    // Define the drawing function
    view.drawFunc = {
        var noteRange = 92; // MIDI notes 36-127 (92 notes total)
        var noteHeight = 1600 / noteRange; // Height of each note row
        var timeScale = width / (viewEnd - viewStart); // Pixels per second
        var isBlackKey = { |midiNote|
            var noteInOctave = midiNote % 12;
            [1, 3, 6, 8, 10].includes(noteInOctave); // C#, D#, F#, G#, A#
        };
        var midiNoteToName = { |midiNote|
            var noteNames = ["c", "c#", "d", "d#", "e", "f", "f#", "g", "g#", "a", "a#", "b"];
            var octave = (midiNote / 12).floor;
            var noteIndex = midiNote % 12;
            noteNames[noteIndex] ++ octave.asString;
        };
        
        // Draw black key shading first
        noteRange.do { |i| // Display noteRange notes starting from startMidiNote
            var midiNote = i + startMidiNote;
            var y = height - (i * noteHeight); // Invert Y coordinate
            if(isBlackKey.(midiNote)) {
                Pen.color = Color.gray(0.9);
                Pen.addRect(Rect(0, y, width, noteHeight));
                Pen.fill;
            };
        };
        
        // Draw the piano roll grid
        Pen.color = Color.gray(0.8);
        noteRange.do { |i| // Display noteRange notes starting from startMidiNote
            var y = height - (i * noteHeight); // Invert Y coordinate
            Pen.line(0@y, width@y);
        };
        Pen.stroke;

        // §12D phase 1: the tempo lane, drawn BEFORE the notes so it can never
        // occlude them. MapEditor owns it now (model, memoization and Pen work);
        // this gui only says where the visible time window is.
        mapEd.drawLane(viewStart, viewEnd, width);

        // Draw the notes
        notes.do { |e, num|
            var noteRange = 92; // Display 92 notes at a time
            var noteHeight = 1600 / noteRange;
            var y = height - ((e.midinote - startMidiNote) * noteHeight);
            var x = (e.timestamp - viewStart) * timeScale;
            var noteWidth = (e.sustain ? 100) * timeScale;
            
            // Only draw notes that are within the visible range (both vertical and horizontal)
            if(e.midinote >= startMidiNote and: (e.midinote < (startMidiNote + noteRange)) and:
               (e.timestamp >= viewStart) and: (e.timestamp <= viewEnd)) {
                // Change color if selected
                if(beatMark.selectedIndices.includes(num)) {
                    Pen.color = Color.red(e.amp); // Selected notes are red
                } {
                    Pen.color = Color.blue(e.amp); // Normal notes are blue
                };
                
                Pen.addRect(Rect(x, y, noteWidth, noteHeight));
                Pen.fill;
                
                Pen.color = Color.black;
                Pen.stringAtPoint(
                    num.asString,
                    Point(x, y - 15),
                    Font.default,
                    Color.black
                );
            };
        };
        
        // §12B: dim the throat-clearing intro (drawn OVER the notes, so the ignored
        // ones read as greyed out), with a hard line at the content start itself
        (contentStart.notNil and: { contentStart > viewStart }).if {
            var cx = (contentStart.min(viewEnd) - viewStart) * timeScale;
            Pen.color = Color.gray(0.5, 0.4);
            Pen.addRect(Rect(0, 0, cx, 1600));
            Pen.fill;
            Pen.width = 2;
            Pen.color = Color.gray(0.15, 0.9);
            Pen.line(cx@0, cx@1600);
            Pen.stroke;
            Pen.width = 1;
        };

        // Extrapolate-mode grid lines + status: BeatMarkMode paints them, this gui
        // only lends it the two coordinate closures and the roll's height.
        beatMark.draw(
            { |t| (t - viewStart) * timeScale },
            { |t| (t >= viewStart) and: { t <= viewEnd } },
            1600);

        // §12b D phase 2: the map editor's span highlight + status, on TOP of the
        // notes. A no-op unless map-edit mode is on, so the gui is pixel-for-pixel
        // what it was whenever the mode is off.
        mapEd.drawEditOverlay(viewStart, viewEnd, width, 1600);

        // Draw the playback cursor (blue) and, while playing, the moving playhead (orange)
        (cursorTime >= viewStart and: { cursorTime <= viewEnd }).if {
            var cx = (cursorTime - viewStart) * timeScale;
            Pen.width = 2; Pen.color = Color.blue(1, 0.7);
            Pen.line(cx@0, cx@1600); Pen.stroke;
        };
        (isPlaying and: { playhead >= viewStart and: { playhead <= viewEnd } }).if {
            var px = (playhead - viewStart) * timeScale;
            Pen.width = 2; Pen.color = Color(1, 0.5, 0);
            Pen.line(px@0, px@1600); Pen.stroke;
        };
        Pen.width = 1;

        // Display take number
        Pen.stringAtPoint(
            take.asString,
            Point(120, 120),
            Font("Helvetica", 48),
            Color(0, 0, 0, 0.5)
        );
        
        // Draw note name labels on the left
        Pen.color = Color.black;
        noteRange.do { |i|
            var midiNote = i + startMidiNote;
            var y = height - (i * noteHeight); // Invert Y coordinate
            var noteName = midiNoteToName.(midiNote);
            // Only draw labels for C notes and every 12 notes to avoid clutter
            if(midiNote % 12 == 0) {
                Pen.stringAtPoint(
                    noteName,
                    Point(5, y + (noteHeight / 2) - 6),
                    Font("Helvetica", 10),
                    Color.black
                );
            };
        };
        
        // Display selection instructions
        Pen.stringAtPoint(
            "space play/stop · 'c' beat clicks · 't' tempo lane · alt-click cursor · 'r' reset · 'g' indices · 'e' extrapolate · 'E' DP beat tracker",
            Point(10, 10),
            Font("Helvetica", 14),
            Color.black
        );
    };
    
    // Refresh the view
    view.refresh;
    
    // Return a function that gives access to the selected indices (the selection
    // lives on the controller now, so this reads through it and stays live)
    ^{ beatMark.selectedIndices };
}
	noteOns {
		^MIDIItemPlayer(
			this.midiEvents.select{|e| e.midicmd == \noteOn},
			this.source
		).copyBounds(this)
	}
	dur {
		^this.midiEvents.collect(_.dur).select(_.notNil).sum
	}
	splitVoices { |maxJump=5 numVoices=2|
		^this.noteOns.midiEvents
		.separate{|i j| (j.midinote - i.midinote).abs > maxJump}
		=> _.clump(numVoices)
		=> _.flop
		=> _.collect(_.flat)
		// => _.sort{|e f| e.collect(_.midinote).mean > f.collect(_.midinote).mean}
	}
	doesNotUnderstand{|selector ...args, kwargs|
        // for collect - reject - select - drop
		this.midiEvents.respondsTo(selector).if{
			^MIDIItemPlayer(
				this.midiEvents.deepCopy.performArgs(selector, args, kwargs ? #[]),
				this.source
			).copyBounds(this)
		}{
			MIDIItemPlayer.findRespondingMethodFor(selector).notNil.if{
				^this.player.performArgs(selector, args, kwargs ? #[])
			}
		};
		// a real DNU error, not the old `class + "..."` — Class doesn't understand
		// `+`, so that line itself threw and masked every genuinely-unknown
		// selector as "Message '+' not understood" (§5 backlog, fixed 2026-08-07)
		DoesNotUnderstandError(this, selector, args).throw
	}
	bounds {
		^(
			end: this.midiEvents.last.timestamp + ( this.midiEvents.last.dur ? 0 ),  
			start: this.midiEvents[0].timestamp
		)
	}
	// selected notes carry a \selBeat marker = their absolute beat coordinate
	// (beat 0 = first selected note). Because the marker lives on the event,
	// it rides through filter/quantize/from/etc. via deepCopy — no stale
	// indices. Returned in beat order (selBeat), which survives time warps.
	selectedNotes {
		^this.midiEvents.select{|e| e[\selBeat].notNil }.sort{|a b| a[\selBeat] < b[\selBeat] }
	}
	// stamp markers from a saved selection Event (indices + per-span beats).
	prStampSelection { |sel|
		var coords = sel[\beats].notNil.if(
			{ [0] ++ sel[\beats].integrate },
			{ Array.series(sel[\indices].size) });
		^this.markSelection(sel[\indices], coords)
	}
	// set markers directly: indices into this.notes; coords = absolute beat
	// coordinate per selected note (defaults to 0,1,2,... — one beat apiece).
	markSelection { |indices, coords|
		var ns = this.notes;
		coords = coords ?? { Array.series(indices.size) };
		this.clearSelection;
		indices.do{|idx i| ns[idx] !? { ns[idx][\selBeat] = coords[i] } };
		^this
	}
	clearSelection {
		this.midiEvents.do{|e| e.removeAt(\selBeat) };
		^this
	}
	// fill omitted beats/choiceFunc from the loaded selection. Prefer the
	// marker-based selection (\selBeat, transform-robust); fall back to the
	// legacy index-based currentSelection when no markers are present.
	prSelectionArgs { |beats, choiceFunc|
		var marked = this.selectedNotes;
		var sel;
		(marked.size > 0).if {
			// A filtered selection may leave one anchor, forcing all other events to
			// extrapolate—often to negative beats. Warn because this can be intentional.
			(marked.size < 2 and: { beats.isNil }).if {
				"MIDIItem tempo map: only % anchor(s) marked, so every other event is "
					"extrapolated from it (often to negative beats, which play(0) drops). "
					"A filter after .selection usually did this — reselect, or carry the "
					"frame with tempoMap_.".format(marked.size).warn
			};
			choiceFunc = choiceFunc ?? { marked };
			beats = beats ?? {
				var b = marked.collect(_[\selBeat]).differentiate.drop(1);
				// closing beat-gap from fromBeat's anchor (gap to the next parent beat),
				// else repeat the last gap to give the final note its own beat
				b ++ ((this.tryPerform(\closingAnchor) !? (_[\beats])) ? (b.last ? 1))
			};
			^[beats, choiceFunc]
		};
		sel = this.tryPerform(\currentSelection);
		sel.notNil.if {
			choiceFunc = choiceFunc ?? { this.notes[sel[\indices]] };
			beats = beats ?? {
				var b = sel[\beats] ?? { Array.fill(sel[\indices].size - 1, 1) };
				b ++ (b.last ? 1)
			};
		};
		^[beats, choiceFunc]
	}
	// dropIntro (§12B): throat-clearing notes recorded before the first selected
	// anchor have no beat position — warpTo extrapolates them below beat 0 and they
	// ride silently into asEventList. With dropIntro (default) they are dropped, and
	// any controller state set during the intro is clamped forward to the anchor.
	// The threshold is the map's t0 (ABSOLUTE timestamp of the first anchor — the
	// same coordinate warpTo's `origin` uses), so notes exactly AT the first anchor
	// are kept (strict <). Nothing before the first anchor => output is identical
	// either way, so this is behaviour-compatible for takes with no junk intro.
	//
	// With no loaded selection AND no explicit beats, prSelectionArgs answers
	// [nil, nil] and MIDIItemTempoMap.prBuildLinear then evaluates `beats.integrate`
	// on nil — a doesNotUnderstand whose error report dumps the whole receiver
	// (every event of the take), which in the post window reads as a hang. Guard
	// on `beats` rather than on the selection itself: passing beats/choiceFunc
	// explicitly is a legitimate way to quantize without a saved selection.
	// Answers the receiver unwarped, like fromSelection.
	quantize { |beats func choiceFunc recalcSustains=true, dropIntro = true |
		var tempoMap, dropBefore;
		#beats, choiceFunc = this.prSelectionArgs(beats, choiceFunc);
		beats ?? {
			"quantize needs a loaded selection — use .selection first (or pass beats)".postln;
			^this
		};
		tempoMap = MIDIItemTempoMap(this, choiceFunc, beats);
		dropBefore = dropIntro.if { tempoMap.tryPerform(\t0) };
		func.notNil.if{
			^this.quantizeFunc(beats, func, choiceFunc, recalcSustains)
		}{
			^this.warpTo(tempoMap, dropBefore)
		}
	}
    quantizeFunc { |beats func choiceFunc recalcSustains=true |
        var tempoMap;
        #beats, choiceFunc = this.prSelectionArgs(beats, choiceFunc);
        // same nil-beats guard as quantize (which also reaches here via func:)
        beats ?? {
            "quantizeFunc needs a loaded selection — use .selection first (or pass beats)".postln;
            ^this
        };
        tempoMap = MIDIItemTempoMap(this, choiceFunc, beats);
        this.collect({|e x| 
            (
                env: tempoMap.env, 
                // Keep `env` in the callback Event for compatibility, but use the
                // public direction-explicit protocol for the actual inversion.
                quantized: tempoMap.beatAt(e.timestamp - this.start),
                e: e, 
                x: x,
                averageOffset: tempoMap.averageOffset,
            ).use(func)
        }) => {|i|
            // timestamps rewritten — see prForgetTempoFrame
            recalcSustains.if { ^i.recalcSustains.prForgetTempoFrame }{ ^i.prForgetTempoFrame }
        }
    }
}

MIDIItem : AbstractMidiEvents { //class to record, save, and retrieve MIDIEvents for use with MicroKeys
	classvar <>folder, <all;
	var <>midiEvents , <name, <>initialCCValues;
	var restFirst, <initialRest, notes ;
	var <takes, <recordedMks, <>recordedMk;
	// §9a step 3: wall-clock sound epoch per take — recordEpoch + timestamp is the
	// SystemClock moment a recorded event SOUNDED (record's latencyCompensation is
	// folded in, undoing the subtraction at MIDI-Item2 capture). Overdubs are also
	// pulled back by AudioItem.outputLatency — the press was aimed at monitoring.
	// Absolute alone, but every consumer takes a difference against recordPlayEpoch's
	// \seconds, so placement survives restarts and machine moves (see recordWall).
	var <recordEpochs, <recordEpoch;
	// §9b: the EventList play epoch this take overdubbed against, snapshotted at record
	// time so source-preferred addItem aligns to the playthrough the take heard rather
	// than the list's current lastPlayEpoch. Archives (detached clock + Env, no live
	// objects); missing on pre-epoch takes, where addItem at:nil falls back to the
	// live lastPlayEpoch and misplaces silently — prefer at:\original after a restart.
	var <recordPlayEpochs, <recordPlayEpoch;
	var <beatSelections; // Dictionary: take -> List of selection Events (append-only, immutable versions)
	classvar midiout, <recording;
	classvar <current; // last item .record was called on; survives stopRecording
	// gate for DECLARATIVE record intent only (record: true on \mi2 events, which
	// persists in a song across replays) — imperative .record calls (KeyStage
	// button, recordMe, evaluated code) are one-shot gestures and are NOT gated.
	// Mirrors AudioItem.armed: disarmed by MyFree and Cmd-.
	classvar <>armed = false;

	*initClass {
		var parent;
		all = Dictionary.new(256);
		folder = this.filenameSymbol.asString.dirname.dirname +/+ "MIDI-items";
		File.exists(folder).not.if{ "mkdir %".format(folder).unixCmd };
		MyFree.add({ this.stopRecording; armed = false });
		CmdPeriod.add(this);
		// TempoClock.default=TempoClock(queueSize:8192).permanent_(true)
	}
	*cmdPeriod{
		this.stopRecording;
		armed = false
	}
//

	*new { |name restFirst=true |
		all.keys.includes(name).if { ^all[name] };
		folder.asPathName.entries.collect(_.fileName).includesEqual(name.asString).if{
			\reading.postln; 
			^Object.readArchive(folder +/+ name).register //saved mk won't be right otherwise - should not even save?
		} {
			\new.postln; 
			^super.new.initMIDIitem(name, restFirst)
		}
	}
	*newFrom { |midiEvents |
		^ MIDIItem( UniqueID ).midiEvents_(midiEvents)
	}
	// Build a MIDIItem from a Standard MIDI File (e.g. an acoustic-piano
	// transcription). Reads via wslib's SimpleMIDIFile with times converted to
	// SECONDS (MIDIItem's timestamp convention), then emits the RAW recorded
	// event stream — paired \mk/\mkOff notes plus \setDamper for CC64 — so
	// makeNotesFromMidiEvents/gui/play all behave exactly as with a recorded
	// item. name defaults to the file's basename (sans extension).
	*fromMIDIFile { |path name|
		var f, events;
		path = path.standardizePath;
		File.exists(path).not.if { ^"MIDIItem.fromMIDIFile: no file at %".format(path).warn };
		name = (name ?? { PathName(path).fileNameWithoutExtension }).asSymbol;
		f = SimpleMIDIFile.read(path);
		f.timeMode_(\seconds); // absolute onsets + durations now in seconds
		events = List.new;
		// notes: [track, onset, \noteOn, channel, note, velo, dur, upVelo]
		f.noteSustainEvents.do { |ev|
			var t = ev[1], chan = ev[3], note = ev[4], velo = ev[5], dur = ev[6], up = ev[7];
			// a note with no matching noteOff reports inf sustain — clamp so the
			// off timestamp stays finite (rare with clean transcriptions).
			(dur.isNil or: { dur == inf }).if { dur = 0 };
			events.add((midicmd: \noteOn,  type: \mk,    midinote: note, channel: chan,
				timestamp: t,       sustain: dur, amp: velo / 127));
			events.add((midicmd: \noteOff, type: \mkOff, midinote: note, channel: chan,
				timestamp: t + dur, amp: (up ? velo) / 127));
		};
		// sustain pedal (CC64): [track, time, \cc, channel, 64, value] — kept as
		// raw 0..127 in `control`, matching how record stores \setDamper.
		f.damperEvents.do { |ev|
			events.add((midicmd: \control, type: \setDamper, ctlNum: \damper,
				channel: ev[3], timestamp: ev[1], control: ev[5]));
		};
		events = events.sort { |a, b| a.timestamp < b.timestamp };
		^MIDIItem(name, false).midiEvents_(events)
	}
	*record {|name="item"|
		var stamp = name ++ "_" ++ Date.getDate.stamp;
		Nvim.replace( "MIDIItem2(\"%\").record".format(stamp) )
	}
	initMIDIitem {|n r|
		takes = List[];
		recordedMks = List[];
		restFirst = r;
		name = n;
		midiEvents = List.new;
		initialCCValues = ();
		this.register;
		^this
	}
	notes {
		notes.isNil.if{
			^this.player.notes
		};
		^notes
	}
	insert {
		Nvim.replace( "MIDIItem(\"%\")".format(name) )
	}
	// pin the take into the buffer: called blind, e.g. from a controller.
	// reads the item name from the nearest MIDIItem("...") mention at/above
	// the cursor, then round-trips through scnvim to that item's insertTake
	// (sclang side knows the take count, the buffer side knows the name)
	*insertTake { |num|
		Nvim.send(this.prInsertTakeCode(num))
	}
	*prInsertTakeCode { |num|
		var call = ".insertTake(" ++ (num ? "") ++ ")";
		^"local cur = vim.api.nvim_win_get_cursor(0)[1] " ++
			"local lines = vim.api.nvim_buf_get_lines(0, 0, cur, false) " ++
			"for i = #lines, 1, -1 do " ++
			"local n = lines[i]:match([=[MIDIItem2?%(\"([^\"]+)\"%)]=]) " ++
			"if n then " ++
			"require('scnvim.sclang').send('MIDIItem(\"' .. n .. '\")" ++ call ++ "') " ++
			"return " ++
			"end end " ++
			"vim.notify('insertTake: no MIDIItem(...) before cursor', vim.log.levels.WARN)"
	}
	// find this item's nearest mention at/above the cursor (MIDIItem or
	// MIDIItem2 spelling) and rewrite it: .record/.play become .take(n).play
	// (call args survive as trailing material), an existing .take(k) is
	// renumbered, a bare receiver gains .take(n); everything else on the
	// line is preserved. num defaults to the latest take, negatives count
	// from the end
	insertTake { |num|
		(takes.size == 0).if { ^"insertTake: no takes in %".format(name).postln };
		num = num ?? { takes.size - 1 };
		(num < 0).if { num = takes.size + num };
		Nvim.substituteBefore(this.prInsertTakePairs(num))
	}
	prInsertTakePairs { |num|
		var recv = "MIDIItem2?%(\"" ++ Nvim.luaPatternEscape(name) ++ "\"%)";
		var take = "MIDIItem(\"%\").take(%)".format(name, num);
		var takePlay = take ++ ".play";
		^[
			[recv ++ "%s*%.%s*record%f[%W]", takePlay],
			[recv ++ "%s*%.%s*play%f[%W]", takePlay],
			[recv ++ "%s*%.%s*take%b()", take],
			[recv, take]
		]
	}
	register {
		all.add(name -> this)
	}
	*mostRecent {
		^
		folder +/+
		( folder => PathName(_) => _.files => _.collect( { |i| i.fileNameWithoutExtension} ) => _.sort => _.last)
		=> Object.readArchive( _ )
	}
	source{
		^this
	}
	ccPbind { |num |
		^this.ccTracks[num].eventsToPatternPairs.p
	}
	ccPbinds {
		^this.ccTracks.keys.collect{ |x|
			try{this.ccPbind(x)}
		}.select{|i| i.notNil}.asArray 
	}
	ppar {
		^Ppar(
			[
				this.notesPbind ,
			]
			++ this.ccPbinds
			// ++ (initialRest ++ ccTracks[\poly]  => _.q)
		)
	}
	makeNotesFromMidiEvents { |array|
		var events = array.deepCopy;
		var on = events.select{|e| e.midicmd == \noteOn};
		var off = events.select{|e| e.midicmd == \noteOff};
		var offMidinotes = off.collect{|e| e.midinote};
		var findMatch = {|midinote| offMidinotes.indexOf(midinote)}; //returns index
		var notes;
		on.do{|e| try{
			var index = findMatch.(e.midinote);
			var match = off.removeAt(index);
			offMidinotes.removeAt(index);
			e.sustain = match.timestamp - e.timestamp
		}
		};
		notes = initialRest.copy ? [] ++ on;
		notes.setDurs;
		^(notes ++ array.reject{|e| e.type == \mk}).sort{|i j| i.timestamp < j.timestamp}
	}
	makeNotes {
		// should copy be deepCopy??
		var events = midiEvents.deepCopy;
		var on = events.select{|e| e.midicmd == \noteOn};
		var off = events.select{|e| e.midicmd == \noteOff};
		var findMatch = {|midinote| off.collect{|e| e.midinote}.indexOf(midinote)}; //returns index
		var notes;
		on.do{|e| try{var match = off.removeAt( findMatch.(e.midinote) ); e.sustain = match.timestamp - e.timestamp;} };
		notes = initialRest.copy ? [] ++ on;
		notes.setDurs;
		^(notes ++ midiEvents.reject{|e| [\mk].includes(e.type)}).sort{|i j| i.timestamp < j.timestamp}
	}
	ccsAsArraysOfPoints{
		^midiEvents.select{|e| e.midicmd == \control}.deepCopy
		.sort{ |i j| i.ctlNum < j.ctlNum }
		.separate{ |i j| i.ctlNum == j.ctlNum }
		.collect{|sub| sub[0].ctlNum -> sub.collect{|i| Point(i.timestamp, i.control)}}
		=> _.asDict
	}
	*stopRecording {
		var item = recording, before;
		[\noteOn, \noteOff, \control, \polytouch, \bend ].do{
			|cmd|
			MIDIdef((\record ++ cmd).asSymbol).free
		};
		item.notNil.if {
			before = item.takes.size;
			item.stop;
			item.save;
			recording = nil;
			// a take was sealed — whether this stop came from the KeyStage record
			// toggle, MyFree/stop, or Cmd-. — so hand the insert line to nvim
			(item.takes.size > before).if { this.prRegisterAddItemLine(item) }
		}
	}
	// union of every XMIDIController subclass's *recordIgnores for this msgType:
	// controller messages (transport buttons etc.) that record must not capture.
	// Re-read at each .record, so controllers can re-map live.
	*recordIgnoredNums { |cmd|
		^(XMIDIController.allSubclasses ? []).collect { |c| (c.recordIgnores ? ())[cmd] }
			.reject(_.isNil).flatten(1)
	}
	// ready-to-paste insert line for the just-sealed take -> nvim register d.
	// take(n) carries recordedMk/epochs, so addItem resolves mk and source-preferred
	// position by itself; at: 0 is appended when no EventList was playing during
	// the take (no play epoch for source-preferred position to resolve against).
	// Report the played beat in a comment; passing at: would change placement mode.
	*prRegisterAddItemLine { |item|
		var n = item.takes.size - 1;
		var list = item.recordPlayEpoch !? { |ep| ep[\list] };
		var beat = list !? { { list.itemStartBeat(item.take(n)) }.try };
		var line = "e.addItem(MIDIItem(\"%\").take(%)%)%".format(
			item.name,
			n,
			item.recordPlayEpoch.isNil.if{ ", at: 0" }{ "" },
			beat !? { |b| " //at " ++ b.round(0.001) } ? ""
		);
		Nvim.setReg("d", line);
		Nvim.notify("reg d: " ++ line);
		"reg d: %".format(line).postln
	}
	stop {
		if (midiEvents.select{|e| e.timestamp > 0}.size > 0) {
			takes.add(midiEvents);
			recordedMks = recordedMks ? List[];
			recordedMks.add(recordedMk);
			recordEpochs = recordEpochs ? List[];
			recordEpochs.add(recordEpoch);
			recordPlayEpochs = recordPlayEpochs ? List[];
			recordPlayEpochs.add(recordPlayEpoch);
		}
	}
	at {|num|
		^takes[num]
	}
    record {
        |mk latencyCompensation|
        var start = SystemClock.seconds;
        var ccIgnore;
        var initialEvent =
        (
            midicmd: \control,
            timestamp: SystemClock.seconds - start,
            initialEvent: true,
        );
        // fresh take: clear any prior take's recordedMk so `recordedMk ?` below (and the
        // Event branch) rebuild from THIS call's mk — otherwise re-recording with a new
        // synth silently keeps the old one and playback uses the stale voice.
        recordedMk = nil;
        mk.isKindOf(Event).if {
            var base = MicroKeys.current.asEvent;
            recordedMk = base.putAll(mk);
            mk = recordedMk.play[\mk]
        };
        mk = mk ? MicroKeys.current;
        // a raw VSTI/VSTPluginController must not land in recordedMk: save would
        // archive the live plugin graph (Synth, controller, OSC dispatcher). Wrap it
        // in a VSTKeys (same routing as MicroKeys.new) so asEvent stores a light form.
        (mk.isKindOf(VSTI) or: { mk.isKindOf(VSTPluginController) }).if { mk = MicroKeys(mk) };
        recordedMk = recordedMk ? mk.isKindOf(MicroKeys).if{ mk.asEvent }{ mk };
        latencyCompensation = latencyCompensation ? Server.default.latency;
        // and the list-play epoch this overdub is sounding against (nil if no list is
        // playing) — lets addItem stay aligned even if that list is later replayed
        recordPlayEpoch = EventList.currentPlayEpoch;
        // sound epoch for this take (see recordEpoch ivar comment)
        recordEpoch = start + latencyCompensation;
        //subtract outputLatency from MIDI recording only when overdubbing
        recordPlayEpoch.notNil.if {
            recordEpoch = recordEpoch - AudioItem.outputLatency
        };
        mk.do{|i| (i.isKindOf(Symbol).if{ MicroKeys(i) }{ i }).monitor};
        recording = this;
        current = this;
        midiEvents = List[];
        // add Events to set initial CC values to midiEvents — skipping controller-
        // ignored CCs (transport buttons), which land in MicroKeys.ccs as numeric
        // Symbols ('45') via monitor's setClassCCs
        ccIgnore = MIDIItem.recordIgnoredNums(\control);
        MicroKeys.ccs.asKeyValuePairs.pairsDo{ | i j |
            ccIgnore.includes(i.asString.asInteger).not.if {
                midiEvents.add(
                    initialEvent ++ (
                        type: \setCC,
                        ctlNum: i,
                        // control: CC(i).spec.unmap(j) * CC(i).rawScale , //put back in original
                        control: j
                    )
                )
            }
        };
        midiEvents.add(
            initialEvent ++ (
                type: \setPoly,
                ctlNum: \polytouch,
                control: 0,
                midinote: \r
            )
        );
        restFirst.if { initialRest = [( type: \rest, timestamp: SystemClock.seconds - start)] };

        //make MIDIdefs - FIXED: Different parameter patterns for different message types

        // Messages with val, num, chan parameters
        [\noteOn, \noteOff, \control, \polytouch ].do { |cmd|
            // controller-declared non-musical messages (transport buttons etc.)
            // must not land in the take
            var ignore = MIDIItem.recordIgnoredNums(cmd);
            MIDIdef((\record ++ cmd).asSymbol, func: { |val num chan src|
                MicroKeys.excludeSrcIDs.includes(src).not.if {
                midiEvents.add(
                    (
                        midicmd: cmd,
                        timestamp: SystemClock.seconds - start - latencyCompensation,
                        channel: chan,
                    )//.postln
                    ++ switch (cmd) 
                        {\noteOn} { (type: \mk, midinote: num, amp: val/127 )}
                        {\noteOff} { (type: \mkOff, midinote: num, amp: val/127 ) }
                        {\polytouch} { (type: \setPoly, midinote: num, polyTouch: val, ) }
                        {\control} {
                            ( num == 64 ).if{
                                (type:\setDamper, ctlNum:\damper, control: val)//.postln 
                            } { 
                                ( num == 74 ).if{
                                    (type: \setCC74, ctlNum: 74, control: val / 127)
                                } {
                                    //TODO do away with this divisions ???
                                    (type: \setCC, ctlNum:num, control: val / 127)//.postln
                                }
                            } 
                        }
                    )
				}},msgType: cmd,
				msgNum: ((cmd == \control) or: { ignore.size > 0 }).if{ (0..127).difference(ignore) },
			)
		};

        // Messages with only val, chan parameters - NO num parameter!
        [\bend, \touch ].do { |cmd|
            MIDIdef((\record ++ cmd).asSymbol, func: { |val chan src|
                MicroKeys.excludeSrcIDs.includes(src).not.if {
                midiEvents.add(
                    (
                        midicmd: cmd,
                        timestamp: SystemClock.seconds - start - latencyCompensation,
                        channel: chan,
                    )
                    ++ switch(cmd)
                        {\bend} { (type: \setBend, ctlNum:\bend, control: val / 16384) }
                        {\touch} { (type: \setPressure, ctlNum:\pressure, control: val / 127) }
                )
            }},msgType: cmd )
        };
        ^SelfReturningObject()
    }
	playRaw {
		var playbackEvents;
		this.stop;
		fork{
			// midiEvents.collect(_.timestamp).differentiate.drop(1).do{|i x|
			this.midiEvents.collect(_.timestamp).differentiate.drop(1).do{|i x|
				midiEvents[x].play;
				i.wait;
			}
		}
	}
	play { |mk name clock post overdub=false |
		mk = case
			{ mk.isKindOf(Event) && recordedMk.isKindOf(Event) } {
				var e = (proto: recordedMk) ++ mk;
				e.play[\mk]
			}
			{ mk.isKindOf(Event) } { mk.play[\mk] }
			{ mk.notNil } { mk.isKindOf(Symbol).if{ MicroKeys(mk) }{ mk } }
			{ recordedMk.isKindOf(Event) } { recordedMk.play[\mk] }
			{ recordedMk.notNil } { MicroKeys(recordedMk) };
		^this.player.play(mk, overdub: overdub)

	}
	player {|func take|
		^if(recording != this) {
			// MIDIItemPlayer( this.makeNotesFromMidiEvents(midiEvents), this) built from
			// the LIVE buffer = the most recent recording -> carries its sound epoch
			MIDIItemPlayer( this.makeNotesFromMidiEvents(midiEvents), this)
				.recordEpoch_(recordEpoch)
				.recordPlayEpoch_(recordPlayEpoch)
		}{
			SelfReturningObject()
		}
	}
	// a MIDIItem's notes are a fresh deepCopy per call, so the inherited method
	// would mark a throwaway — return a marked PLAYER instead (chainable)
	markSelection { |indices, coords|
		^this.player.markSelection(indices, coords)
	}
	save {
		// notes.isNil.if{this.makeNotes};
		// never archive live objects through recordedMk/recordedMks (a PF once
		// dragged its whole VST + OSC-dispatcher graph into the file). Swap in
		// sanitized values for the write, then restore so the in-session mk —
		// which playback may still depend on — is untouched.
		var savedMk = recordedMk, savedMks = recordedMks;
		var sane = { |m|
			case
			{ m.isNil or: { m.isKindOf(Symbol) } } { m }
			{ m.isKindOf(Event) } {
				var e = m.copy;
				m.keysValuesDo { |k v|
					(v.isKindOf(VSTI) or: { v.isKindOf(VSTPluginController) } or: { v.isKindOf(Node) }).if {
						"MIDIItem %: dropping live % at key '%' from archived recordedMk".format(name, v.class, k).warn;
						e[k] = nil
					}
				};
				// Do not archive defaultParentEvent and its environment-dependent sources.
				e.parent_(nil).proto_(nil)
			}
			{ m.isKindOf(MicroKeys) } { m.asEvent.parent_(nil).proto_(nil) }
			{
				"MIDIItem %: recordedMk is a live % — archived as nil".format(name, m.class).warn;
				nil
			}
		};
		recordedMk = sane.(recordedMk);
		recordedMks = recordedMks !? { recordedMks.collect(sane) };
		{ this.writeArchive( folder +/+ name) }.protect {
			recordedMk = savedMk;
			recordedMks = savedMks;
		}
	}
	filterCC { |ctlNum=0 suffix="noZeros"|
		var newName = name ++ "_" ++ suffix;
		var mi = this.class.new(newName, false);
		mi.midiEvents = midiEvents.reject{|e| (e.midicmd == \control) and: {e.ctlNum == ctlNum}};
		mi.save;
		"filterCC: removed CC % from % → %".format(ctlNum, name, newName).postln;
		^mi
	}
	delete {
		var result = File.delete(folder +/+ name); 
		this.free;
		^"file succeeded: %".format(result);
	}
	reset {
		midiEvents = List.new
	}
	take {|num|
		var obj;
		(num < 0).if { num = takes.size + num  };
		(num < 0 or: (num > (takes.size - 1))).if { ^"only % takes in %".format(takes.size, name).postln};
		obj = MIDIItemPlayer(this.makeNotesFromMidiEvents(takes[num]), this);//.recalcSustains
		obj.recordedMk = recordedMks !? _[num];
		obj.recordEpoch = recordEpochs !? _[num];
		obj.recordPlayEpoch = recordPlayEpochs !? _[num];
		obj.takeIndex = num;
		^obj
	}
	// selections are immutable: appending is the only mutation, identical saves are no-ops
	addSelection { |take, sel|
		var list, last, same;
		(take < 0).if { take = takes.size + take };
		beatSelections = beatSelections ?? { Dictionary.new };
		list = beatSelections[take] ?? { List[] };
		beatSelections[take] = list;
		last = list.last;
		same = last.notNil and: {
			// \contentStart counts: re-marking the intro is a real edit, worth a version.
			// \manual counts too: it is the hand-picked/grid-picked PARTITION of
			// \indices, and the gui's reload path (savedSel[\manual] ?? fallback)
			// cannot recover it from \indices — its own comment says so ("the true
			// manual set is unrecoverable"). Two saves with the same notes but a
			// different manual set rebuild different grids, so they are different
			// selections. Comparison is nil-safe by ordinary ==: legacy saves have
			// the key on neither side (nil == nil, dedupes), and gaining a manual
			// set (nil vs an Array) is correctly a new version.
			[\indices, \beats, \pins, \periodPrior, \anchor, \contentStart, \manual]
				.every{ |k| last[k] == sel[k] }
		};
		same.if {
			^"selection unchanged — take % stays at % version(s)".format(take, list.size).postln
		};
		list.add(sel);
		this.save;
		"take %: saved selection version %".format(take, list.size - 1).postln;
		^sel
	}
	selections { |take = (-1)|
		(take < 0).if { take = takes.size + take };
		^beatSelections !? { |d| d[take] }
	}
	// singular returns a configured player (plural returns the data):
	// MIDIItem("foo").selection(4, 3) == MIDIItem("foo").take(3).selection(4)
	selection { |version = (-1), take = (-1)|
		^this.take(take).selection(version)
	}
}

MIDIItemPlayer : AbstractMidiEvents { //class to filter and play MIDIItems
	classvar <playing;
	var <midiEvents, <source, <>recordedMk;
	var <>start, <>end;
	var tracks;
	var <>takeIndex, <>currentSelection; // set by MIDIItem.take / selection — not preserved through filters
	var <>recordEpoch; // wall-clock sound epoch of the take (MIDIItem.recordEpochs) — carried through filters via copyBounds
	var <>recordPlayEpoch; // the list-play epoch this take overdubbed against (MIDIItem.recordPlayEpochs) — carried through filters via copyBounds
	var <>closingAnchor; // (time:, beats:) closing tempo-anchor from the parent's next selected beat; set by fromBeat — carried through filters via copyBounds
	var <>beatScale; // ideal-beats-per-anchor multiplier (nil == 1); applied by tempomap, see scaleBeats — carried through filters via copyBounds
	var <>tempoMapOverride; // set by tempoMap_ / selection; consulted by tempomap before deriving — carried through filters via copyBounds

	*new {| amidiEvents source |
		var player, bounds;
		var midiEvents = (amidiEvents.size != 0).if{ amidiEvents.deepCopy }{ [(type: \rest, timestamp:0, dur: 1, sustain: 1)]};
		player = super.newCopyArgs(midiEvents, source);
		midiEvents.notNil.if { //this should not be necessary!!!!
			bounds = (
				end: midiEvents.last.timestamp + ( midiEvents.last.dur ? 0 ),  
				start: midiEvents[0].timestamp max: 0
			);
			player.start = bounds.start;
			player.end = bounds.end;
		}{"MidiEvents nil!!".warn};
		^player
	}
	player { ^this } // a player is already a player; lets asEventList etc. resolve uniformly
	*stopAll {
		playing.do({ |i| 
			i.restoreCCValues;
			playing.remove(i)
		})
	}
	*initClass{
		playing = Set[];
		MyFree.add({MIDIItemPlayer.stopAll});
		Event.addEventType(\mi, {
			~dur = ~player[~to+1].timestamp - ~player[~from].timestamp;
			// tempo wins; else 1/stretch (sec per beat); else 1. Parens are load-bearing:
			// SC binary ops are flat L-to-R, so the un-parenthesized form divided by nil.
			~clock = TempoClock(~tempo ? (1 / (~stretch ? 1)));
			~player.fromNote(~from, ~to).play(~mk, clock: ~clock) 
		}, parentEvent: (type: \durEvent));
		Event.addEventType(\mi2, {
			// record: true only means record when ARMED (MIDIItem.armed) — the
			// audioItem pattern: leave record: true in the event, flip armed for the
			// pass you want captured. Armed, recording REPLACES playback (you're
			// re-performing the part); the take lands on the event's source item,
			// snapshots the playing list's epoch, and is sealed by stopRecording
			// (KeyStage record button, MyFree/stop, Cmd-.) — which also writes the
			// e.addItem(...) line to nvim register d.
			var wantsRecord = (~record ? false) == true;
			var item = wantsRecord.if { ~player.tryPerform(\source) };
			var doRecord = wantsRecord and: {
				MIDIItem.armed.not.if {
					"MIDIItem %: not armed — playing; will record if armed"
						.format(item.tryPerform(\name)).warn;
					false
				} {
					case
					{ item.isNil } {
						"mi2 record: player % has no source item — playing instead"
							.format(~player).warn;
						false
					}
					// one shared recording at a time (classvar + \record* MIDIdefs) —
					// never steal an in-progress take
					{ MIDIItem.recording.notNil } {
						"mi2 record: already recording % — playing % instead"
							.format(MIDIItem.recording.name, item.name).warn;
						false
					}
					{ true }
				}
			};
			doRecord.if {
				item.record(~mk ? ~player.recordedMk ? item.recordedMk)
			} {
				~filter.notNil.if{~player = ~filter.(~player)};
				// '!?'.help
				~dur = ~dur ? ((~player.end ? ~player.bounds.end) - (~player.start ? ~player.bounds.start));
				~clock = TempoClock(~tempo ? (1 / (~stretch ? 1)), queueSize: 65536);
				~player.play(~mk ? MicroKeys(\default), clock: ~clock)
			}
		}, );
		Event.addParentType(\mi2,
			// NB: type:durEvent and finish MUST live on this one event with a nil
			// .parent, so addParentType chains it to defaultParentEvent. Nesting
			// `parent: (type: \durEvent)` dead-ends the chain before playerEvent,
			// so ~eventTypes/~parentTypes vanish and play fails with 'at'/nil.
			(
				type: \durEvent,
				finish: {|e|
					(e.params.notNil).if {
						// \setParams.postln;
						e.player = e.player.setParams(e.params)
					}
					// implement lag and some setting to increase the duration
					// maybe .filter({|e| e.collect{|f| f.timestamp = f.timestamp + f.lag}})
				}
			)
		);
	}
	initialRest {
		^midiEvents.select{|e| e.timestamp == 0 and:  (e.type == \rest)}[0].dur
	}
	removeNote{ |index|
		var notes = midiEvents.select{|i| i.midicmd == \noteOn};
		^this.filter { |e| //remove bad note (should be method?)
			e = e.copy; // don't mutate the receiver's midiEvents
			index.asArray.do{ |x|
				var note =  notes[x];
				var off = e.select{|i| i.midicmd == \noteOff and: (i.timestamp >= note.timestamp) and: (i.midinote == note.midinote)}
				// .sort({|x y| x.timestamp < y.timestamp})
				.at(0);
				e.remove(note); e.remove(off)
			};
			e
		}
	}
	setBounds {|event|
		start = event.start; end = event.end
	}
	// carry bounds + record epochs from the player/item this one derives from —
	// filtered events still occurred at the same wall-clock moments, so
	// source-preferred addItem keeps working down a filter chain. Caveat: a
	// timestamp-mutating filter (quantize, +lag) makes the epoch map the MUTATED
	// timestamps as performed moments — deliberate retiming lands shifted.
	copyBounds {|mi|
		start = mi.start; end = mi.end;
		recordEpoch = recordEpoch ? mi.tryPerform(\recordEpoch);
		recordPlayEpoch = recordPlayEpoch ? mi.tryPerform(\recordPlayEpoch);
		// Filters remove notes, not the container's tempo frame.
		tempoMapOverride = tempoMapOverride ? mi.tryPerform(\tempoMapOverride);
		beatScale = beatScale ? mi.tryPerform(\beatScale);
		closingAnchor = closingAnchor ? mi.tryPerform(\closingAnchor);
	}
	// wall offset (seconds from the recorded playthrough's beat-0 origin) at which
	// the take's timestamp 0 sounded. Pure difference of same-session epochs, so it
	// survives archive round-trips and machine moves. nil for pre-epoch takes.
	recordWall {
		var ep = recordPlayEpoch ?? { ^nil };
		recordEpoch ?? { ^nil };
		^recordEpoch - ep[\seconds] + ep[\list].beatToWall(ep[\fromBeat], ep[\tempoEnv])
	}
	// beat the take START was performed at, in the recorded playthrough's frame —
	// what source-preferred addItem resolves for timestamp 0. For b0 in ANOTHER
	// list's current frame (wall-preserving), use thatList.itemStartBeat(this).
	recordBeat {
		var ep = recordPlayEpoch ?? { ^nil };
		^this.recordWall !? { |w| ep[\list].wallToBeat(w, ep[\tempoEnv]) }
	}
	// sched: optional { |relTime, playFunc| } hook — when given, events are handed to it
	// instead of clock.sched (EventList.prepare flattens them into its own schedule,
	// §10; no clock, so no queueSize overflow). mk resolution/CC store still run here.
	play { |mk clock post=#[] overdub=false take sched|
		(mk.rank > 0).if { mk.do{|i| this.play(i, clock, post, overdub, take, sched) }; ^this };

		mk.isNil.if {
			var rmk = recordedMk ? source.recordedMk;
			mk = case
				{ rmk.isKindOf(Event) } { rmk.play[\mk] }
				{ rmk.notNil } { MicroKeys(rmk) }
		};
		mk.isKindOf(Event).if {
			var rmk = recordedMk ? source.recordedMk;
			mk = rmk.isKindOf(Event).if {
				var e = (proto: rmk) ++ mk;
				e.play[\mk]
			}{
				mk.play[\mk]
			}
		};
		mk.isKindOf(Symbol).if {
			overdub.if { 
				mk = MicroKeys(mk) 
			} {
				mk = MicroKeys.newFrom(mk, UniqueID.next) 
			}
		};
		// (mk.size > 1).if { 'play first'.postln; mk.do(this.play() };
		mk.notNil.if { playing.add(mk) };

		(post.size > 0).if{
			"# note amp sus".postln 
		};
		mk.storeCCValues;
		mk.modState = (bend: 0, poly: 0, pressure: 0, expr: 0);
		midiEvents.do{|e x|
			var from = start ? 0;
			var to = end ? midiEvents.last.timestamp;

			((e.timestamp == 0) or: (e.timestamp >= from) and: (e.timestamp <=  to )).if {
				var playFunc = mk.notNil.if{
					{
						e
						.mk_(mk.name ? mk)
						.latency_(Server.default.latency)
						.play; 
					} 
				}{
					{ 
						e
						.latency_(Server.default.latency)
						.play
					} 
				}; 

				sched.notNil.if {
					sched.(e.timestamp - (start ? 0), playFunc)
				} {
					(clock ? TempoClock.default).sched(e.timestamp - ( start ? 0 ), playFunc)
				};

				post.includes(e.midicmd).if{
					var dict = e.asDict;
					var logString = "% % % % % ".format(
						mk !? _.name,
						x,
						dict.at(\midinote),
						dict.at(\amp) !? _.round(0.001),
						dict.at(\sustain) !? _.round(0.001)
					);
					AppClock.sched(e.timestamp - midiEvents[from].timestamp, { logString.postln }) 
				}
			}
		}
	}
	
	dur {
		^(end - start)
	}

	// load a saved selection version onto this player (chainable):
	// MIDIItem("foo").take(3).selection(2).gui
	selection { |version = (-1)|
		var list = takeIndex !? { source.tryPerform(\selections, takeIndex) };
		currentSelection = list !? { |l|
			(version < 0).if { l[l.size + version] }{ l[version] }
		};
		currentSelection.isNil.if {
			"no saved selection (take %, version %)".format(takeIndex, version).postln
		}{
			this.prStampSelection(currentSelection); // ride markers through transforms
			// Cache after stamping so later note filters cannot change the frame.
			tempoMapOverride = { this.tempomap }.try
		};
		^this
	}
	selections {
		^source.tryPerform(\selections, takeIndex)
	}
	noteIndices {
		^midiEvents.select{|e| e.midicmd == \noteOn }
		.collect{|i x| x->midiEvents.indexOf(i) }
		.asDict
	}
	tempoMapFromIndices {
		|indices=#[0, 3, 5, 7] beats=#[1, 1, 1, 1]|
		^MIDIItemTempoMap(this, this.notes[indices], beats)
	}
	// dropBefore (§12B): absolute source-time threshold for the intro-drop policy.
	// Without it, events before the map's first anchor are extrapolated below beat 0
	// at the boundary tempo — throat-clearing notes land on NEGATIVE beats and ride
	// silently into asEventList. When given: NOTE events earlier than the threshold
	// are dropped outright; NON-note events (CC/bend/program change) are KEPT but
	// clamped to the threshold, because they carry the controller state the content
	// starts in (same landing philosophy as chaseCCs at a slice start). nil (default)
	// == exactly the old behaviour, and with nothing before the threshold the two
	// paths are bit-identical.
	warpTo { |tempoMap, dropBefore|
			var origin, src;
			// §12f: a sec -> sec MonoMap is a TIME REMAP, not a tempo map, and it
			// gets its own branch. Routing it through prTempoMapFromMonoMap would
			// throw (asAnchorTempoMap wants beat<->sec), and it SHOULD: driving a
			// BEAT map through the walk below lands every event on its beat number,
			// i.e. warps the WHOLE take onto the ideal 1 s/beat grid — warpTo is
			// quantize's engine. A sec -> sec map instead says "this played second
			// becomes that played second", which is what lets an edit stay LOCAL and
			// leave the performed feel everywhere else alone (see quantizeToRhythm).
			(tempoMap.isKindOf(MonoMap) and: { tempoMap.mapsDimensions(\sec, \sec) }).if {
				// Absolute in, absolute out: a sec -> sec map composed out of
				// origin: \absolute snapshots already speaks take time, so there is
				// NO origin/t0 arithmetic in this branch — the timestamps go in raw.
				// prSecMapForWarp guards the one map that would break that.
				var remap = this.prSecMapForWarp(tempoMap);
				^this.prDropBefore(dropBefore).collect({ |e|
					e.timestamp_(remap.at(e.timestamp))
				}).prForgetTempoFrame
			};
			// §12 seam: a V2 MonoMap is accepted here and converted ONCE, before
			// anything reads t0, into the AnchorTempoMap the walk below already
			// knows how to drive. Everything downstream is untouched.
			tempoMap.isKindOf(MonoMap).if { tempoMap = this.prTempoMapFromMonoMap(tempoMap) };
			origin = tempoMap.tryPerform(\t0) ? start;
			src = this.prDropBefore(dropBefore);
			tempoMap.respondsTo(\prAtExtrapolated).if {
				^src.collect({ |e|
					e.timestamp_(tempoMap.prAtExtrapolated(e.timestamp - origin, tempoMap.env) + origin)
				}).prForgetTempoFrame
			};
			^src.collect({ |e| e.timestamp_(tempoMap[e.timestamp - start] + start) })
				.prForgetTempoFrame
	}
	// Timestamp rewrites invalidate the absolute-time override; \selBeat markers
	// remain valid for deriving a replacement.
	prForgetTempoFrame { tempoMapOverride = nil; ^this }
	// The dropBefore policy, factored out so both warpTo branches share it (the
	// comment above warpTo documents the policy itself). nil answers the receiver
	// untouched, so the no-policy path allocates nothing and stays bit-identical
	// to the `src = this` it replaced.
	prDropBefore { |dropBefore|
		dropBefore.isNil.if { ^this };
		^this
		.reject({ |e|
			((e.timestamp < dropBefore)
				and: { (e.midicmd == \noteOn) or: { e.midicmd == \noteOff } })
		})
		.collect({ |e| (e.timestamp < dropBefore).if { e.timestamp = dropBefore }; e })
	}
	// §12f: the sec -> sec half of the seam. `bake` first because the map is
	// looked up once per event and PL fusion is exact and paid once; the frame
	// check is prTempoMapFromMonoMap's, restated for the other orientation.
	prSecMapForWarp { |map|
		var baked = map.bake;
		var relFrame = MapFrame.peekSource(this.midiEvents, \relative);
		// A sec -> sec map assembled from origin: \relative snapshots measures
		// seconds from its own first anchor on BOTH ends, while these timestamps
		// are absolute take time: applying it would shift everything by t0 instead
		// of remapping it. Only an EXACT match against the take's registered
		// relative axis is an error (peekSource never mints, so a foreign map reads
		// nil and is trusted) — same deliberate asymmetry, same player-identity
		// reason, as the beat<->sec check.
		(relFrame.notNil and: {
			(baked.fromFrame == relFrame) or: { baked.toFrame == relFrame }
		}).if {
			Error("warpTo: this sec -> sec map is built on seconds RELATIVE to its own "
				"first anchor (origin: \\relative), but warpTo needs absolute take time "
				"— it would shift by t0 instead of remapping. Rebuild the pieces it was "
				"composed from with asMonoMap(origin: \\absolute).").throw
		};
		^baked
	}
	// §12 seam (MonoMap.asAnchorTempoMap is the other half). rebase: false —
	// warpTo's `origin` IS the map's t0, the absolute timestamp its first anchor
	// was played at, so the seconds axis must pass through untouched.
	prTempoMapFromMonoMap { |map|
		var baked = map.bake;
		// sec-side frame, read off the BAKED orientation (a sec->beat map carries
		// it on fromFrame); nil when the map is not beat<->sec at all, in which
		// case asAnchorTempoMap below is the one that reports the dimensions.
		var secFrame = baked.mapsDimensions(\beat, \sec).if { baked.toFrame } {
			baked.mapsDimensions(\sec, \beat).if { baked.fromFrame }
		};
		// The one mistake this seam can actually catch: a snapshot taken with
		// origin: \relative measures seconds from its own first anchor, while
		// these timestamps are absolute source time — warping through it would
		// subtract t0 twice, silently. Only an EXACT match against the take's
		// registered relative axis is an error; peekSource never mints, so a
		// foreign map (anchor-built, another take, or these events after a
		// deepCopy) reads nil and is trusted. Player identity is why that
		// asymmetry is deliberate: MIDIItem.player hands back a fresh deepCopy on
		// every call, so a take's arrays are not stable across hops and a
		// mismatch must degrade to "foreign, trust the caller", never to a false
		// error on a perfectly good absolute map.
		(secFrame.notNil and: {
			secFrame == MapFrame.peekSource(this.midiEvents, \relative)
		}).if {
			Error("warpTo: this map's seconds are RELATIVE to its own first anchor "
				"(built with origin: \\relative), but warpTo needs absolute take time — "
				"it would subtract t0 twice. Rebuild it with asMonoMap(origin: "
				"\\absolute).").throw
		};
		^baked.asAnchorTempoMap(rebase: false)
	}
	chaseCCs { |from|
		var ccs = midiEvents
		.select{|e| e.timestamp <= from }
		.select{|e| e.ctlNum.notNil };
		(ccs.size == 0).if { ^[] }; // [].separate yields [[]] -> collect(_.last) -> [nil]
		^ccs
		.sort{|i j| i.ctlNum <= j.ctlNum }
		.separate{|i j| i.ctlNum != j.ctlNum }
		.collect{|e| e.last}
			// .sort({|i j| i.timestamp <= j.timestamp}).last
	}
	notesStraddling {|time|
			// A note occupies the HALF-OPEN interval [timestamp, timestamp + sustain),
			// the same convention as onsets/beatTimes' [from, to) windows. So both
			// ends are strict: a note starting exactly at `time` is not straddling
			// (from's main select already takes it, and it would be duplicated), and
			// a note RELEASED exactly at `time` is not straddling either — it is
			// already over. The release end used to be >=, which handed `from` a
			// straddler it then clipped to sustain 0: a silent ghost noteOn at every
			// slice boundary that happened to coincide with a release. Legato takes
			// and asMIDIItem-built material (notes laid end to end) hit that
			// constantly.
			^midiEvents.select{|e| e.midicmd == \noteOn }
			.select{|e| e.timestamp < time and: (e.timestamp + e.sustain > time )};
	}

	from {|from to trim=true| 
		//makes a new player starting from from
		//clips initial notes if trim==true 
		//changes timestamps to start at 0
		
		var firstNotes = this.notesStraddling(from).deepCopy; // Array

		if (trim and: (firstNotes.size > 0)) {

			firstNotes.do{|e|
				e.sustain = e.sustain - (from - e.timestamp);
				e.timestamp = from 
			}
		}

		^(
			(firstNotes ++
			this.chaseCCs(from).deepCopy.do{|e| e.timestamp = from } ++ // chased CC state lands at the start
			midiEvents.select{|i| i.timestamp >= from and: (i.timestamp <= (to ? inf)) }.deepCopy)
			.do{|e| e.timestamp = e.timestamp - from} //adjust times to start at 0 (incl. straddlers/CCs)
			// [(),(),()].do(_.dur = 3)
			=> MIDIItemPlayer(_, this.source)
		)
	}

	// §12B: slice from the first SELECTED note — the throat-clearing intro before
	// the first anchor is gone before any downstream use (asEventList, addItem, ...).
	// Marker-based (\selBeat rides transforms), falling back to the legacy
	// index-based currentSelection. Sugar for `from(firstSelectedTime)`, so the
	// usual `from` semantics apply: straddling notes clipped when trim, CC state
	// chased to the new start, timestamps rebased to 0.
	fromSelection { |trim = true|
		var marked = this.selectedNotes;
		var t = (marked.size > 0).if { marked.first.timestamp }{
			currentSelection !? { |sel|
				(sel[\indices] ? []).first !? { |i| this.notes[i] !? (_.timestamp) }
			}
		};
		t ?? {
			"fromSelection needs a loaded selection — use .selection first".postln;
			^this
		};
		^this.from(t, nil, trim)
	}

	trim {|bool|
		bool.if{
			start = this[\timestamp][0];
		}
	}

	trimTimeStampsToStart {
		^this.collect {|i| i.timestamp = i.timestamp - start; i }
		.reject {|i| i.timestamp < 0}
		.start_(0)
	}

	fromNote {|from to trim=true|
		var indices = this.noteIndices;
		to = to ? midiEvents.select{|e| e.midicmd == \noteOn}.size;

		^this.filter({|e| 

			var res = this.chaseCCs(e[indices[from]].timestamp) 
			++ e[indices[from]..indices[to - 1]].setDurs;

			indices[to + 1].notNil.if {
				res.drop(-1)
			}{
				res
			}
		}).trim(trim)
	}

	//deprecate this
	fromNoteTo{ |from to| ^this.fromNote(from, to) }

	//collects either: the params of notes selected by Symbol
	//or the notes themselves if given a number
	//so this[\amp] returns [0.2, 0.3] etc and this[4] the 4th note
	at { |index|
		index.isKindOf(Symbol).if{
			^midiEvents.select{|e| e.midicmd == \noteOn}
			.collect{|i x| i[index] }
		}{
			^midiEvents.select{|e| e.midicmd == \noteOn}
			.at(index)
		}
	}
	tracks {
		^(tracks ? this.makeTracks)
	}
	makeTracks { //seperate CC bend and poly data into tracks with \dur key for use in Pbinds
		tracks = midiEvents.select{|e| e.midicmd == \control }.copy // do I need copy here??
		.select{|i| i.ctlNum.notNil}
		.sort{ |i j|
			i.ctlNum  < j.ctlNum
		}
		.separate{ |i j| i.ctlNum != j.ctlNum}
		.do{|subarray| subarray.setDurs }
		.collect{|subarray| subarray[0] !? {|i| i.ctlNum -> subarray }}
		.asDict;
		tracks.add(
			\poly -> midiEvents.select{|e| e.midicmd == \polytouch }
		);
		tracks.add(
			\bend -> midiEvents.select{|e| e.midicmd == \bend }
		);
		^tracks
	}

	makeNotes {
		// should copy be deepCopy??
		var notes;
		var on = midiEvents.select{|e| e.midicmd == \noteOn}.deepCopy;
		var off = midiEvents.select{|e| e.midicmd == \noteOff}.deepCopy;
		var findMatch = {|midinote| off.collect{|e| e.midinote}.indexOf(midinote)}; //returns index
		on.do{|e| 
			try{
				var match = off.removeAt(findMatch.(e.midinote)); 
				e.sustain = match.timestamp - e.timestamp 
			}
		};
		^on ++ midiEvents.reject{|e| e.type == \mk} => _.sort{|i j| i.timestamp < j.timestamp}
	}

	setParams { |array|
		//key-value pairs - values are patterns
		//for an array, use a pseq
		var event = array.asEvent, makeOutEvent;
		event.keys.do{|i| event[i] = event[i].asStream};
		makeOutEvent = {|x|
			event.keys.collect{|k| 
				().put(k, event[k].next)
			}.inject( (), _ ++ _ )
		};
		^this.filter({|e|
			e.deepCopy.collect{|i x| i.params = i.params ++
				makeOutEvent.(x)
			}
		})
	}

	filterEventsAndNotes{|func|
		^MIDIItemPlayer(
			// (indices: this.noteIndices).use{ func.(midiEvents).valueEnvir })
			func.(midiEvents, this.notes),
			this.source
		).copyBounds(this)
	}
	pickNotes { |list|
		^MIDIItemPlayer( this.notes[list], source: this).copyBounds(this)
	}
	filter {|func, key, choice, onlyNotes=false, midicmd|
		var choiceFunc, out, array, notes, evts;
		// midicmd builds a choice function
		midicmd.notNil.if {
			choice.notNil.if { "filter: midicmd overrides choice".warn };
			choiceFunc = case
				{ midicmd.class == Symbol } {{ |e| e.midicmd == midicmd }}
				{ midicmd.class == Integer } {{ |e| e.midicmd == \control and: (e.ctlNum == midicmd) }};
		} {
			choiceFunc = choice;
		};
		// key: extract one param from notes, apply func, write back
		key.notNil.if {
			(choiceFunc.notNil or: midicmd.notNil).if { "filter: key ignores choice/midicmd".warn };
			out = midiEvents.deepCopy;
			array = this[key];
			func.(array).do{|i x| this.notes(out)[x].put(key, i)};
			^MIDIItemPlayer(out, this.source).copyBounds(this)
		};
		// onlyNotes: func acts on notes array, spliced back in
		onlyNotes.if {
			choiceFunc.notNil.if { "filter: onlyNotes ignores choice/midicmd".warn };
			notes = func.(this.notes.copy);
			evts = this.midiEvents.copy;
			notes.do {|note index|
				evts.put(this.noteIndices[index], note)
			};
			^MIDIItemPlayer(evts, this.source).copyBounds(this)
		};
		// choice/midicmd: apply func only where choiceFunc is true
		choiceFunc.notNil.if {
			^this.collect(
				{|e x| choiceFunc.(e, x).if { func.(e, x) } {e}},
				midiEvents
			)
		};
		// base case: func receives full midiEvents array
		^MIDIItemPlayer(func.(midiEvents), this.source).copyBounds(this)
	}
	//deprecated — use filter(func, choice:choiceFunc)
	filterOnly { |choiceFunc, actionFunc|
		^this.filter(actionFunc, choice: choiceFunc)
	}
	//deprecated — use filter(func, onlyNotes:true)
    filterNotes { |func|
		^this.filter(func, onlyNotes: true)
    }

	notes { |aMidiEvents|
		^(aMidiEvents ? midiEvents).select({|e| e.midicmd == \noteOn})
	}

	pasteKey{|key precision=2|
		Nvim.replace(this[key].round(10 ** (precision * -1)))
	}
	//deprecated — use filter(func, key:key)
	filterNotesKey {|key func|
		^this.filter(func, key: key)
	}
	//deprecated — use filter(func, midicmd:track)
	filterOnlyMidicmd {|track actionFunc|
		^this.filter(actionFunc, midicmd: track)
	}
	muteCC{ |num|
		^MIDIItemPlayer(
			midiEvents.reject{|e| e.type == \setCC and: ( e.ctlNum == num )} ,
			this.source
		).copyBounds(this);
	}
	initialCCOnly{ |num|
		^MIDIItemPlayer(
			midiEvents.reject{|e| e.type == \setCC and: ( e.ctlNum == num ) and: (e.initial.isNil)} ,
			this.source
		).copyBounds(this)
	}
	tempomap {|beats choiceFunc|
		// Explicit anchor arguments request a newly derived map.
		(tempoMapOverride.notNil and: { beats.isNil } and: { choiceFunc.isNil }).if {
			^tempoMapOverride
		};
		beats.isString.if{ beats = beats.beats };
		#beats, choiceFunc = this.prSelectionArgs(beats, choiceFunc);
		// player-level beat scale: each anchor gap counts as beatScale ideal beats
		// (same as MIDIItemTempoMap.scaleBeats, folded in before construction).
		^MIDIItemTempoMap(this, choiceFunc, beats * (beatScale ? 1))
	}
	tempoMap {|beats choiceFunc| ^this.tempomap(beats, choiceFunc) }
	// Set a filter-stable beat frame before asEventList bakes event positions.
	// Preserve absolute t0 when coercing MonoMap; foreign-map t0 values are suspect.
	tempoMap_ { |aMap|
		var lo, hi, t0;
		aMap.isNil.if { tempoMapOverride = nil; ^this };
		tempoMapOverride = aMap.isKindOf(MonoMap).if {
			aMap.asAnchorTempoMap(false)
		}{
			aMap
		};
		tempoMapOverride.respondsTo(\prAtExtrapolated).not.if {
			Error("MIDIItemPlayer.tempoMap_: % does not answer the tempo-map protocol "
				"(t0 / env / prAtExtrapolated)".format(aMap.class)).throw
		};
		t0 = tempoMapOverride.tryPerform(\t0);
		(t0.notNil and: { midiEvents.size > 0 }).if {
			lo = midiEvents.first.timestamp;
			hi = midiEvents.last.timestamp;
			((t0 < (lo - 1e-6)) or: { t0 > (hi + 1e-6) }).if {
				"MIDIItemPlayer.tempoMap_: the map's t0 (%) is outside this player's "
					"timestamps [%, %] — t0 is an absolute recorded time, so a map from "
					"another take (or an unplaced synthetic one) offsets every beat"
					.format(t0.round(0.001), lo.round(0.001), hi.round(0.001)).warn
			}
		};
		^this
	}
	// Return a COPY of this player whose tempomap treats each anchor gap as k ideal
	// beats instead of 1 — so everything derived from the map picks it up, including
	// asEventList (which builds its own map internally): pure relabel, playback is
	// unchanged, but bps/bpm and the EventList's beat grid scale by k. Non-mutating,
	// so chain it — m.scaleBeats(2).asEventList(\x, \default) — or m = m.scaleBeats(2)
	// to keep it. Composes: scaleBeats(2).scaleBeats(2) == 4.
	scaleBeats {|k = 1| ^this.copy.prScaleBeats(k) }
	prScaleBeats {|k = 1| beatScale = (beatScale ? 1) * k; ^this }
	// measured tempo of the loaded selection (see MIDIItemTempoMap.bps).
	// e.g. q = m.quantize; q.play(nil, TempoClock(m.bps)) -> original tempo.
	bps {|beats choiceFunc| ^this.tempomap(beats, choiceFunc).bps }
	bpm {|beats choiceFunc| ^this.tempomap(beats, choiceFunc).bpm }
	// mean tempo over a BEAT span of the loaded selection — the reader that bps/bpm
	// (whole selection) and MapEditor.spanBpm (gui, current span only) both left
	// out. Goes through timeAtBeat, so it extrapolates past the selection at the
	// boundary tempo like every other beat-addressed method here, and a subrange
	// answers the tempo the MAP holds there — NOT fromBeat(from, to).bpm, which
	// rebuilds a map from the slice and is skewed by its closing anchor (see
	// MIDIItemTempoMap.bps). Pass `tempoMap` to reuse one across a sweep.
	spanBps { |from, to, tempoMap|
		var tm, dt;
		((from.isNumber.not) or: { to.isNumber.not }).if {
			("spanBps: from and to must be numbers, got % and %".format(from, to)).warn;
			^nil
		};
		(from >= to).if {
			("spanBps: need from < to, got % and %".format(from, to)).warn;
			^nil
		};
		tm = tempoMap ?? { this.tempomap };
		dt = this.timeAtBeat(to, tm) - this.timeAtBeat(from, tm);
		^(dt > 1e-9).if { (to - from) / dt }
	}
	spanBpm { |from, to, tempoMap| ^this.spanBps(from, to, tempoMap) !? (_ * 60) }
	// performed timestamp of an ideal beat position of the loaded selection
	// (beat 0 = the first selected note); extrapolates beyond the selection
	// at the boundary tempo, so negative beats address a pickup
	timeAtBeat { |beat, tempoMap|
		var tm = tempoMap ?? { this.tempomap };
		^tm.timeAt(beat) + tm.t0
	}
	// §12C: absolute performed timestamps of every 1/subdiv beat across the loaded
	// selection's beat domain — the click grid, and the snap target for the gui
	// cursor. Every beat goes through the selection tempomap, so beats BETWEEN
	// anchors sit where the map puts them (uneven anchor gaps, ghost beats,
	// curvature) rather than at a naive split of the note gaps; anchor beats land
	// exactly on timeAtBeat. Returns [] quietly when nothing is selected — a gui
	// asks this on every alt-click.
	// The domain's last beat is the map's CLOSING anchor, which for a plain
	// selection is the clip end rather than a played beat; it is INCLUDED when it
	// lands exactly on the grid (the map does claim it as a beat).
	beatTimes { |subdiv = 1|
		var tm, domain, step, n;
		((this.selectedNotes.size > 0) or: { currentSelection.notNil }).not.if { ^[] };
		(subdiv.isNumber.not or: { subdiv <= 0 }).if {
			("beatTimes: subdiv must be a positive number (%)".format(subdiv)).warn;
			^[]
		};
		tm = this.tempomap;
		domain = tm.beatDomain[1];
		(domain.isNil or: { domain <= 0 }).if { ^[] };
		step = 1 / subdiv;
		n = ((domain / step) + 1e-9).floor.asInteger;
		^(0 .. n).collect { |i| tm.timeAt(i * step) + tm.t0 }
	}
	// §12D: instantaneous tempo of a beat-grid times array — the bpm of each
	// adjacent pair, i.e. 1/slope of the beat->time map read piecewise constant.
	// `subdiv` says how many entries make one beat (pass what beatTimes was asked
	// for). The result is one shorter than `times`; a degenerate (non-increasing)
	// span yields nil in its slot so the array stays aligned with the spans.
	// Pure — the gui's tempo lane is just this over beatTimes / gridLines.
	*bpmFromTimes { |times, subdiv = 1|
		var beat;
		(times.isNil or: { times.size < 2 }).if { ^[] };
		(subdiv.isNumber.not or: { subdiv <= 0 }).if {
			("bpmFromTimes: subdiv must be a positive number (%)".format(subdiv)).warn;
			^[]
		};
		beat = 1 / subdiv; // beats spanned by one gap
		^times.differentiate.drop(1).collect { |dt|
			(dt > 1e-9).if { 60 * beat / dt }
		}
	}
	// §12c': the PICKING half of the retime flow — performed onsets inside a
	// BEAT window, deliberately kept out of the retime methods (auto-picking
	// judged too fragile to bury: grace notes, stray chord tones and a missed event all
	// want an eye on the result, and a query you can print and edit is that eye).
	// Needs a loaded selection, like every beat-addressed method here.
	//
	// The window is [fromBeat, toBeat) run through the selection's tempomap, so
	// it is asked in beats and answered in ABSOLUTE performed seconds — which is
	// exactly what the `onsets` argument takes. Half-open on purpose:
	// onsets(0, 4) ++ onsets(4, 8) partitions the take with nothing counted
	// twice, and the next bar's downbeat — which the retime reads off the MAP,
	// never off a played note — cannot sneak in as an extra event.
	//
	// `choiceFunc` is a picker, `{ |note, i| bool }` over the noteOn events —
	// `filter`'s choiceFunc convention, minus the midicmd sugar (everything here
	// is a note already; `i` indexes this.notes), and plain-function-only, which
	// is why it carries that name rather than filter's `choice`. Applied BEFORE
	// windowing and dedupe, so a register band or an amp floor costs a lambda
	// instead of a filter-player round trip:
	// onsets(20, 24, choiceFunc: { |n| n.midinote < 60 }). nil keeps every note.
	//
	// dedupe (seconds, 0 or negative disables): a chord is ONE rhythmic event,
	// so onsets closer together than this collapse to the FIRST of the cluster.
	// The comparison is between SUCCESSIVE onsets, not against the kept one, so
	// a rolled chord chains into a single event however long the roll — the
	// reading that matches how a spread chord is played. A genuinely fast
	// passage wants a smaller dedupe (or 0) and a look at the result.
	onsets { |fromBeat, toBeat, dedupe = 0.03, choiceFunc|
		var tm, lo, hi, picked, times, out, prev;
		var eps = 1e-9;
		(this.selectedNotes.size > 0 or: { currentSelection.notNil }).not.if {
			"onsets needs a loaded selection — use .selection first".postln;
			^[]
		};
		(fromBeat.isNumber.not or: { toBeat.isNumber.not }).if {
			("onsets: fromBeat and toBeat must be numbers (% and %)"
				.format(fromBeat, toBeat)).warn;
			^[]
		};
		(toBeat <= fromBeat).if { ^[] };   // empty window, quietly
		tm = this.tempomap;
		lo = this.timeAtBeat(fromBeat, tm);
		hi = this.timeAtBeat(toBeat, tm);
		picked = this.notes;
		choiceFunc !? { picked = picked.select { |e, i| choiceFunc.(e, i) } };
		// eps on BOTH ends: float dust must not make an onset that IS the span
		// start miss it, nor one that IS the end creep in (the end is exclusive)
		times = picked.collect(_.timestamp)
			.select { |t| (t >= (lo - eps)) and: { t < (hi - eps) } }
			.sort;
		(dedupe.isNumber.not or: { dedupe <= 0 }).if { ^times };
		out = [];
		times.do { |t|
			(prev.isNil or: { (t - prev) >= dedupe }).if { out = out.add(t) };
			prev = t;
		};
		^out
	}
	// §12c': re-anchor ONE beat span onto the onsets that were actually played —
	// "this bar is five events, and here is when each of them sounded". The
	// canonical call is the composition of the two halves:
	//
	//     o  = p.onsets(20, 24);
	//     m2 = p.quantizeToRhythmMap("ex x q qe e".beats, o, 20);
	//
	// followed by ONE of three applications, which say genuinely different things
	// (§12f):
	//
	//     p.quantizeToRhythm("ex x q qe e".beats, o, 20)
	//         // DESTRUCTIVE and LOCAL — the whole flow in one call. Only the
	//         // span's events move; every timestamp outside it is bit-identical,
	//         // so the performed feel of the rest of the take survives.
	//     list.tempoMap = m2
	//         // NON-DESTRUCTIVE, list level — timestamps stay performed and the
	//         // EventList reads them through the new map (the setter coerces a
	//         // V2 MonoMap for you).
	//     sourceTempoMap: m2.asAnchorTempoMap(rebase: false)
	//         // NON-DESTRUCTIVE, per-event key; needs the concrete map.
	//
	// NOT `p.warpTo(m2)`. warpTo drives a BEAT map by sending every event to its
	// beat number, i.e. it flattens the ENTIRE take onto the ideal 1 s/beat grid —
	// warpTo is quantize's engine, and the retimed span is then only the part of
	// that flattening you steered. quantizeToRhythm is warpTo of the sec -> sec map
	// `(m2.inverse >> currentMap)`, which is the local statement instead.
	//
	// (the doc's "e. s q q. e" spelling is not in String.beats' vocabulary — it
	// has no dots and no `s`; "ex x q qe e" is that same rhythm in the tokens the
	// parser does know, since a token's chars SUM: ex == dotted eighth.)
	//
	// `durs` are ITEM-LEVEL widths (§12d): beat-unit IOIs, one per rhythmic
	// event, precisely what `.beats` yields — a String is parsed for you, same
	// precedent as `tempomap`. `to` is the span's end beat, defaulting to
	// from + durs.sum; when given it is a CHECK, not a rescale — a disagreement
	// means a miscounted bar, and quietly stretching the rhythm to fit would
	// bury it.
	//
	// `onsets` is REQUIRED and never picked here (see `onsets`, the query above):
	// one performed time per dur, increasing, the first being the event AT beat
	// `from`. Each later onset pairs with the cumulative dur position.
	//
	// NO RIPPLE: both of the span's boundary times are read off the CURRENT map,
	// not off the onsets, so only events inside the span move — displacing the
	// bar itself stays scaleTempo's job. That falls out of the algebra rather
	// than being imposed: the edited cell's output width is (map time of `to`)
	// minus the first onset, and the first onset is required to sit at the span
	// start (see the tolerance below), so the width is the one it replaced.
	//
	// Non-mutating: receiver, selection and map are untouched, and the result is
	// a plain AnchorMap (beat -> absolute take seconds) for the caller to apply.
	// `amount` as in quantizeToRhythm: 1 is the fully retimed map, 0 the map as it
	// stands, in between a blend. Needs its own snapshot to blend against, since the
	// two must share a beat frame (see the ONE-call note below).
	// The MAP form of quantizeToRhythm: same computation, handed back as an
	// AnchorMap for the caller to apply (or not) instead of warping the take.
	quantizeToRhythmMap { |durs, onsets, from, to, amount = 1|
		var mOld, mNew;
		(amount == 1).if { ^this.prQuantizeToRhythmMap(from, durs, onsets, to, \quantizeToRhythmMap) };
		mOld = this.tempomap.asMonoMap(origin: \absolute);
		mNew = this.prQuantizeToRhythmMap(from, durs, onsets, to, \quantizeToRhythmMap, mOld);
		^mOld.blendWith(mNew, amount)
	}
	// §12f: the map APPLIED, locally and destructively — "these five events of
	// bar 5 were meant to be this rhythm; move them there and leave the rest of
	// the take exactly as played". Same arguments, same guards (they fire from the
	// shared builder, so only the method name in the message changes), but it
	// answers a warped PLAYER rather than a map.
	//
	// The composition is the whole idea. `warpTo(retimed beat map)` would flatten
	// the entire take onto the ideal grid; what is wanted instead is a sec -> sec
	// statement, "the second this note was played at becomes the second the OLD
	// map would have put its intended beat at":
	//
	//     mNew.inverse   played sec -> intended beat   (the retimed map, backwards)
	//     >> mOld        intended beat -> performed sec (the map as it stands)
	//
	// Outside [from, to] the two maps are the SAME anchors, so the composition is
	// the identity there — not approximately, by construction — and warpTo's
	// sec -> sec branch hands those timestamps back untouched to float precision.
	// Inside, each onset lands on mOld's time for its cumulative-dur beat.
	//
	// Both maps come from ONE `tempomap.asMonoMap` call on purpose: `tempomap`
	// builds a fresh MIDIItemTempoMap every time it is asked, so its \beat frame
	// is minted anew per call and two snapshots taken separately REFUSE to compose
	// (that is the frame system working). One call, one beat axis, no `withFrames`
	// repair.
	//
	// Non-mutating in warpTo's sense: the receiver keeps its performed times and
	// the warped copy is returned.
	// `amount` is quantize STRENGTH: 1 puts every onset on its intended beat, 0 leaves
	// the take as played, in between each onset moves that fraction of the way. It is
	// a blend of the two MAPS, not of the timestamps, so the no-ripple guarantee holds
	// at every strength — outside the span the maps are the same anchors, so any blend
	// of them is still the identity there and warpTo's sec -> sec branch hands those
	// timestamps back untouched.
	// Named for the family it belongs to: MIDIItemPlayer.quantize is the WHOLE-take
	// form (intended beats for the selection's anchors, rebuild the map, warp
	// everything), this is the local one — "these events were meant to be THIS
	// rhythm, move them there and leave the rest of the take alone". Cousins, not
	// twins: different payload (durs + measured onsets vs anchor beats), different
	// mechanism (one edited cell vs a rebuilt map), and the no-ripple guarantee is
	// this one's alone, so they stay separate methods under one verb.
	quantizeToRhythm { |durs, onsets, from, to, amount = 1|
		var mOld, mNew;
		this.prNeedSelection(\quantizeToRhythm);
		mOld = this.tempomap.asMonoMap(origin: \absolute);
		mNew = this.prQuantizeToRhythmMap(from, durs, onsets, to, \quantizeToRhythm, mOld);
		(amount != 1).if { mNew = mOld.blendWith(mNew, amount) };
		^this.warpTo((mNew.inverse >> mOld).bake)
	}
	prNeedSelection { |who|
		(this.selectedNotes.size > 0 or: { currentSelection.notNil }).not.if {
			Error("% needs a loaded selection — use .selection first".format(who)).throw
		};
		^this
	}
	// The retime builder both callers share: every guard, and the one edited cell.
	// `who` names the caller in the error messages (the guards are the caller's,
	// as far as the user is concerned). `map` lets quantizeToRhythm pass the
	// snapshot it already holds, so the two maps it composes share a beat frame;
	// nil takes a fresh one, which is the Map form's case.
	prQuantizeToRhythmMap { |from, durs, onsets, to, who = \quantizeToRhythmMap, map|
		var sum;
		this.prNeedSelection(who);
		durs.isString.if { durs = durs.beats };
		durs = durs.asArray;
		(from.isNumber.not).if {
			Error("%: from must be a beat number, got %".format(who, from)).throw
		};
		(durs.isEmpty or: { durs.every { |d| d.isNumber and: { d > 0 } }.not }).if {
			Error("%: durs must be a non-empty array of positive beat-unit "
				"IOIs, got %".format(who, durs)).throw
		};
		sum = durs.sum;
		to = to ?? { from + sum };
		(to.isNumber.not).if {
			Error("%: to must be a beat number, got %".format(who, to)).throw
		};
		(((to - from) - sum).abs > 1e-9).if {
			Error("%: the durs span % beats but [%, %] is % beats — `to` is a "
				"check, not a rescale, so fix the count or leave `to` out"
				.format(who, sum, from, to, to - from)).throw
		};
		onsets.isNil.if {
			Error("%: onsets is required — % durs, no onsets. This method never "
				"picks; query them first, e.g. p.onsets(%, %)"
				.format(who, durs.size, from, to)).throw
		};
		onsets = onsets.asArray;
		onsets.every(_.isNumber).not.if {
			Error("%: onsets must be performed times in seconds, got %"
				.format(who, onsets)).throw
		};
		(onsets.size != durs.size).if {
			Error("%: % onsets for % durs — one onset per rhythmic event. "
				"Got: %".format(who, onsets.size, durs.size, onsets)).throw
		};
		onsets.differentiate.drop(1).every(_ > 0).not.if {
			Error("%: onsets must be strictly increasing, got %".format(who, onsets)).throw
		};
		// The committed algebra (§12b A): snapshot beat -> ABSOLUTE seconds (the
		// axis the onsets live on), then edit exactly one cell. transformSpan
		// slices, hands the cell over, reconcatenates and restores the origin, so
		// nothing outside [from, to] is touched.
		map = map ?? { this.tempomap.asMonoMap(origin: \absolute) };
		^map.transformSpan(from, to, { |cell|
			// tolerance: HALF the first dur's performed width under the current
			// map. Past that the first onset is nearer some other intended
			// position than the span start — nearest-grid-point reasoning, the
			// same half-a-gap boundary quantizing uses — which in practice means
			// the wrong span, or a leading onset too many/few. Cheap to widen by
			// asking for the right window; expensive to discover after a warp.
			var lo = cell.at(from), hi = cell.at(to);
			var tol = 0.5 * (cell.at(from + durs[0]) - lo);
			((onsets.first - lo).abs > tol).if {
				Error("%: beat % sits at % s in the current map, but the first "
					"onset is at % s — off by % s, more than half the first dur's "
					"performed width (% s). Wrong span, or a missing/extra leading onset?"
					.format(who, from, lo, onsets.first, onsets.first - lo, tol)).throw
			};
			(onsets.last >= (hi - 1e-9)).if {
				Error("%: the last onset (% s) is at or past the span's end "
					"(beat % = % s) — every onset must lie inside the span's performed "
					"window.".format(who, onsets.last, to, hi)).throw
			};
			// beat widths = durs; performed widths = the gaps between the onsets,
			// closed by the span's end time from the map (never from a note).
			// x0/y0 keep the cell in the receiver's absolute coordinates like the
			// one `slices` handed over — MapSeq re-glues either way, but an
			// inspectable cell is worth the two keywords.
			AnchorMap.fromSpans(durs, (onsets ++ [hi]).differentiate.drop(1),
				x0: from, y0: onsets.first,
				fromFrame: cell.fromFrame, toFrame: cell.toFrame)
		})
	}
	// sub-player between two beat positions — beat-domain mirror of fromNote;
	// needs a loaded selection (or explicit beats/choiceFunc via .tempomap first)
	fromBeat { |from, to, trim = true|
		var tm, sub, next;
		(this.selectedNotes.size > 0 or: { currentSelection.notNil }).not.if {
			^"fromBeat needs a loaded selection — use .selection first".postln
		};
		tm = this.tempomap;
		sub = this.from(this.timeAtBeat(from, tm), to !? { this.timeAtBeat(to, tm) }, trim);
		// Closing tempo-anchor: the parent's NEXT selected beat past `to`, so the final
		// span follows the performed tempo at the boundary instead of bounds.end — which,
		// when the last note sustains past the slice, collapses to a degenerate tiny beat.
		// Left nil (→ bounds.end fallback in MIDIItemTempoMap.init) when `to` is nil or is
		// the last selected beat. TODO(quantize-tempomap): revisit the last-beat fallback.
		to !? {
			next = this.selectedNotes.detect{|e| e[\selBeat] > to };
			next !? {
				var sliceLast = (sub.selectedNotes.last !? (_[\selBeat])) ? to;
				sub.closingAnchor = (
					time: next.timestamp - this.timeAtBeat(from, tm),
					beats: next[\selBeat] - sliceLast
				);
			};
		};
		^sub
	}
	recalcSustains {
		^MIDIItemPlayer(
			this.makeNotes,
			this.source
		).copyBounds(this)
	}
	synthVPbind { |choiceFunc trimToStart=true|
		^trimToStart.if{
			this.trimTimeStampsToStart 
		}{ 
			this 
		}.doSynthVPbind(choiceFunc)
	}
	doSynthVPbind { |choiceFunc|
		var initialRestDur = midiEvents.select{|e| 
			e.type == \rest and: (e.timestamp == 0)
		}.collect(_.dur);
		var notes = (choiceFunc ? I.d).value(
			midiEvents.select{|e| e.midicmd == \noteOn}
		);
		var midinotes = notes.collect{|e| e.midinote};
		var durs = notes.collect{|e| e.timestamp}.differentiate.drop(1)
		//last dur
		++ (notes.last !? _.sustain ? 0);

		// insert initial rest
		if (initialRestDur.size > 0) {
			midinotes = midinotes.insert(0, 60); //will be made rest by \r in lyric
			durs = durs.insert(0, initialRestDur[0])
		}{ 
			if (notes[0].timestamp > 0) {
			midinotes = midinotes.insert(0, 60); //will be made rest by \r in lyric
			durs = durs.insert(0, notes[0].timestamp)
			}
		}

		^[midinote: midinotes, dur: durs].p
	}

    // choose the notes to make a Song line from (durations will be calculated)
	addLine { |name choiceFunc|
		var initialRestDur = midiEvents.select{|e| 
			e.type == \rest and: (e.timestamp == 0)
		}.collect(_.dur);
		var notes = 
		(choiceFunc ? I.d).value(

			midiEvents.select{|e| e.midicmd == \noteOn}
		);
		var midinotes = notes.collect{|e| e.midinote};
		var durs = notes.collect{|e| e.timestamp}.differentiate.drop(1)
		//last dur
		++ (notes.last.sustain ? 0);

		// add initial rest
		( initialRestDur.size > 0 ).if{
			midinotes = midinotes.insert(0, \r);
			durs = durs.insert(0, initialRestDur[0])
		} ;
		^[ name, midinotes, durs].addLine;
	}
	notesPbind { |mk| 
		var res = List.new;
		var keys = [\midinote, \sustain, \amp, \dur];
		keys.do{|key|
			res.add(key);
			res.add(  
				midiEvents.select{|e| e.midicmd == \noteOn}.collect{|i|
					i[key] ? \r //avoid nil for rest
				}.q
			)
		};
		res = res ++ [
			type: \mk,
			mk: mk
		] => _.p;
		^res
	}
}

MIDIItemTempoMap : AbstractMidiEvents { //this is almost the same as TempoMap but with timestamps instead of beats
	var <times, <>beats, midiEvents;
	var <env, <tempoMap ;
	var <invEnv, <curved = false, <curveAmount = 0;
	var <t0; // absolute timestamp of the first anchor (times/env are relative to it)
	// Per-Env O(log n) lookup cache (see prEnvLinCache): identity-keyed cumulative-time
	// index so timeAt/mapBeats don't linear-scan a big (oversampled) Env every call.
	var prEnvCache;

	*new {|midiItem, choiceFunc, beats|
		^super.new.init( midiItem, choiceFunc, beats)
	}
	// Media-neutral construction path: anchor times in seconds paired with
	// cumulative ideal-beat positions. Both axes are normalized to zero; the
	// first absolute time is retained as t0 for compatibility with placement.
	*fromAnchors {|anchorTimes, beatPositions|
		^super.new.initAnchors(anchorTimes, beatPositions)
	}
	// Add one closing anchor. Prefer an explicit closingAnchor; otherwise repeat
	// the last measured span so extrapolation keeps the last played tempo.
	init{|midiItem, choiceFunc, b|
		var closeTime, marks, lastSpan;
		midiEvents = midiItem.midiEvents;
		marks = (choiceFunc ? I.d)
		.value( midiEvents.select({|e| e.midicmd == \noteOn}))
		.collect{|e| e.timestamp };
		// N marks plus a closing anchor require N beat gaps.
		marks.isEmpty.if {
			Error("%: no anchor notes — the selection (or choiceFunc) picked nothing"
				.format(this.class)).throw
		};
		b.isNil.if {
			Error("%: no beat gaps — load a selection, or pass beats explicitly"
				.format(this.class)).throw
		};
		(b.size != marks.size).if {
			Error("%: need one beat gap per mark (% marks -> % anchors -> % spans), got %"
				.format(this.class, marks.size, marks.size + 1, marks.size, b.size)).throw
		};
		// Chord notes may share a timestamp; retain them and let tempo readers return nil.
		(marks.differentiate.drop(1).every(_ > 0)).not.if {
			"%: anchor times are not strictly increasing — spans of zero or negative "
			"width will read as no tempo".format(this.class).warn
		};
		lastSpan = (marks.size >= 2).if { marks.last - marks[marks.size - 2] };
		closeTime = (midiItem.tryPerform(\closingAnchor) !? (_[\time])) ?? {
			(lastSpan.notNil and: { lastSpan > 0 }).if
				{ marks.last + lastSpan }
				{ midiItem.bounds.end }
		};
		times = marks ++ closeTime;
		t0 = times[0];
		times = times - t0; //relative to first anchor
		beats = b;
		this.prBuildLinear;
	}
	// Anchor-constructed maps (initAnchors) have no MIDI source; fail loudly with
	// the reason instead of letting inherited AbstractMidiEvents methods
	// (noteOns, bounds, ...) crash on nil deep inside their bodies.
	midiEvents {
		^midiEvents ?? {
			Error("%: no MIDI events — this map was built from anchors, not a MIDIItem"
				.format(this.class)).throw
		}
	}
	initAnchors {|anchorTimes, beatPositions|
		var sourceTimes = anchorTimes.asArray;
		var sourceBeats = beatPositions.asArray;
		((sourceTimes.size < 2) or: { sourceTimes.size != sourceBeats.size }).if {
			Error("AnchorTempoMap: times and beatPositions must have the same size >= 2").throw
		};
		(sourceTimes.every(_.isNumber) and: { sourceBeats.every(_.isNumber) }).not.if {
			Error("AnchorTempoMap: every time and beat position must be numeric").throw
		};
		(sourceTimes.differentiate.drop(1).every(_ > 0)).not.if {
			Error("AnchorTempoMap: times must be strictly increasing").throw
		};
		(sourceBeats.differentiate.drop(1).every(_ > 0)).not.if {
			Error("AnchorTempoMap: beat positions must be strictly increasing").throw
		};
		midiEvents = nil;
		t0 = sourceTimes.first;
		times = sourceTimes - sourceTimes.first;
		beats = (sourceBeats - sourceBeats.first).differentiate.drop(1);
		this.prBuildLinear;
		^this
	}
	// (re)build env / tempoMap / invEnv from the current times + beats as the
	// piecewise-linear (constant-tempo-per-span) maps. Shared by init and the
	// beats transforms (scaleBeats); resets any curvature and the per-Env cache.
	// curve() replaces env/invEnv with a monotone-Hermite sampling afterwards.
	prBuildLinear {
		var gaps = times.differentiate.drop(1);
		// direction 1: performedTime -> idealBeat
		env = Env([0] ++ ([0] ++ beats.integrate), times.differentiate);
		// inner TempoMap kept only for doesNotUnderstand forwarding of TempoMap methods.
		tempoMap = TempoMap(beats, gaps);
		// direction 2: idealBeat -> performedTime, exact inverse of env's anchor nodes.
		invEnv = Env(times, beats);
		curved = false;
		curveAmount = 0;
		prEnvCache = nil;
	}
	offsets{
		^times.collect{|i| env[i] - i};
	}
	averageOffset{
		^this.offsets.mean
	}
	// average performed tempo of the selection, in beats per second. Full span:
	// total beats over the whole mapped region (first onset -> closing anchor),
	// since beats.sum maps to times.last. Playing the unit-beat quantize result
	// on TempoClock(bps) reproduces this tempo. The closing anchor now repeats the
	// last measured span (see init), so it no longer skews this the way a clip-end
	// anchor after a long final sustain did.
	bps {
		^(times.last > 0).if { beats.sum / times.last }
	}
	bpm { ^this.bps !? (_ * 60) }

	// Mean tempo over an arbitrary beat span, including boundary extrapolation.
	spanTempo { |from, to|
		var dt;
		((from.isNumber.not) or: { to.isNumber.not }).if {
			("spanTempo: from and to must be numbers, got % and %".format(from, to)).warn;
			^nil
		};
		(from >= to).if {
			("spanTempo: need from < to, got % and %".format(from, to)).warn;
			^nil
		};
		dt = this.timeAt(to) - this.timeAt(from);
		^(dt > 1e-9).if { (to - from) / dt }
	}
	spanBpm { |from, to| ^this.spanTempo(from, to) !? (_ * 60) }

	// Return bpm per span. Curved maps and subdivisions are sampled uniformly;
	// degenerate spans remain as nil to preserve alignment.
	tempoCurve { |subdiv = 1|
		var dom, step, n, ts, dts;
		(subdiv.isNumber.not or: { subdiv <= 0 }).if {
			("tempoCurve: subdiv must be a positive number (%)".format(subdiv)).warn;
			^[]
		};
		((subdiv == 1) and: { curved.not }).if {
			dts = times.differentiate.drop(1);
			^beats.collect { |b, i| (dts[i] > 1e-9).if { 60 * b / dts[i] } }
		};
		dom = this.beatDomain[1];
		(dom.isNil or: { dom <= 0 }).if { ^[] };
		step = 1 / subdiv;
		n = ((dom / step) + 1e-9).floor.asInteger;
		ts = (0 .. n).collect { |i| this.timeAt(i * step) };
		^ts.differentiate.drop(1).collect { |dt| (dt > 1e-9).if { 60 * step / dt } }
	}

	// Beat position where each tempoCurve value STARTS — the x axis for plotTempo.
	// Parallel to tempoCurve(subdiv), same size, so it can be handed to
	// Plotter.domain directly.
	tempoCurveBeats { |subdiv = 1|
		var dom, step, n;
		(subdiv.isNumber.not or: { subdiv <= 0 }).if {
			("tempoCurveBeats: subdiv must be a positive number (%)".format(subdiv)).warn;
			^[]
		};
		((subdiv == 1) and: { curved.not }).if {
			^([0] ++ beats.integrate).drop(-1)
		};
		dom = this.beatDomain[1];
		(dom.isNil or: { dom <= 0 }).if { ^[] };
		step = 1 / subdiv;
		n = ((dom / step) + 1e-9).floor.asInteger;
		(n < 1).if { ^[] };
		^(0 .. n - 1) * step
	}

	// Plot as steps. The final value is the closing span used for extrapolation.
	// domain: \beats (default) puts BEAT POSITION on the x axis, so a step's width
	// is the span it actually covers — with uneven spans (or a beatScale) the span
	// INDEX is not the beat number, and reading a ritardando off an index axis
	// misplaces it. \index restores the old evenly-spaced-per-span axis.
	plotTempo { |subdiv = 1, name, domain = \beats|
		var bpms = this.tempoCurve(subdiv);
		var bad = bpms.count(_.isNil);
		var xs, plotter;
		#[\beats, \index].includes(domain).not.if {
			Error("plotTempo: domain must be \\beats or \\index, got %".format(domain)).throw
		};
		bpms.isEmpty.if {
			"plotTempo: no spans to plot".warn;
			^nil
		};
		(bad > 0).if {
			"plotTempo: % degenerate span(s) drawn as 0".format(bad).warn
		};
		plotter = bpms.collect { |b| b ? 0 }
			.plot(name ?? { "% — tempo (bpm), % spans".format(this.class.name, bpms.size) })
			.plotMode_(\steps);
		(domain == \index).if { ^plotter };
		xs = this.tempoCurveBeats(subdiv);
		// Sizes disagree only if tempoCurve and tempoCurveBeats fell down different
		// branches; leave the index axis rather than mislabel it.
		(xs.size != bpms.size).if {
			"plotTempo: % beat positions for % spans — keeping the index axis"
				.format(xs.size, bpms.size).warn;
			^plotter
		};
		plotter.domainSpecs = ControlSpec(xs.first, this.beatDomain[1] ? xs.last,
			units: "beats");
		plotter.domain = xs;
		^plotter
	}
	at{|x|
		^env[x]
	}
	// ideal beat -> performed time, scalar (relative to the first anchor; add t0
	// for absolute time). Unlike `at`/`[]`, extrapolates past BOTH ends at the
	// boundary tempo instead of clamping — consistent with prMapThrough, and the
	// finite-difference slope follows the Hermite tangent when curved.
	timeAt { |beat|
		^this.prAtExtrapolated(beat, invEnv)
	}
	// Public protocol metadata in this map's relative coordinate frame (`t0`
	// remains the separate absolute placement offset). Curved maps may contain
	// oversampled Envs, so ask their actual domains rather than recomputing from
	// the original anchor arrays.
	beatDomain { ^[0, this.prEnvDomain(invEnv)] }
	timeDomain { ^[0, this.prEnvDomain(env)] }
	extrapolation { ^\carry }
	// Direction-explicit protocol aliases. Unlike the legacy `at`, beatAt also
	// follows this class's boundary policy and carries the endpoint tempo beyond
	// both ends of the map.
	beatAt { |time|
		^this.prAtExtrapolated(time, env)
	}
	prAtExtrapolated { |x, anEnv|
		// fetch the lin-cache ONCE per call (prEnvDomain + prEnvAtFast each did their
		// own IdentityDictionary lookup — measurable at prepare-time call volumes).
		var c = this.prEnvLinCache(anEnv);
		var at = c.notNil.if { { |xx| this.prEnvAtFastC(c, xx) } } { { |xx| anEnv.at(xx) } };
		var domain = c.notNil.if { c[0].last } { anEnv.times.sum };
		var eps, rate;
		(domain <= 0).if { ^at.(x) };
		eps = (domain * 1e-4) max: 1e-9;
		(x < 0).if {
			rate = (at.(eps) - at.(0)) / eps;
			^at.(0) + (x * rate)
		};
		(x > domain).if {
			rate = (at.(domain) - at.(domain - eps)) / eps;
			^at.(domain) + ((x - domain) * rate)
		};
		^at.(x)
	}
	// ---- fast piecewise-linear Env evaluation (O(log n), cached) ------------
	// env/invEnv (and .curve's oversampled outputs) are all built with \lin curves,
	// so a cached cumulative-time index + binary search reproduces Env.at exactly.
	// Any non-linear Env returns nil here and callers fall back to Env.at.
	prEnvLinCache { |anEnv|
		var entry, allLin, cum;
		prEnvCache ?? { prEnvCache = IdentityDictionary.new };
		entry = prEnvCache[anEnv];
		entry.notNil.if { ^(entry === \nonLinear).if { nil } { entry } };
		allLin = anEnv.curves.asArray.every { |c|
			(c == \lin) or: { c == \linear } or: { c == 0 }
		};
		allLin.not.if { prEnvCache[anEnv] = \nonLinear; ^nil };
		cum = [0] ++ anEnv.times.integrate;   // cumulative x-nodes (== the Env's time axis)
		entry = [cum, anEnv.levels, 0];       // slot 2: last-segment memo (see prEnvAtFastC)
		prEnvCache[anEnv] = entry;
		^entry
	}
	// domain (== sum of times) without an O(n) .times.sum every call
	prEnvDomain { |anEnv|
		var c = this.prEnvLinCache(anEnv);
		^c.notNil.if { c[0].last } { anEnv.times.sum }
	}
	// interior evaluation; clamps at the ends exactly like Env.at (extrapolation is
	// the caller's job in prAtExtrapolated/prMapThrough).
	prEnvAtFast { |anEnv, x|
		var c = this.prEnvLinCache(anEnv);
		c.isNil.if { ^anEnv.at(x) };
		^this.prEnvAtFastC(c, x)
	}
	// Same, on a prefetched cache entry. c[2] memoizes the segment index of the last
	// hit: prepare-time callers (beatToWall, mi2 warps, audio-follow chunks) walk beats
	// in near-sorted order, so that segment or its right neighbor usually matches and
	// the binary search is skipped.
	prEnvAtFastC { |c, x|
		var cum = c[0], lv = c[1];
		var lo, hi, mid, x0, x1, y0, y1;
		(x <= cum[0]).if { ^lv[0] };
		(x >= cum.last).if { ^lv.last };
		lo = (c[2] ? 0).clip(0, cum.size - 2);
		((cum[lo] <= x) and: { x < cum[lo + 1] }).not.if {
			(((lo + 2) < cum.size) and: { cum[lo + 1] <= x } and: { x < cum[lo + 2] }).if {
				lo = lo + 1
			} {
				lo = 0; hi = cum.size - 1;         // invariant: cum[lo] <= x < cum[hi]
				while { (hi - lo) > 1 } {
					mid = (lo + hi) div: 2;
					(cum[mid] <= x).if { lo = mid } { hi = mid };
				};
			}
		};
		c[2] = lo;
		x0 = cum[lo]; x1 = cum[lo + 1]; y0 = lv[lo]; y1 = lv[lo + 1];
		(x1 == x0).if { ^y0 };
		^y0 + ((y1 - y0) * (x - x0) / (x1 - x0))
	}
	// map cumulative positions through anEnv; positions past `domain` are extrapolated
	// at the env's final slope (carry the last tempo forward) instead of being clamped/
	// dropped. The finite-difference slope is the last linear segment OR, when curved,
	// the Hermite endpoint tangent -- so the tempo is continuous across the boundary.
	prMapThrough {|positions, anEnv, domain|
		var c = this.prEnvLinCache(anEnv);
		var at = c.notNil.if { { |xx| this.prEnvAtFastC(c, xx) } } { { |xx| anEnv.at(xx) } };
		var endV, eps, rate;
		(domain <= 0).if { ^positions.collect{|x| at.(x) } };
		endV = at.(domain);
		eps  = (domain * 1e-4) max: 1e-9;
		rate = (endV - at.(domain - eps)) / eps;
		^positions.collect{|x|
			(x <= domain).if { at.(x) }{ endV + ((x - domain) * rate) }
		}
	}
	mapBeats{|b, fromBeat = 0|
		^b.mapSpansFrom(fromBeat, { |beat| this.timeAt(beat) })
	}
	// `durs` always means elapsed seconds; map them into musical beat spans.
	// mapBeats is the opposite direction: beat spans -> second durations.
	mapDurs {|durs, fromTime = 0|
		^durs.mapSpansFrom(fromTime, { |t| this.beatAt(t) })
	}
	dursToBeats{|a, fromTime = 0|
		^this.mapDurs(a, fromTime)
	}

	// Reduce anchor density by merging adjacent ideal-beat spans. `sizes` is
	// either one positive integer or an array of positive integers which cycles
	// (mixed-meter/bar grouping). Placement is "pick": every new boundary keeps
	// the corresponding original anchor time verbatim. The remainder is always
	// retained, so both endpoints stay pinned and the full duration is preserved.
	// This is non-mutating and rebuilds a linear map; compose curvature afterward:
	//     map.clump(4).curve(amount)
	clump {|sizes = 2|
		^this.copy.prClump(sizes)
	}
	prClump {|sizes = 2|
		var grouping = sizes.asArray;
		var spanCount = beats.size;
		var starts = List[0], pos = 0, groupIndex = 0;
		var newBeats = List.new, newTimes;
		(grouping.isEmpty or: {
			grouping.any { |n| n.isNumber.not or: { n.asInteger != n } or: { n <= 0 } }
		}).if {
			("MIDIItemTempoMap.clump: group sizes must be positive integers (%)"
				.format(sizes)).warn;
			^this
		};
		(times.size != (spanCount + 1)).if {
			("MIDIItemTempoMap.clump: expected one more anchor time than beat spans "
				"(% times, % spans)".format(times.size, spanCount)).warn;
			^this
		};
		while { pos < spanCount } {
			var next = (pos + grouping.wrapAt(groupIndex)).min(spanCount);
			newBeats.add(beats.copyRange(pos, next - 1).sum);
			starts.add(next);
			pos = next;
			groupIndex = groupIndex + 1;
		};
		newTimes = starts.collect { |i| times[i] };
		beats = newBeats.asArray;
		times = newTimes.asArray;
		this.prBuildLinear;
		^this
	}

	// Return a NEW map with every ideal-beat span multiplied by `k` — i.e. each
	// recorded anchor gap counts as k ideal beats instead of 1. Pure relabel of the
	// beat axis: performed times are untouched, but bps/bpm scale by k and beat-domain
	// addressing rescales (timeAt(k*b) == old timeAt(b)). To reproduce the performance
	// you now feed k-beat spans: (k ! n).warpTo(t.scaleBeats(k)). Resets curvature —
	// compose it: t.scaleBeats(k).curve(amount).
	scaleBeats {|k = 1|
		^this.copy.prScaleBeats(k)
	}
	prScaleBeats {|k = 1|
		beats = beats * k;   // new array — the original's beats is left untouched
		this.prBuildLinear;
		^this
	}

	// Return a NEW map running `k` times faster — every performed span divided by
	// k, beat numbering untouched. The rubato is PRESERVED (each span keeps its
	// share of the total), which is what separates this from setBpm/setTempo (mean
	// tempo set, shape kept) and from quantize (shape removed, mean kept).
	//
	// NOT scaleBeats, which is the other axis: scaleBeats relabels beats and
	// leaves the performance where it was recorded, so the take still lasts as
	// long; scaleTempo moves the performance and leaves the beat numbers alone,
	// so beat 6 is still beat 6 but arrives sooner. t0 is absolute placement and
	// is left alone — the take starts where it started and runs faster.
	// Resets curvature, like scaleBeats: compose as t.scaleTempo(k).curve(amount).
	scaleTempo {|k = 1|
		((k.isNumber.not) or: { k <= 0 }).if {
			Error("MIDIItemTempoMap.scaleTempo: k must be > 0, got %".format(k)).throw
		};
		^this.copy.prScaleTempo(k)
	}
	// Set the map's mean tempo, keeping the rubato: the scaleTempo factor that lands
	// it there. The mean is total beats / total seconds — what spanBpm reads back,
	// not the arithmetic mean of the per-span tempi. Whole-map only here; span
	// editing lives on the core (asMonoMap) and on EventList.
	setBpm {|bpm|
		var mean;
		((bpm.isNumber.not) or: { bpm <= 0 }).if {
			Error("MIDIItemTempoMap.setBpm: bpm must be > 0, got %".format(bpm)).throw
		};
		mean = this.spanBpm(0, beats.sum);
		mean.isNil.if {
			Error("MIDIItemTempoMap.setBpm: this map has no width to read a tempo from").throw
		};
		^this.scaleTempo(bpm / mean)
	}
	setTempo {|bps|
		((bps.isNumber.not) or: { bps <= 0 }).if {
			Error("MIDIItemTempoMap.setTempo: bps must be > 0, got %".format(bps)).throw
		};
		^this.setBpm(bps * 60)
	}
	prScaleTempo {|k = 1|
		times = times / k;   // new array — the original's times is left untouched
		this.prBuildLinear;
		^this
	}

	// Return a re-zeroed map over [from, to], preserving absolute placement in t0.
	// Trim closing spans before concatenating map slices.
	fromBeat {|from = 0, to|
		^this.copy.prTrim(from, to)
	}
	/* pre-rename name; player.trim(bool) means something else entirely */
	trim {|from = 0, to| ^this.fromBeat(from, to) }

	// Concatenate maps on both axes. Trim intended sections first with fromBeat.
	++ { |other| ^this.asMonoMap ++ other }

	// Concatenate and smooth the tempo seam (AnchorMap.easeTo). Same bridge shape
	// as ++: snapshot to anchors and hand `other` over as a shape.
	easeTo { |other, before = 1, after = 0, q = 2, amount = 1, w|
		^this.asMonoMap.easeTo(other, before, after, q, amount, w)
	}
	prTrim {|from = 0, to|
		var cum = [0] ++ beats.integrate;    // cumulative beat nodes, parallel to `times`
		var lo = from, hi, keep, fromTime;
		hi = to ? cum.last;
		(hi <= lo).if {
			("MIDIItemTempoMap.fromBeat: to (%) must be > from (%)".format(hi, lo)).warn;
			^this
		};
		keep     = (0 .. (cum.size - 1)).select { |i| (cum[i] > lo) and: { cum[i] < hi } };
		fromTime = this.timeAt(lo);
		// exact endpoints + interior anchors, then re-zero to the window start
		beats = (([lo] ++ keep.collect { |i| cum[i] } ++ [hi]) - lo).differentiate.drop(1);
		times = ([fromTime] ++ keep.collect { |i| times[i] } ++ [this.timeAt(hi)]) - fromTime;
		t0 = t0 + fromTime;
		this.prBuildLinear;
		^this
	}

	// Return a NEW MIDIItemTempoMap whose performed<->ideal mapping is a monotone
	// cubic Hermite (PCHIP) curve through the same anchor nodes, instead of the
	// piecewise-linear (constant-tempo-per-span) default. Because the curve passes
	// through every anchor exactly, the integral over each span is preserved:
	// anchors stay locked, only the tempo SHAPE between them bends.
	//   amount: 0 = linear (identical to the default map), 1 = full curvature.
	//   oversample: samples per span baked into the resulting Env (resolution of the curve).
	// Monotone tangent-clamping (Fritsch-Carlson) guarantees tempo never goes negative.
	curve {|amount = 1, oversample = 32|
		^this.copy.prCurve(amount, oversample)
	}
	prCurve {|amount = 1, oversample = 32|
		var b = [0] ++ beats.integrate;   // ideal-beat node positions (x)
		var t = times;                    // performed-time node positions (y)
		var n = b.size min: t.size;
		var m, bs = [], ts = [];
		b = b.keep(n); t = t.keep(n);
		m = this.prMonotoneTangents(b, t);
		(n - 1).do {|k|
			var h  = b[k+1] - b[k];
			var dy = t[k+1] - t[k];
			oversample.do {|j|
				var x    = j / oversample;
				var lin  = t[k] + (dy * x);
				var herm = this.prHermite(x, t[k], t[k+1], m[k] * h, m[k+1] * h);
				bs = bs.add( b[k] + (h * x) );
				ts = ts.add( lin + ((herm - lin) * amount) );
			}
		};
		bs = bs.add(b.last); ts = ts.add(t.last);
		env    = Env(bs, ts.differentiate.drop(1));   // performedTime -> beat (direction 1)
		invEnv = Env(ts, bs.differentiate.drop(1));    // beat -> performedTime (direction 2)
		prEnvCache = nil;                              // copy shared the parent's dict; start fresh
		curved = true;
		curveAmount = amount;
		^this
	}
	// cubic Hermite basis on a single span, local x in [0,1]
	prHermite {|x, y0, y1, m0, m1|
		var x2 = x * x, x3 = x2 * x;
		^( ((2 * x3) - (3 * x2) + 1) * y0 )
		+ ( (x3 - (2 * x2) + x) * m0 )
		+ ( (((-2) * x3) + (3 * x2)) * y1 )
		+ ( (x3 - x2) * m1 )
	}
	// per-node tangents dy/dx with Fritsch-Carlson monotonicity clamp
	prMonotoneTangents {|x, y|
		var dx = x.differentiate.drop(1).collect{|i| i.abs max: 1e-9 };
		var d  = y.differentiate.drop(1) / dx;   // secant slopes (size n-1)
		var n  = x.size;
		var m  = [ d[0] ];
		(n - 2).do {|i| m = m.add( (d[i] + d[i+1]) * 0.5 ) };
		m = m.add(d.last);
		(n - 1).do {|k|
			(d[k] == 0).if
				{ m[k] = 0; m[k+1] = 0 }
				{
					var a  = m[k]   / d[k];
					var bb = m[k+1] / d[k];
					var s  = (a * a) + (bb * bb);
					(s > 9).if {
						var tau = 3 / s.sqrt;
						m[k]   = tau * a  * d[k];
						m[k+1] = tau * bb * d[k];
					}
				}
		};
		^m
	}
	doesNotUnderstand{|selector ...args|
		tempoMap.respondsTo(selector).if{
			^Message(tempoMap, selector, args).()
		}{
		this.class + "does not understand" + selector	
		}
	}
}

// Public media-neutral name. MIDI selections remain one authoring adapter for
// the same anchor representation; callers with audio, taps, imported markers,
// or synthetic data can construct the map directly without a fake MIDIItem.
AnchorTempoMap : MIDIItemTempoMap {
	*new {|times, beatPositions|
		^this.fromAnchors(times, beatPositions)
	}
}

SelfReturningObject {
	*new{
		^super.new
	}
	doesNotUnderstand{
		^this
	}
}

+ Synth{
	mapCC{ |param num spec|
		var cc = CC(param, num, spec);
		this.set(param, cc.spec.map(cc.spec.map(cc.val)));
		cc.mapSynth(this, param)
	}
}
 
+ SequenceableCollection {
		setDurs { |finalDur = 1| 
			var durs = this
			.sort{|i j| i.timestamp < j.timestamp}
			.collect(_.timestamp).differentiate.drop(1) ++ finalDur ;
			durs.do{|i x| try{ this[x].dur = i }  };
			^this
		}
		eventsToPatternPairs{
			^this.collect({ |i| i.asAssociations.sort.asPairs}).flop.collect{|i|
				( i[0].class == Symbol ).if { i[0] }{ i.q }
			}
		}
		// keyword-array form: [midinote: [...], dur: [...]].asMIDIItem
		asMIDIItem {
			var e = ();
			this.pairsDo { |k, v| e[k] = v };
			^e.asMIDIItem
		}
}

+ Event {
	// Build an ad-hoc MIDIItem from a compact pitch/duration spec, e.g.
	//   [midinote: [60,62,64], dur: "q e e".beats].asMIDIItem
	// `midinote` (or `note`) is a pitch (Array or scalar); `dur` is an Array, a
	// scalar (applied to all), or a rhythm String ("q e e" -> .beats); `amp`
	// optional (Array/scalar, default 0.7). Emits paired noteOn/noteOff events in
	// the RAW recorded format (\mk / \mkOff) — what makeNotesFromMidiEvents consumes
	// (it pairs offs into the noteOn `sustain` and rejects the raw \mk copies, so
	// notes don't double). Timestamps are in BEATS — a reference is a score, not a
	// performance — so MIDIItem gui/playback (which assume seconds) read it at a
	// nominal tempo. Monophonic: adjacent same-pitch notes don't overlap, so
	// off-pairing by midinote is unambiguous. (Rests: not yet.)
	asMIDIItem {
		var notes, durs, amps, onsets, events, n;
		notes = (this[\midinote] ? this[\note]).asArray;
		n = notes.size;
		(n == 0).if { ^Error("asMIDIItem: spec needs a \\midinote (or \\note)").throw };
		durs = this[\dur] ? 1;
		durs.isString.if { durs = durs.beats };
		durs = durs.asArray.wrapExtend(n);
		amps = (this[\amp] ? 0.7).asArray.wrapExtend(n);
		onsets = durs.integrate.drop(-1).addFirst(0);   // cumulative onsets, beat time
		events = List.new;
		n.do { |i|
			events.add((midicmd: \noteOn,  type: \mk,    midinote: notes[i],
				timestamp: onsets[i],           sustain: durs[i], amp: amps[i]));
			events.add((midicmd: \noteOff, type: \mkOff, midinote: notes[i],
				timestamp: onsets[i] + durs[i], amp: amps[i]));
		};
		events = events.sort { |a, b| a.timestamp < b.timestamp };
		// NB: not MIDIItem.newFrom — it names items after the UniqueID *class* (not
		// .next), so repeated builds would alias/overwrite each other in MIDIItem.all.
		^MIDIItem(("ref_" ++ UniqueID.next).asSymbol).midiEvents_(events)
	}
}

+ String {
	// Build a MIDIItem from a Standard MIDI File on disk:
	//   "~/home/studio-idea/recordings/tb_rec_20260428_152927.mid".asMIDIItem("myTake")
	// name is optional (defaults to the file's basename). The receiver is a path;
	// contrast Event/SequenceableCollection asMIDIItem, which build score specs.
	asMIDIItem { |name|
		^MIDIItem.fromMIDIFile(this, name)
	}
}
