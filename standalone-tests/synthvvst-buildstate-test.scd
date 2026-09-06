// Pure-language regression tests for SynthVVST's build-state guard. No server use:
// prShouldRebuild is a predicate, and every build case here returns from the cache
// hit before any VST is opened.
var h = (thisProcess.nowExecutingPath.dirname +/+ "test-helpers.scd").load;
var assert = h[\assert];
var oldCache = SynthVVST.cache;
var params = (lyrics: "la", midinote: [60], dur: [1]);
var fakeSynthV = { |vst| var sv = SynthV.prNew; sv.vst = vst; sv };
/* A cached take in a given state, published under its own key. `ready` is
   deliberately getter-only on the class, so seed it directly rather than widening
   the API for a test. */
var cacheAs = { |state, up = false|
	var item = SynthVVST(\xuan2, params);
	item.synthV = fakeSynthV.((token: \open));
	item.instVarPut(\ready, Condition(up));
	item.buildState = state;
	SynthVVST.cache = IdentityDictionary[item.cacheKey -> item];
	item
};
var probe = { SynthVVST(\xuan2, params) };
var cached, adopting;

"== SynthVVST build-state tests ==".postln;

/* The bug this guards: an open still in flight has a down Condition, which the old
   test read as breakage. Rebuilding reopened the same /private/tmp/<cacheKey>.fxp
   while the outgoing plugin still held it, and Synthesizer V asked to save a copy. */
cached = cacheAs.(\building);
assert.(probe.().prShouldRebuild(cached).not, "a build still opening is not rebuilt");

cached = cacheAs.(\ready, true);
assert.(probe.().prShouldRebuild(cached).not, "a ready take is not rebuilt");

// The two states a rebuild is actually for: the plugin behind them is gone.
[\failed, \stale, nil].do{|state|
	cached = cacheAs.(state);
	assert.(probe.().prShouldRebuild(cached),
		"% is rebuilt".format(state ? "an untagged down take"));
};

assert.(probe.().prShouldRebuild(nil).not, "an empty cache slot is not a rebuild");

// Adoption: the in-flight take stays in the cache and its Condition is shared, so
// every caller is released by the single open already running.
cached = cacheAs.(\building);
adopting = probe.().build;
assert.(SynthVVST.cache[cached.cacheKey] === cached,
	"the in-flight take is left in the cache, not replaced");
assert.(adopting.ready === cached.ready, "the adopting take shares the Condition");
assert.(adopting.synthV === cached.synthV, "the adopting take shares the SynthV");
assert.(adopting.buildState == \building, "the adopted state carries over");

// Cmd-. tags every cached take rather than only lowering its Condition.
cached = cacheAs.(\ready, true);
SynthVVST.doOnCmdPeriod;
assert.(cached.ready.test.not, "Cmd-. lowers the Condition");
assert.(cached.buildState == \stale, "Cmd-. tags the take stale, not failed");

// freeVSTs drops the state along with the resources it names.
cached = cacheAs.(\ready, true);
cached.synthV = fakeSynthV.(nil);
cached.freeVSTs;
assert.(cached.buildState.isNil, "freeVSTs clears the build state");

SynthVVST.cache = oldCache;
h[\report].().exit;
