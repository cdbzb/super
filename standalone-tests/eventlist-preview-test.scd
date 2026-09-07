// Nested preview must use the same placement/filtering as list playback.
// Pure-language callbacks only: no synths, buffers, or audio server needed.
(
var h = (thisProcess.nowExecutingPath.dirname +/+ "test-helpers.scd").load;
var check = h[\assert], times = h[\assertArr];
var child, parent, ev, actions, normal, own, hits = List[], previewList;
child = EventList(\zzzPreviewChild, \func);
child.beatDur = 2;
child.add(0, name: \altVox, func: { hits.add(\altVox) });
child.add(2, name: \altVox, func: { hits.add(\altVoxLater) });
child.add(0, name: \keys, func: { hits.add(\keys) });
parent = EventList.sequenced(nil, \eventList);
parent.beatDur = 0.25;
parent.section(newType: \rest, dur: 54);
ev = parent.section(child, solo: [\altVox], followTrack: true, dur: 4);
parent.nextPreviewOffset(0);
actions = parent.prPreviewListActions(parent.resolveEvent(ev), 0, parent.tempoEnv);
normal = parent.prepare(0, from: 54);
times.(actions.collect(_[\time]), [0, 0.5],
    "late-score section previews immediately at parent tempo");
times.(actions.collect(_[\time]), normal.collect(_[\time]),
    "preview placement matches play from this section");
check.(actions.size == 2, "preview honors insertion solo");
check.(child.solo.isNil and: { child.mute.isNil },
    "preview does not change the child's filter state");
own = ev.copy;
own[\followTrack] = false;
times.(parent.prPreviewListActions(own, 0, parent.tempoEnv).collect(_[\time]),
    [0, 4], "own-tempo preview retains child timing");
times.(parent.prPreviewListActions(ev, 2, parent.tempoEnv).collect(_[\time]),
    [0.5, 1], "preview offset shifts onset without changing score tempo");
own = ev.copy;
own[\start] = 1;
own[\end] = 3;
times.(parent.prPreviewListActions(own, 0, parent.tempoEnv).collect(_[\time]),
    [0.25], "preview respects child start/end trim");

// Two insertions of the same child in one preview batch used to call child.play
// twice. The second child.fire cancelled the first child's pending sends.
previewList = EventList.sequenced(nil, \eventList);
previewList.beatDur = 0.01;
previewList.preview = true;
previewList.section(child, solo: [\altVox], followTrack: true, dur: 4);
previewList.section(child, solo: [\keys], followTrack: true, dur: 4);
Routine {
    0.2.wait;
    check.(hits.includes(\altVox), "first child's soloed event survives the second preview");
    check.(hits.includes(\altVoxLater), "first child's later event survives");
    check.(hits.includes(\keys), "second child preview also plays");
    EventList.all.removeAt(\zzzPreviewChild);
    h[\report].().exit;
}.play(SystemClock);
)
