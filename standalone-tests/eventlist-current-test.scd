// EventList.current is set explicitly, never as a lookup side effect.
// Pure-language; no server, no audio.
(
var h = (thisProcess.nowExecutingPath.dirname +/+ "test-helpers.scd").load;
var check = h[\assert], times = h[\assertArr];
var a, b, saved, threw;
saved = { EventList.current }.try;

a = EventList(\zzzCurA, \note);
b = EventList(\zzzCurB, \note);
EventList.current_(a);
check.(EventList.current === a, "current_ sets the current list");
EventList(\zzzCurB);
check.(EventList.current === a, "looking a list up does not make it current");
EventList.sequenced(\zzzCurC, \note);
check.(EventList.current === a, "sequenced does not make its list current");
check.(EventList.newFrom(a, \zzzCurD).name == \zzzCurD, "newFrom builds a list");
check.(EventList.current === a, "newFrom does not make its list current");

check.(b.current === b, "the current instance method returns this, so it chains");
check.(EventList.current === b, "the current instance method sets the class-side list");

// the trap this replaced: a lookup inside an argument list used to redirect the add
\zzzVoice.add(3, dur: EventList(\zzzCurA).events.size + 1);
check.(b.events.size == 1, "symbol add lands in the current list, not the looked-up one");
check.(a.events.isEmpty, "the looked-up list is untouched");
check.(b.events[0][\name] == \zzzVoice, "symbol add stamps the voice name");

EventList.current_(nil);
threw = false;
{ \zzzVoice.add(0) }.try { threw = true };
check.(threw, "a symbol add with no current list raises rather than nil-dispatching");
threw = false;
{ EventList.add(0) }.try { threw = true };
check.(threw, "the class-side delegators raise too");

[\zzzCurA, \zzzCurB, \zzzCurC, \zzzCurD].do { |k| EventList.all.removeAt(k) };
EventList.current_(saved);
h[\report].().exit;
)
