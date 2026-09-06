// Pure-language regression tests for SynthVVST freeze selection. No server use.
var h = (thisProcess.nowExecutingPath.dirname +/+ "test-helpers.scd").load;
var assert = h[\assert];
var oldCache = SynthVVST.cache;
var params = (lyrics: "la", midinote: [60], dur: [1]);
var fakeSynthV = { |vst| var sv = SynthV.prNew; sv.vst = vst; sv };
var a, duplicate, closed, multi, got;

"== SynthVVST freeze selection tests ==".postln;

a = SynthVVST(\xuan2, params);
a.synthV = fakeSynthV.((token: \open));
duplicate = SynthVVST(\xuan2, params);
duplicate.synthV = fakeSynthV.((token: \alsoOpen));
closed = SynthVVST(\uni2, params);
closed.synthV = fakeSynthV.(nil);
multi = SynthVVST(\choirZh2, params.copy.put(\midinote, [[60], [64]]));
multi.synthV = [fakeSynthV.(nil), fakeSynthV.((token: \open))];

assert.(a.isOpen, "single live VST is open");
assert.(closed.isOpen.not, "nil VST is closed");
assert.(multi.isOpen, "one live voice makes a multi take open");

SynthVVST.cache = IdentityDictionary[
	a.cacheKey -> a,
	closed.cacheKey -> closed,
	multi.cacheKey -> multi
];

got = SynthVVST.prFreezeItems;
assert.(got.includes(a), "default selection includes an open cached take");
assert.(got.includes(multi), "default selection includes an open multi take");
assert.(got.includes(closed).not, "default selection excludes a closed take");
assert.(got.size == 2, "default selection contains only open cache entries");

got = SynthVVST.prFreezeItems([duplicate, a, duplicate]);
assert.(got.size == 1, "explicit selection deduplicates cache keys");
assert.(got[0] === a, "explicit selection prefers the cached canonical wrapper");

SynthVVST.cache = oldCache;
h[\report].().exit;
