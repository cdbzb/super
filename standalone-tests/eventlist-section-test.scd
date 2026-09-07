// Pure-language section DSL regression; no audio server required.
// Run: sclang -D standalone-tests/eventlist-section-test.scd
(
var h = (thisProcess.nowExecutingPath.dirname +/+ "test-helpers.scd").load;
var check = h[\assert], times = h[\assertArr];
var child, f, legacy, anonymous, rounded, custom, positional, rejected;
var oldPlayFn = EventList.playFn, playedFrom;
child = EventList(\zzzSectionChild, \note);
child.add(0, dur: 4);
f = EventList.sequenced(nil, \eventList);
f.section(\zzzSectionChild);
f.add(eventList: child, dur: 20); // a long layer does not extend its section
f.section(\zzzSectionChild);
f.add(1, eventList: child);
f.section(\zzzSectionChild, section: \alternate, dur: 2);
f.section(eventList: \zzzSectionChild);
times.(f.events.collect(_[\when]), [0, 0, 4, 5, 8, 10],
    "repeats open sections; add layers and offsets retain their placement");
check.(f.env[\nextWhen] == 14, "opening event controls duration");
check.(f.events[0][\section] == \zzzSectionChild, "symbol supplies navigation label");
check.(f.events[1][\section].isNil, "layers do not acquire navigation labels");
check.(f.events[4][\section] == \alternate, "explicit label overrides child name");
check.(f.events[5][\section] == \zzzSectionChild, "keyword child supplies default label");
check.(f.events.every { |e| e.includesKey(\eventListSectionStart).not },
    "private boundary marker is consumed before storage");
check.(f.events.every { |e| e[\type] == \eventList }, "child type inferred through add");
EventList.playFn = { |list, from| playedFrom = from };
f.play(fromSection: \zzzSectionChild);
check.(playedFrom == 0, "play finds first occurrence of a repeated label");
f.play(0.5, fromSection: \alternate);
check.(playedFrom == 8.5, "play finds explicit label and applies offset");
EventList.playFn = oldPlayFn;

anonymous = EventList.sequenced(nil, \note);
anonymous.section(newType: \note, dur: 3);
anonymous.add(1, newType: \note, dur: 10);
anonymous.section(newType: \func, func: {}); // unmeasurable: one-beat placeholder
anonymous.add(newType: \note, dur: 10);
anonymous.section(child);
times.(anonymous.events.collect(_[\when]), [0, 1, 3, 3, 4],
    "anonymous sections layer and unmeasurable openings advance");
check.(anonymous.events[0][\section].isNil and: {
    anonymous.events[2][\section].isNil }, "anonymous sections have no public labels");
check.(anonymous.events[4][\section] == \zzzSectionChild,
    "EventList instance supplies its name");

legacy = EventList.sequenced(nil, \note);
legacy.add(section: \a, dur: 4);
legacy.add(section: \a, dur: 10);
legacy.add(dur: 10);
legacy.add(section: \a, again: true, dur: 2);
legacy.add(section: \b, dur: 3);
times.(legacy.events.collect(_[\when]), [0, 0, 0, 4, 6],
    "legacy labels and again retain grouping behavior");
legacy = EventList.sequenced(nil, \note);
legacy.add(dur: 2);
legacy.add(dur: 3);
times.(legacy.events.collect(_[\when]), [0, 2], "bare legacy adds still sequence");

rounded = EventList.sequenced(nil, \eventList, quantum: 8);
rounded.section(child);
rounded.section(child, dur: 3);
rounded.section(child);
times.(rounded.events.collect(_[\when]), [0, 8, 11],
    "quantum rounds measured duration but respects explicit duration");
custom = EventList.sequenced(nil, \note, { |ev| ev[\length] });
custom.section(length: 5);
custom.add(length: 100);
custom.section(length: 2);
times.(custom.events.collect(_[\when]), [0, 0, 5],
    "custom sectionDur still controls openings only");

positional = EventList.sequenced(nil, \eventList);
positional.section(child, dur: 4);
positional.section(4, child, dur: 8);
positional.section(child, dur: 2);
times.(positional.events.collect(_[\when]), [0, 4, 12],
    "positional when is a gap that still advances the running end");
positional.add(2, dur: 1);
positional.section(1, dur: 1);
times.(positional.events.collect(_[\when]).drop(3), [14, 15],
    "a layer after a gapped section anchors to it; the next gap follows the layer");

rejected = false;
{ f.section(\zzzSectionChild, eventList: child) }.try { rejected = true };
check.(rejected, "ambiguous child arguments rejected");
check.(f.events.size == 6, "rejected call stores no event");
rejected = false;
{ f.section("nope") }.try { rejected = true };
check.(rejected, "invalid positional argument rejected");
rejected = false;
{ f.section(4, 5) }.try { rejected = true };
check.(rejected, "second positional must still be a child");
rejected = false;
{ f.section(4, child, when: 4) }.try { rejected = true };
check.(rejected, "ambiguous when arguments rejected");
rejected = false;
{ f.section(child, 4) }.try { rejected = true };
check.(rejected, "a second positional needs a numeric when first");
rejected = false;
{ EventList(nil, \note).section(child) }.try { rejected = true };
check.(rejected, "ordinary list rejects section without sequencing");

EventList.all.removeAt(\zzzSectionChild);
h[\report].().exit;
)
