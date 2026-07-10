// Shared assert vocabulary for the standalone-tests suites. Pure language.
//
// Usage (from a suite in this directory):
//   var h = (thisProcess.nowExecutingPath.dirname +/+ "test-helpers.scd").load;
//   h[\assert].(cond, "msg");
//   h[\assertClose].(a, b, "msg", 1e-6);
//   h[\assertArr].([1,2], [1,2], "msg", 1e-6);
//   h[\maxErrOver].(t0, t1, { |t| ...err at t... }, 1000);  // -> max err on grid
//   h[\fail].("msg");                                       // count a failure directly
//   h[\report].();  // prints summary, returns failure count (caller decides 0.exit)
//
// Each .load creates independent counters, so one sclang can run several
// suites without cross-talk. Default tol is 1e-6 — suites wanting a
// different default should wrap in a local shim rather than rely on it.
(
var count = 0, failures = 0, h = ();
h[\assert] = { |cond, msg|
	count = count + 1;
	cond.if { ("  ok - " ++ msg).postln } {
		failures = failures + 1;
		("FAIL - " ++ msg).postln
	}
};
h[\fail] = { |msg|
	count = count + 1;
	failures = failures + 1;
	("FAIL - " ++ msg).postln
};
h[\assertClose] = { |a, b, msg, tol = 1e-6|
	h[\assert].((a - b).abs < tol, msg + "(got % want %)".format(a, b))
};
// element-wise closeness for equal-length arrays
h[\assertArr] = { |a, b, msg, tol = 1e-6|
	var ok = (a.size == b.size) and: {
		a.every { |x, i| (x - b[i]).abs < tol }
	};
	h[\assert].(ok, msg + "(got % want %)".format(a, b))
};
// max of errFunc.(t) over an (n+1)-point grid on [t0, t1]
h[\maxErrOver] = { |t0, t1, errFunc, n = 1000|
	var m = 0;
	(n + 1).do { |i|
		var t = t0 + ((t1 - t0) * i / n);
		var err = errFunc.(t);
		(err > m).if { m = err };
	};
	m
};
h[\report] = {
	"".postln;
	("== % checks, % failures ==".format(count, failures)).postln;
	(failures == 0).if { "ALL PASS".postln } { "FAILURES".postln };
	failures
};
h
)
