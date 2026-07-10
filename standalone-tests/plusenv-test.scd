// Headless regression suite for plusEnv.sc — Env monotone time-map algebra
// (compose / <> / o, invert, bakeLinear, isMonotone, isLinearShaped).
// Pure language — no server.
// Run: /Applications/SuperCollider.app/Contents/MacOS/sclang standalone-tests/plusenv-test.scd
(
var h = (thisProcess.nowExecutingPath.dirname +/+ "test-helpers.scd").load;
var assert = h[\assert];
var assertClose = { |a, b, msg, tol = 1e-12| h[\assertClose].(a, b, msg, tol) };
var composeErr = { |f, g, t0, t1|
	var c = f.compose(g);
	h[\maxErrOver].(t0, t1, { |t| (c.at(t) - f.at(g.at(t))).abs })
};
var f, g, c, m, inv, gExp, b, badInv;

"== plusEnv (Env map algebra) tests ==".postln;

try {

f = Env([0, 2, 3, 7, 8], [1, 2, 1, 3]);           // strictly increasing, domain [0,7], range [0,8]
g = Env([0, 1.5, 4, 7], [2, 3, 1]);               // monotone, domain [0,6], range [0,7]

// -- 1. linear ∘ linear is exact -------------------------------------------
assert.(composeErr.(f, g, 0, 6) < 1e-12, "compose: linear∘linear exact");
assert.(f.compose(g).isLinearShaped, "compose: result is lin-shaped");

// -- 2. identity map --------------------------------------------------------
assert.(composeErr.(g, Env([0, 6], [6]), 0, 6) < 1e-12, "compose: identity inner");

// -- 3. invert roundtrip: (f^-1 ∘ f)(t) == t --------------------------------
inv = f.invert;
c = inv.compose(f);
m = h[\maxErrOver].(0, 7, { |t| (c.at(t) - t).abs });
assert.(m < 1e-9, "invert: roundtrip is identity (maxErr %)".format(m));

// -- 4. curved inner gets baked; bounded error ------------------------------
gExp = Env([0.5, 4, 6], [2, 2], \exp);
m = composeErr.(f, gExp, 0, 4);
assert.(m < 0.02, "compose: curved inner baked, err bounded (maxErr %)".format(m));
assert.(f.compose(gExp).isLinearShaped, "compose: curved result is lin-shaped");

// -- 5. bakeLinear exact at original breakpoints ----------------------------
b = gExp.bakeLinear;
assert.(b.isLinearShaped, "bakeLinear: output lin-shaped");
[[0, 0.5], [2, 4], [4, 6]].do { |pair|
	assertClose.(b.at(pair[0]), pair[1], "bakeLinear: breakpoint t=%".format(pair[0]))
};

// -- 6. flat segment in inner — exact ---------------------------------------
assert.(composeErr.(f, Env([0, 2, 2, 5], [1, 2, 1]), 0, 4) < 1e-12,
	"compose: flat inner segment exact");

// -- 7. non-monotone inner — per-segment preimages still correct ------------
g = Env([0, 5, 1, 6], [2, 2, 2]);
assert.(g.isMonotone.not, "isMonotone: false for non-monotone");
assert.(f.isMonotone, "isMonotone: true for monotone");
assert.(composeErr.(f, g, 0, 6) < 1e-12, "compose: non-monotone inner exact");

// -- 8. jump (zero-duration segment) in inner survives ----------------------
g = Env([0, 2, 5, 6], [1, 0, 2]);
c = f.compose(g);
assert.((c.at(0.99) - f.at(g.at(0.99))).abs < 1e-9 and: {
	(c.at(1.01) - f.at(g.at(1.01))).abs < 1e-9 } and: {
	(c.at(1.01) - c.at(0.99)).abs > 1 },
	"compose: jump in inner preserved");

// -- 9. inner exceeding outer domain clamps like Env.at ---------------------
assert.(composeErr.(f, Env([0, 10], [2]), 0, 2) < 1e-12,
	"compose: clamp beyond outer domain");

// -- 10. invert refuses decreasing levels -----------------------------------
badInv = Env([3, 1], [1]).invert;
assert.(badInv.isNil, "invert: decreasing levels -> nil (+warning)");

// -- 11. operator aliases ----------------------------------------------------
g = Env([0, 1.5, 4, 7], [2, 3, 1]);
assertClose.((f <> g).at(2.5), f.compose(g).at(2.5), "<> alias");
assertClose.(f.o(g).at(2.5), f.compose(g).at(2.5), ".o alias");

} { |e|
	h[\fail].("EXCEPTION - " ++ e.errorString);
};

// -------------------------------------------------------------------- report
h[\report].();
0.exit;
)
